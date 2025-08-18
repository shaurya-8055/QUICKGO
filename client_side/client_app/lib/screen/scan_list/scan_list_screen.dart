import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/data/data_provider.dart';
import '../../models/product.dart';
import '../product_cart_screen/provider/cart_provider.dart';
import '../product_favorite_screen/provider/favorite_provider.dart';

class ScanListScreen extends StatefulWidget {
  const ScanListScreen({super.key});

  @override
  State<ScanListScreen> createState() => _ScanListScreenState();
}

class _ScanListScreenState extends State<ScanListScreen> {
  final TextEditingController _listController = TextEditingController();
  final Map<String, _MatchResult> _matches = {};
  final Map<String, Product?> _chosen = {};

  bool _searching = false;

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  double _effectivePrice(Product p) =>
      (p.offerPrice ?? p.price ?? double.maxFinite).toDouble();

  // --- Input parsing helpers ---
  static final RegExp _qtySuffix =
      RegExp(r'(?:^|\s)(x|\*)\s*(\d+)\s*$', caseSensitive: false);
  static final RegExp _qtyPrefix = RegExp(r'^(\d+)\s*[a-zA-Z]*\b');

  List<_ParsedItem> _parseInput(String raw) {
    final lines = raw
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final Map<String, _ParsedItem> dedup = {};
    for (var line in lines) {
      int qty = 1;
      // parse suffix like "watch x2" or "bottle*3"
      final sfx = _qtySuffix.firstMatch(line);
      if (sfx != null) {
        qty = int.tryParse(sfx.group(2) ?? '1') ?? 1;
        line = line.replaceRange(sfx.start, sfx.end, '').trim();
      } else {
        // parse prefix like "2 milk" or "3kg rice" (takes number only)
        final pfx = _qtyPrefix.firstMatch(line);
        if (pfx != null) {
          qty = int.tryParse(pfx.group(1) ?? '1') ?? 1;
          line = line.replaceFirst(pfx.group(1)!, '').trim();
        }
      }

      final base = _normalize(line);
      if (base.isEmpty) continue;
      if (dedup.containsKey(base)) {
        dedup[base] =
            dedup[base]!.copyWith(quantity: dedup[base]!.quantity + qty);
      } else {
        dedup[base] = _ParsedItem(original: line, base: base, quantity: qty);
      }
    }
    return dedup.values.toList();
  }

  String _normalize(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  Set<String> _tokens(String s) {
    const stop = {
      'the',
      'a',
      'an',
      'and',
      'or',
      'of',
      'for',
      'to',
      'with',
      'by',
      'on',
      'in',
      'at',
      'is',
      'are',
      'pack',
      'pcs',
      'piece',
      'pieces'
    };
    return _normalize(s)
        .split(' ')
        .where((t) => t.isNotEmpty && !stop.contains(t))
        .toSet();
  }

  Set<String> _significantTokens(Set<String> tokens) =>
      tokens.where((t) => t.length >= 3).toSet();

  bool _textContainsAny(String text, Set<String> tokens) {
    if (tokens.isEmpty) return false;
    final n = _normalize(text);
    for (final t in tokens) {
      if (n.contains(t)) return true;
    }
    return false;
  }

  bool _productContainsAny(Product p, Set<String> tokens) {
    if (tokens.isEmpty) return false;
    return _textContainsAny(p.name ?? '', tokens) ||
        _textContainsAny(p.proBrandId?.name ?? '', tokens) ||
        _textContainsAny(p.proCategoryId?.name ?? '', tokens) ||
        _textContainsAny(p.proSubCategoryId?.name ?? '', tokens);
  }

  // --- Fuzzy similarity ---
  double _jaccard(Set<String> a, Set<String> b) {
    if (a.isEmpty || b.isEmpty) return 0;
    final inter = a.intersection(b).length;
    final union = a.union(b).length;
    return inter / union;
  }

  int _lev(String a, String b) {
    // simple iterative DP
    final la = a.length, lb = b.length;
    if (la == 0) return lb;
    if (lb == 0) return la;
    final prev = List<int>.generate(lb + 1, (i) => i);
    final curr = List<int>.filled(lb + 1, 0);
    for (int i = 1; i <= la; i++) {
      curr[0] = i;
      for (int j = 1; j <= lb; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        curr[j] = [
          prev[j] + 1,
          curr[j - 1] + 1,
          prev[j - 1] + cost,
        ].reduce((v, e) => v < e ? v : e);
      }
      for (int j = 0; j <= lb; j++) {
        prev[j] = curr[j];
      }
    }
    return prev[lb];
  }

  double _ratio(String a, String b) {
    if (a.isEmpty || b.isEmpty) return 0;
    final d = _lev(a, b).toDouble();
    return 1.0 - d / (a.length > b.length ? a.length : b.length);
  }

  double _scoreProduct(String query, Set<String> qTokens, Product p) {
    final name = p.name ?? '';
    final brand = p.proBrandId?.name ?? '';
    final cat = p.proCategoryId?.name ?? '';
    final sub = p.proSubCategoryId?.name ?? '';
    final text = [name, brand, cat, sub].where((e) => e.isNotEmpty).join(' ');
    final tTokens = _tokens(text);
    final nameScore = _ratio(_normalize(query), _normalize(name));
    final tokenScore = _jaccard(qTokens, tTokens);
    double score = 0.75 * nameScore + 0.25 * tokenScore;
    // Boost if the full phrase appears in the product name (common case like "milk").
    if (_normalize(name).contains(_normalize(query))) score += 0.2;
    if (brand.isNotEmpty && qTokens.contains(_normalize(brand))) score += 0.05;
    if (cat.isNotEmpty && qTokens.contains(_normalize(cat))) score += 0.05;
    if (sub.isNotEmpty && qTokens.contains(_normalize(sub))) score += 0.03;
    return score.clamp(0.0, 1.0);
  }

  Future<void> _findBestPrices() async {
    setState(() => _searching = true);
    final data = context.read<DataProvider>();
    final products = data.allProducts;

    final parsed = _parseInput(_listController.text);

    final results = <String, _MatchResult>{};
    for (final item in parsed) {
      final qTokens = _tokens(item.base);
      final sig = _significantTokens(qTokens);
      // Prefer a filtered pool that actually contains the significant query tokens.
      final pool = products
          .where((p) => _productContainsAny(p, sig))
          .toList(growable: false);

      List<({Product p, double score})> filterByThreshold(
              List<Product> base, double t) =>
          base
              .map((p) => (p: p, score: _scoreProduct(item.base, qTokens, p)))
              .where((e) => e.score >= t)
              .toList();

      // Adaptive thresholds: try stricter first, then relax.
      final thresholds = <double>[0.55, 0.45, 0.35, 0.25, 0.15];
      List<({Product p, double score})> scored = [];
      final baseList = pool.isNotEmpty ? pool : products;
      for (final t in thresholds) {
        scored = filterByThreshold(baseList, t);
        if (scored.isNotEmpty) break;
      }

      // Fallback: still empty → take top 5 closest by score
      if (scored.isEmpty) {
        scored = baseList
            .map((p) => (p: p, score: _scoreProduct(item.base, qTokens, p)))
            .toList();
      }

      // Sort by higher score then by lower price
      scored.sort((a, b) {
        final c = b.score.compareTo(a.score);
        if (c != 0) return c;
        return _effectivePrice(a.p).compareTo(_effectivePrice(b.p));
      });

      final topList = scored.take(8).toList();
      results[item.base] = _MatchResult(
        query: item.base,
        product: topList.isEmpty ? null : topList.first.p,
        quantity: item.quantity,
        alternatives: topList.map((e) => e.p).toList(),
      );
      _chosen[item.base] = topList.isEmpty ? null : topList.first.p;
    }

    setState(() {
      _matches
        ..clear()
        ..addAll(results);
      _searching = false;
    });
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text == null || data!.text!.trim().isEmpty) return;
    setState(() {
      if (_listController.text.trim().isEmpty) {
        _listController.text = data.text!.trim();
      } else {
        _listController.text =
            (_listController.text.trim() + '\n' + data.text!.trim());
      }
    });
  }

  void _clearAll() {
    setState(() {
      _listController.clear();
      _matches.clear();
      _chosen.clear();
    });
  }

  void _addAllToFavorites() {
    final fav = context.read<FavoriteProvider>();
    int count = 0;
    for (final m in _matches.values) {
      final id = (_chosen[m.query] ?? m.product)?.sId;
      if (id != null) {
        fav.updateToFavoriteList(id);
        count++;
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added $count items to Favorites')),
    );
  }

  void _addAllToCart() {
    final cart = context.read<CartProvider>();
    int count = 0;
    for (final m in _matches.values) {
      final p = _chosen[m.query] ?? m.product;
      if (p != null) {
        cart.addProductToCart(p, quantity: m.quantity);
        count++;
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added $count items to Cart')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan / Build Shopping List'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _listController,
                          maxLines: 5,
                          minLines: 3,
                          decoration: InputDecoration(
                            hintText:
                                'Paste or type items (one per line)\nExample: milk\nwatch\nbottle',
                            filled: true,
                            fillColor: const Color(0xFFF8F9FA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.15)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Tooltip(
                        message: 'Paste from clipboard',
                        child: IconButton(
                          onPressed: _pasteFromClipboard,
                          icon: const Icon(Icons.paste_rounded),
                        ),
                      ),
                      Tooltip(
                        message: 'Clear input',
                        child: IconButton(
                          onPressed: _clearAll,
                          icon: const Icon(Icons.clear_rounded),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Removed match mode chips; adaptive threshold is used automatically.
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _searching ? null : _findBestPrices,
                      icon: const Icon(Icons.search_rounded),
                      label: Text(_searching
                          ? 'Finding best prices...'
                          : 'Find Best Prices'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _matches.isEmpty
                  ? const _EmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      itemBuilder: (context, i) {
                        final entry = _matches.values.elementAt(i);
                        return _ReviewTile(
                          result: entry,
                          chosen: _chosen[entry.query],
                          onChoose: (p) =>
                              setState(() => _chosen[entry.query] = p),
                          onQuantityChanged: (q) =>
                              setState(() => entry.quantity = q),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemCount: _matches.length,
                    ),
            ),
            if (_matches.isNotEmpty)
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SummaryBar(
                          matches: _matches,
                          chosen: _chosen,
                          priceOf: _effectivePrice),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _addAllToFavorites,
                              icon: Icon(Icons.favorite_rounded,
                                  color: Theme.of(context).colorScheme.primary),
                              label: const Text('Add all to Favorites'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.primary,
                                side: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _addAllToCart,
                              icon: const Icon(Icons.shopping_bag_rounded),
                              label: const Text('Add all to Cart'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                foregroundColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// _ResultTile replaced by _ReviewTile to support multiple choices

class _ReviewTile extends StatelessWidget {
  final _MatchResult result;
  final Product? chosen;
  final ValueChanged<Product?> onChoose;
  final ValueChanged<int> onQuantityChanged;

  const _ReviewTile({
    required this.result,
    required this.chosen,
    required this.onChoose,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final p = chosen ?? result.product;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  result.query,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              _QtyStepper(
                value: result.quantity,
                onChanged: onQuantityChanged,
                enabled: p != null,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (result.alternatives.isEmpty)
            Text('No match found',
                style: TextStyle(color: Colors.grey.shade600))
          else
            Column(
              children: result.alternatives.take(5).map((alt) {
                final isSel = alt.sId == p?.sId;
                final altPrice =
                    (alt.offerPrice ?? alt.price ?? 0).toStringAsFixed(2);
                return InkWell(
                  onTap: () => onChoose(alt),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFFEEF0FF) : null,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: alt.images?.isNotEmpty == true
                                ? Image.network(alt.images!.first.url ?? '',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.image_outlined))
                                : const Icon(Icons.image_outlined),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            alt.name ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '₹$altPrice',
                          style: const TextStyle(
                            color: Color(0xFF667eea),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (isSel)
                          const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Icon(Icons.check_circle,
                                color: Color(0xFF667eea), size: 18),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final bool enabled;
  const _QtyStepper(
      {required this.value, required this.onChanged, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SquareBtn(
          icon: Icons.remove,
          onTap: enabled && value > 1 ? () => onChanged(value - 1) : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text('$value',
              style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
        _SquareBtn(
          icon: Icons.add,
          onTap: enabled ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }
}

class _SquareBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _SquareBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: onTap == null
              ? theme.disabledColor.withOpacity(0.1)
              : theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon,
            size: 18,
            color: onTap == null
                ? theme.disabledColor
                : theme.colorScheme.primary),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_cart_checkout_rounded,
                size: 56, color: Color(0xFF667eea)),
            const SizedBox(height: 12),
            const Text(
              'Build your list',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Paste items one per line or use the camera.\nWe\'ll pick the best price for you.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            )
          ],
        ),
      ),
    );
  }
}

class _MatchResult {
  final String query;
  Product? product;
  int quantity;
  final List<Product> alternatives;
  _MatchResult({
    required this.query,
    required this.product,
    this.quantity = 1,
    this.alternatives = const [],
  });
}

class _ParsedItem {
  final String original;
  final String base;
  final int quantity;
  const _ParsedItem(
      {required this.original, required this.base, required this.quantity});
  _ParsedItem copyWith({String? original, String? base, int? quantity}) =>
      _ParsedItem(
        original: original ?? this.original,
        base: base ?? this.base,
        quantity: quantity ?? this.quantity,
      );
}

class _SummaryBar extends StatelessWidget {
  final Map<String, _MatchResult> matches;
  final Map<String, Product?> chosen;
  final double Function(Product) priceOf;
  const _SummaryBar(
      {required this.matches, required this.chosen, required this.priceOf});

  @override
  Widget build(BuildContext context) {
    int items = 0;
    double total = 0;
    for (final m in matches.values) {
      final p = chosen[m.query] ?? m.product;
      if (p != null) {
        items += m.quantity;
        total += priceOf(p) * m.quantity;
      }
    }
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.summarize_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$items total item(s) • Est. ₹${total.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Tooltip(
            message: 'Copy chosen list',
            child: IconButton(
              icon: const Icon(Icons.copy_all_rounded),
              onPressed: () async {
                final lines = matches.values.map((m) {
                  final p = chosen[m.query] ?? m.product;
                  final qty = m.quantity;
                  final name = p?.name ?? m.query;
                  return '${qty}x $name';
                }).join('\n');
                await Clipboard.setData(ClipboardData(text: lines));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chosen items copied')),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class HorizontalList<T> extends StatelessWidget {
  final List<T>? items;
  final T selected;
  final String Function(T) itemToString;
  final void Function(T) onSelect;
  final bool dense;

  const HorizontalList(
      {super.key,
      this.items,
      required this.itemToString,
      required this.selected,
      required this.onSelect,
      this.dense = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final double listHeight = dense ? 40 : 50;
    final EdgeInsets chipPadding = dense
        ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    final TextStyle labelStyle = TextStyle(
      fontSize: dense ? 12.5 : 14,
      fontWeight: FontWeight.w500,
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: dense ? 6.0 : 10.0),
      child: SizedBox(
        height: listHeight,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: items?.length ?? 0,
          itemBuilder: (context, index) {
            T item = items![index];
            final isSelected = selected == item;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: dense ? 6 : 8),
              child: ChoiceChip(
                label: Text(
                  itemToString(item),
                  style: labelStyle.copyWith(
                    color: isSelected ? Colors.white : colorScheme.onSurface,
                  ),
                ),
                selected: isSelected,
                onSelected: (bool selected) {
                  onSelect(item);
                },
                padding: chipPadding,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: isDark
                    ? colorScheme.surface.withOpacity(0.8)
                    : colorScheme.surfaceVariant,
                selectedColor: colorScheme.primary,
                showCheckmark: false,
                side: BorderSide(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.outline.withOpacity(0.5),
                  width: 1,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

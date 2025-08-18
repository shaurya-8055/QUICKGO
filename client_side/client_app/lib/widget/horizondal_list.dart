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
    final double listHeight = dense ? 40 : 50;
    final EdgeInsets chipPadding = dense
        ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    final TextStyle labelStyle = TextStyle(fontSize: dense ? 12.5 : 14);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: dense ? 6.0 : 10.0),
      child: SizedBox(
        height: listHeight,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: items?.length ?? 0,
          itemBuilder: (context, index) {
            T item = items![index];
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: dense ? 6 : 8),
              child: ChoiceChip(
                label: Text(itemToString(item), style: labelStyle),
                selected: selected == item,
                onSelected: (bool selected) {
                  onSelect(item);
                },
                padding: chipPadding,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: Colors.grey[200],
                selectedColor: Colors.orangeAccent,
                showCheckmark: false,
              ),
            );
          },
        ),
      ),
    );
  }
}

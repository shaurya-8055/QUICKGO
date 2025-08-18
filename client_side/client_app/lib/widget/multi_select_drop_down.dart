import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

import '../utility/app_color.dart';

class MultiSelectDropDown<T> extends StatelessWidget {
  final String? hintText;
  final List<T> items;
  final Function(List<T>) onSelectionChanged;
  final String Function(T) displayItem;
  final List<T> selectedItems;
  // Use compact layout
  final bool dense;

  const MultiSelectDropDown({
    super.key,
    required this.items,
    required this.onSelectionChanged,
    required this.displayItem,
    required this.selectedItems,
    this.hintText = 'Select Items',
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: dense ? EdgeInsets.zero : null,
      elevation: dense ? 0 : null,
      child: Center(
        child: DropdownButtonHideUnderline(
          child: DropdownButton2<T>(
            isExpanded: true,
            hint: Text(
              '$hintText',
              style: TextStyle(
                fontSize: dense ? 13 : 14,
                color: Theme.of(context).hintColor,
              ),
            ),
            items: items.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                // Disable default onTap to avoid closing menu when selecting an item
                enabled: false,
                child: StatefulBuilder(
                  builder: (context, menuSetState) {
                    final isSelected = selectedItems.contains(item);
                    return InkWell(
                      onTap: () {
                        isSelected
                            ? selectedItems.remove(item)
                            : selectedItems.add(item);
                        onSelectionChanged(selectedItems);
                        menuSetState(() {});
                      },
                      child: Container(
                        height: double.infinity,
                        padding: dense
                            ? const EdgeInsets.symmetric(horizontal: 12.0)
                            : const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            if (isSelected)
                              const Icon(Icons.check_box_outlined)
                            else
                              const Icon(Icons.check_box_outline_blank),
                            SizedBox(width: dense ? 12 : 16),
                            Expanded(
                              child: Text(
                                displayItem(item),
                                style: TextStyle(fontSize: dense ? 13 : 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
            // Use last selected item as the current value so if we've limited menu height, it scrolls to the last item.
            value: selectedItems.isEmpty ? null : selectedItems.last,
            onChanged: (value) {},
            selectedItemBuilder: (context) {
              return items.map(
                (item) {
                  return Container(
                    alignment: AlignmentDirectional.center,
                    child: Text(
                      selectedItems.map(displayItem).join(', '),
                      style: TextStyle(
                          fontSize: dense ? 13 : 14,
                          overflow: TextOverflow.ellipsis),
                      maxLines: 1,
                    ),
                  );
                },
              ).toList();
            },
            buttonStyleData: ButtonStyleData(
              padding: dense
                  ? const EdgeInsets.only(left: 12, right: 8)
                  : const EdgeInsets.only(left: 16, right: 8),
              height: dense ? 40 : 50,
              decoration: BoxDecoration(
                color: AppColor.lightGrey,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            menuItemStyleData: MenuItemStyleData(
              height: dense ? 36 : 40,
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
    );
  }
}

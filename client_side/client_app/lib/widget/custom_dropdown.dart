import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T? initialValue;
  final Color? bgColor;
  final List<T> items;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;
  final String hintText;
  final String Function(T) displayItem;
  // When true, uses a denser layout with smaller height/paddings.
  final bool dense;
  final double? height;
  final EdgeInsetsGeometry? buttonPadding;

  const CustomDropdown({
    super.key,
    this.initialValue,
    required this.items,
    required this.onChanged,
    this.validator,
    this.hintText = 'Select an option',
    required this.displayItem,
    this.bgColor,
    this.dense = false,
    this.height,
    this.buttonPadding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final double resolvedHeight = height ?? (dense ? 40 : 50);
    final EdgeInsetsGeometry resolvedPadding = buttonPadding ??
        (dense
            ? const EdgeInsets.only(left: 12, right: 8)
            : const EdgeInsets.only(left: 16, right: 8));

    return Card(
      margin: dense ? EdgeInsets.zero : null,
      elevation: dense ? 0 : null,
      color: isDark ? colorScheme.surface : null,
      child: Center(
        child: DropdownButtonHideUnderline(
          child: DropdownButton2<T>(
            isExpanded: true,
            hint: Text(
              hintText,
              style: TextStyle(
                fontSize: dense ? 13 : 14,
                color: colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            items: items.map((T value) {
              return DropdownMenuItem<T>(
                value: value,
                child: Container(
                  height: double.infinity,
                  padding: dense
                      ? const EdgeInsets.symmetric(horizontal: 12.0)
                      : const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    displayItem(value),
                    style: TextStyle(
                      fontSize: dense ? 13 : 14,
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
            value: initialValue,
            onChanged: onChanged,
            buttonStyleData: ButtonStyleData(
              padding: resolvedPadding,
              height: resolvedHeight,
              decoration: BoxDecoration(
                color: bgColor ??
                    (isDark
                        ? colorScheme.surface.withOpacity(0.8)
                        : colorScheme.surfaceVariant),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.5),
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            menuItemStyleData: MenuItemStyleData(
              height: dense ? 36 : 40,
              padding: EdgeInsets.zero,
            ),
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.5),
                ),
              ),
            ),
            iconStyleData: IconStyleData(
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Represents a cell in the grouped table header
class GroupedTableCell {
  /// The text content of the cell
  final String text;

  /// Number of columns this cell spans (default: 1)
  final int colSpan;

  /// Number of rows this cell spans (default: 1)
  final int rowSpan;

  /// Background color of the cell
  final Color? backgroundColor;

  /// Text style of the cell
  final TextStyle? textStyle;

  /// Alignment of the cell content
  final Alignment alignment;

  /// Custom widget builder (if provided, text will be ignored)
  final Widget Function(BuildContext context)? builder;

  /// Border configuration
  final Border? border;

  /// Height of the cell
  final double? height;

  /// Child cells (for nested headers)
  final List<GroupedTableCell>? children;

  const GroupedTableCell({
    required this.text,
    this.colSpan = 1,
    this.rowSpan = 1,
    this.backgroundColor,
    this.textStyle,
    this.alignment = Alignment.center,
    this.builder,
    this.border,
    this.height,
    this.children,
  });

  /// Creates a simple cell with text
  factory GroupedTableCell.simple(String text) {
    return GroupedTableCell(text: text);
  }

  /// Creates a merged cell spanning multiple columns
  factory GroupedTableCell.merged({
    required String text,
    required int colSpan,
    int rowSpan = 1,
    Color? backgroundColor,
    TextStyle? textStyle,
  }) {
    return GroupedTableCell(
      text: text,
      colSpan: colSpan,
      rowSpan: rowSpan,
      backgroundColor: backgroundColor,
      textStyle: textStyle,
    );
  }

  /// Creates a cell with nested children (for grouped headers)
  factory GroupedTableCell.grouped({
    required String text,
    required List<GroupedTableCell> children,
    Color? backgroundColor,
    TextStyle? textStyle,
  }) {
    return GroupedTableCell(
      text: text,
      children: children,
      backgroundColor: backgroundColor,
      textStyle: textStyle,
    );
  }
}

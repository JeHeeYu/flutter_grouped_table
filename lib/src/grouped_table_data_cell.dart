import 'package:flutter/material.dart';

/// Represents a data cell in the grouped table
class GroupedTableDataCell {
  /// The widget content of the cell
  final Widget child;

  /// Number of columns this cell spans (default: 1)
  final int colSpan;

  /// Number of rows this cell spans (default: 1)
  final int rowSpan;

  /// Background color of the cell
  final Color? backgroundColor;

  /// Text style of the cell (applied if child is Text)
  final TextStyle? textStyle;

  /// Alignment of the cell content
  final Alignment alignment;

  /// Border configuration
  final Border? border;

  /// Height of the cell (optional, defaults to rowHeight)
  final double? height;

  const GroupedTableDataCell({
    required this.child,
    this.colSpan = 1,
    this.rowSpan = 1,
    this.backgroundColor,
    this.textStyle,
    this.alignment = Alignment.center,
    this.border,
    this.height,
  });

  /// Creates a simple data cell with text
  factory GroupedTableDataCell.text(
    String text, {
    int colSpan = 1,
    int rowSpan = 1,
    Color? backgroundColor,
    TextStyle? textStyle,
    Alignment alignment = Alignment.center,
  }) {
    return GroupedTableDataCell(
      child: Text(text),
      colSpan: colSpan,
      rowSpan: rowSpan,
      backgroundColor: backgroundColor,
      textStyle: textStyle,
      alignment: alignment,
    );
  }

  /// Creates a merged cell spanning multiple columns
  factory GroupedTableDataCell.merged({
    required Widget child,
    required int colSpan,
    int rowSpan = 1,
    Color? backgroundColor,
    TextStyle? textStyle,
    Alignment alignment = Alignment.center,
  }) {
    return GroupedTableDataCell(
      child: child,
      colSpan: colSpan,
      rowSpan: rowSpan,
      backgroundColor: backgroundColor,
      textStyle: textStyle,
      alignment: alignment,
    );
  }

  /// Creates a cell with row span
  factory GroupedTableDataCell.rowSpan({
    required Widget child,
    required int rowSpan,
    Color? backgroundColor,
    TextStyle? textStyle,
    Alignment alignment = Alignment.center,
  }) {
    return GroupedTableDataCell(
      child: child,
      rowSpan: rowSpan,
      backgroundColor: backgroundColor,
      textStyle: textStyle,
      alignment: alignment,
    );
  }
}

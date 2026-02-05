import 'package:flutter/material.dart';

/// Helper class to represent cell data with optional row span
class TableCellData {
  /// The cell value (String, Widget, or null for empty/merged cells)
  final dynamic value;

  /// Number of rows this cell spans (default: 1)
  final int rowSpan;

  /// Number of columns this cell spans (default: 1)
  final int colSpan;

  /// Background color of the cell
  final Color? backgroundColor;

  /// Text style of the cell
  final TextStyle? textStyle;

  /// Alignment of the cell content
  final Alignment alignment;

  const TableCellData({
    this.value,
    this.rowSpan = 1,
    this.colSpan = 1,
    this.backgroundColor,
    this.textStyle,
    this.alignment = Alignment.center,
  });

  /// Creates a simple text cell
  factory TableCellData.text(String text) {
    return TableCellData(value: text);
  }

  /// Creates a cell with row span
  factory TableCellData.rowSpan(dynamic value, int rowSpan) {
    return TableCellData(value: value, rowSpan: rowSpan);
  }

  /// Creates an empty cell (for merged cells in subsequent rows)
  factory TableCellData.empty() {
    return const TableCellData(value: null);
  }
}

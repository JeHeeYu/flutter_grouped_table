import 'package:flutter/material.dart';
import 'grouped_table_cell.dart';
import 'grouped_table_data_cell.dart';
import 'table_cell_data.dart';

/// A table widget that supports merged cells and grouped headers
class GroupedTable extends StatelessWidget {
  /// Header rows configuration
  final List<List<GroupedTableCell>> headerRows;

  /// Data rows
  final List<List<GroupedTableDataCell>> dataRows;

  /// Flex weights for columns (optional, for responsive sizing)
  final List<int>? columnFlexWeights;

  /// Border color
  final Color borderColor;

  /// Border width
  final double borderWidth;

  /// Border radius for the table
  final BorderRadius? borderRadius;

  /// Background color for header cells
  final Color? headerBackgroundColor;

  /// Background color for data cells
  final Color? dataBackgroundColor;

  /// Default text style for headers
  final TextStyle? headerTextStyle;

  /// Default text style for data cells
  final TextStyle? dataTextStyle;

  /// Default header cell height
  final double? defaultHeaderHeight;

  /// Default data row height
  final double rowHeight;

  /// Spacing between rows (vertical spacing)
  final double rowSpacing;

  const GroupedTable({
    super.key,
    required this.headerRows,
    required this.dataRows,
    this.columnFlexWeights,
    this.borderColor = Colors.black,
    this.borderWidth = 1.0,
    this.borderRadius,
    this.headerBackgroundColor,
    this.dataBackgroundColor,
    this.headerTextStyle,
    this.dataTextStyle,
    this.defaultHeaderHeight,
    this.rowHeight = 40.0,
    this.rowSpacing = 0,
  });

  /// Creates a table from simple data (List<List<dynamic>>)
  /// 
  /// For grouped headers, use a Map with 'text' and 'children' keys:
  /// ```dart
  /// headerRows: [
  ///   [
  ///     'Product',
  ///     'Category',
  ///     {'text': 'Sales', 'children': ['Q1', 'Q2', 'Q3', 'Q4']}
  ///   ]
  /// ]
  /// ```
  /// 
  /// Example:
  /// ```dart
  /// GroupedTable.fromSimpleData(
  ///   headerRows: [
  ///     ['Product', 'Category', {'text': 'Sales', 'children': ['Q1', 'Q2', 'Q3', 'Q4']}]
  ///   ],
  ///   dataRows: [
  ///     ['Laptop', 'Electronics', '120', '150', '180', '200'],
  ///     ['Smartphone', null, '250', '280', '300', '320'], // null = merged from previous row
  ///   ],
  ///   rowSpanMap: {0: {1: 3}}, // rowIndex: {colIndex: rowSpan}
  /// )
  /// ```
  factory GroupedTable.fromSimpleData({
    Key? key,
    required List<List<dynamic>> headerRows,
    required List<List<dynamic>> dataRows,
    Map<int, Map<int, int>>? rowSpanMap,
    List<int>? columnFlexWeights,
    Color borderColor = Colors.black,
    double borderWidth = 1.0,
    BorderRadius? borderRadius,
    Color? headerBackgroundColor,
    Color? dataBackgroundColor,
    TextStyle? headerTextStyle,
    TextStyle? dataTextStyle,
    double? defaultHeaderHeight,
    double rowHeight = 40.0,
    double rowSpacing = 0,
  }) {
    final processedHeaderRows = <List<GroupedTableCell>>[];
    for (final row in headerRows) {
      final processedRow = <GroupedTableCell>[];
      for (final cell in row) {
        if (cell is String) {
          processedRow.add(GroupedTableCell.simple(cell));
        } else if (cell is Map) {
          final text = cell['text'] as String?;
          final children = cell['children'] as List<dynamic>?;
          if (text != null && children != null) {
            processedRow.add(
              GroupedTableCell.grouped(
                text: text,
                children: children
                    .map((c) => GroupedTableCell.simple(c.toString()))
                    .toList(),
              ),
            );
          } else if (text != null) {
            processedRow.add(GroupedTableCell.simple(text));
          }
        }
      }
      processedHeaderRows.add(processedRow);
    }

    final processedDataRows = <List<GroupedTableDataCell>>[];
    for (int rowIndex = 0; rowIndex < dataRows.length; rowIndex++) {
      final row = dataRows[rowIndex];
      final processedRow = <GroupedTableDataCell>[];
      
      for (int colIndex = 0; colIndex < row.length; colIndex++) {
        final value = row[colIndex];
        
        if (value == null) {
          continue;
        }
        
        final rowSpan = rowSpanMap?[rowIndex]?[colIndex] ?? 1;
        
        if (value is String) {
          processedRow.add(
            rowSpan > 1
                ? GroupedTableDataCell.rowSpan(
                    child: Text(value),
                    rowSpan: rowSpan,
                    textStyle: dataTextStyle,
                  )
                : GroupedTableDataCell.text(
                    value,
                    textStyle: dataTextStyle,
                  ),
          );
        } else if (value is Widget) {
          processedRow.add(
            rowSpan > 1
                ? GroupedTableDataCell.rowSpan(
                    child: value,
                    rowSpan: rowSpan,
                    textStyle: dataTextStyle,
                  )
                : GroupedTableDataCell(child: value, textStyle: dataTextStyle),
          );
        } else if (value is TableCellData) {
          Widget child;
          if (value.value is String) {
            child = Text(value.value as String);
          } else if (value.value is Widget) {
            child = value.value as Widget;
          } else {
            continue;
          }
          
          processedRow.add(
            GroupedTableDataCell(
              child: child,
              rowSpan: value.rowSpan,
              colSpan: value.colSpan,
              backgroundColor: value.backgroundColor,
              textStyle: value.textStyle ?? dataTextStyle,
              alignment: value.alignment,
            ),
          );
        }
      }
      
      processedDataRows.add(processedRow);
    }

    return GroupedTable(
      key: key,
      headerRows: processedHeaderRows,
      dataRows: processedDataRows,
      columnFlexWeights: columnFlexWeights,
      borderColor: borderColor,
      borderWidth: borderWidth,
      borderRadius: borderRadius,
      headerBackgroundColor: headerBackgroundColor,
      dataBackgroundColor: dataBackgroundColor,
      headerTextStyle: headerTextStyle,
      dataTextStyle: dataTextStyle,
      defaultHeaderHeight: defaultHeaderHeight,
      rowHeight: rowHeight,
      rowSpacing: rowSpacing,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.zero;

    return Container(
      decoration: BoxDecoration(
        borderRadius: effectiveBorderRadius,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            _buildDataRows(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final processedHeaderRows = _processGroupedHeaders();
    return Column(
      children: [
        for (int rowIndex = 0; rowIndex < processedHeaderRows.length; rowIndex++)
          _buildHeaderRow(context, processedHeaderRows[rowIndex], rowIndex),
      ],
    );
  }

  List<List<GroupedTableCell>> _processGroupedHeaders() {
    if (headerRows.isEmpty) return [];

    final List<List<GroupedTableCell>> processed = [];
    bool hasGroupedCells = false;

    for (final row in headerRows) {
      for (final cell in row) {
        if (cell.children != null && cell.children!.isNotEmpty) {
          hasGroupedCells = true;
          break;
        }
      }
      if (hasGroupedCells) break;
    }

    if (!hasGroupedCells) {
      return headerRows;
    }

    final firstRow = headerRows[0];
    final List<GroupedTableCell> firstProcessedRow = [];
    final List<GroupedTableCell> secondRow = [];

    for (final cell in firstRow) {
      if (cell.children != null && cell.children!.isNotEmpty) {
        firstProcessedRow.add(cell.copyWith(children: null, colSpan: cell.children!.length));
        secondRow.addAll(cell.children!);
      } else {
        firstProcessedRow.add(cell);
        secondRow.add(GroupedTableCell.simple(''));
      }
    }

    processed.add(firstProcessedRow);
    processed.add(secondRow);

    return processed;
  }

  Widget _buildHeaderRow(
    BuildContext context,
    List<GroupedTableCell> cells,
    int rowIndex,
  ) {
    final processedRows = _processGroupedHeaders();
    final isLastHeaderRow = rowIndex == processedRows.length - 1;

    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildHeaderCells(context, cells, rowIndex, isLastHeaderRow),
      ),
    );
  }

  List<Widget> _buildHeaderCells(
    BuildContext context,
    List<GroupedTableCell> cells,
    int rowIndex,
    bool isLastHeaderRow,
  ) {
    List<Widget> widgets = [];
    int currentColumn = 0;

    for (final cell in cells) {
      int actualColSpan = _calculateActualColSpan(cell);

      int flex;
      if (columnFlexWeights != null && currentColumn < columnFlexWeights!.length) {
        if (actualColSpan > 1) {
          int sumFlex = 0;
          for (int i = 0; i < actualColSpan && (currentColumn + i) < columnFlexWeights!.length; i++) {
            sumFlex += columnFlexWeights![currentColumn + i];
          }
          flex = sumFlex > 0 ? sumFlex : actualColSpan;
        } else {
          flex = columnFlexWeights![currentColumn];
        }
      } else {
        flex = actualColSpan;
      }

      widgets.add(
        Expanded(
          flex: flex,
          child: _buildCell(context, cell, rowIndex, isLastHeaderRow),
        ),
      );

      currentColumn += actualColSpan;
    }

    return widgets;
  }

  Widget _buildCell(
    BuildContext context,
    GroupedTableCell cell,
    int rowIndex,
    bool isLastHeaderRow,
  ) {
    final height = cell.height ?? defaultHeaderHeight ?? 40.0;
    final bgColor = cell.backgroundColor ?? headerBackgroundColor ?? Colors.black;

    Widget content;
    if (cell.builder != null) {
      content = cell.builder!(context);
    } else {
      content = Text(
        cell.text,
        style: cell.textStyle ??
            headerTextStyle ??
            const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    Border? cellBorder;
    if (cell.border != null) {
      cellBorder = cell.border;
    } else {
      if (isLastHeaderRow) {
        cellBorder = Border(
          right: BorderSide(color: borderColor, width: borderWidth),
        );
      } else {
        cellBorder = Border(
          right: BorderSide(color: borderColor, width: borderWidth),
          bottom: BorderSide(color: borderColor, width: borderWidth),
        );
      }
    }

    return Container(
      height: height,
      alignment: cell.alignment,
      decoration: BoxDecoration(
        color: bgColor,
        border: cellBorder,
      ),
      child: content,
    );
  }

  Widget _buildDataRows(BuildContext context) {
    if (dataRows.isEmpty) return const SizedBox.shrink();

    final totalColumns = _calculateDataColumns();
    final Map<int, Map<int, int>> rowSpanMap = {};
    final Map<int, Set<int>> skipCells = {};

    for (int rowIndex = 0; rowIndex < dataRows.length; rowIndex++) {
      final row = dataRows[rowIndex];
      int colIndex = 0;

      for (final cell in row) {
        while (skipCells[rowIndex]?.contains(colIndex) == true) {
          colIndex++;
        }

        if (cell.rowSpan > 1) {
          rowSpanMap[rowIndex] ??= {};
          rowSpanMap[rowIndex]![colIndex] = cell.rowSpan;

          for (int nextRow = rowIndex + 1;
              nextRow < rowIndex + cell.rowSpan && nextRow < dataRows.length;
              nextRow++) {
            skipCells[nextRow] ??= {};
            for (int spanCol = colIndex; spanCol < colIndex + cell.colSpan; spanCol++) {
              skipCells[nextRow]!.add(spanCol);
            }
          }
        }

        colIndex += cell.colSpan;
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = constraints.maxWidth;
        final flexWeights = columnFlexWeights ??
            List.generate(totalColumns, (_) => 1);
        final totalFlex = flexWeights.fold(0, (sum, w) => sum + w);

        Map<String, Rect> rowSpanPositions = {};
        double currentTop = 0;

        for (int rowIndex = 0; rowIndex < dataRows.length; rowIndex++) {
          final row = dataRows[rowIndex];
          double currentLeft = 0;
          int colIndex = 0;

          for (final cell in row) {
            while (skipCells[rowIndex]?.contains(colIndex) == true) {
              final colWidth = (flexWeights[colIndex] / totalFlex) * tableWidth;
              currentLeft += colWidth;
              colIndex++;
            }

            if (cell.rowSpan > 1) {
              final colWidth = (flexWeights[colIndex] / totalFlex) * tableWidth * cell.colSpan;
              rowSpanPositions['$rowIndex-$colIndex'] = Rect.fromLTWH(
                currentLeft,
                currentTop,
                colWidth,
                rowHeight * cell.rowSpan + (rowSpacing * (cell.rowSpan - 1)),
              );
            }

            currentLeft += (flexWeights[colIndex] / totalFlex) * tableWidth * cell.colSpan;
            colIndex += cell.colSpan;
          }

          currentTop += rowHeight + (rowIndex > 0 ? rowSpacing : 0);
        }


        return Stack(
          children: [
            Column(
              children: [
                for (int i = 0; i < dataRows.length; i++)
                  Padding(
                    padding: EdgeInsets.only(top: i > 0 ? rowSpacing : 0),
                    child: SizedBox(
                      height: rowHeight,
                      child: ClipRect(
                        child: _buildDataRow(context, dataRows[i], i, skipCells[i] ?? {}, flexWeights, totalFlex, tableWidth),
                      ),
                    ),
                  ),
              ],
            ),
            ...rowSpanPositions.entries.map((entry) {
              final parts = entry.key.split('-');
              final rowIndex = int.parse(parts[0]);
              final colIndex = int.parse(parts[1]);
              final rect = entry.value;
              final cell = _getCellAtPosition(rowIndex, colIndex);
              if (cell == null) return const SizedBox.shrink();

              final rowSpan = rowSpanMap[rowIndex]![colIndex]!;
              final isLastRowOfSpan = rowIndex + rowSpan - 1 == dataRows.length - 1;

              final border = isLastRowOfSpan
                  ? Border(
                      right: BorderSide(color: borderColor, width: borderWidth),
                    )
                  : Border(
                      right: BorderSide(color: borderColor, width: borderWidth),
                      bottom: BorderSide(color: borderColor, width: borderWidth),
                    );

              return Positioned(
                left: rect.left,
                top: rect.top,
                width: rect.width,
                height: rect.height,
                child: Container(
                  alignment: cell.alignment,
                  decoration: BoxDecoration(
                    color: cell.backgroundColor ?? dataBackgroundColor ?? Colors.white,
                    border: border,
                  ),
                  child: ClipRect(
                    child: _buildCellContent(cell),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  GroupedTableDataCell? _getCellAtPosition(int rowIndex, int colIndex) {
    if (rowIndex < 0 || rowIndex >= dataRows.length) return null;

    final row = dataRows[rowIndex];
    int currentCol = 0;

    for (final cell in row) {
      if (colIndex >= currentCol && colIndex < currentCol + cell.colSpan) {
        return cell;
      }
      currentCol += cell.colSpan;
    }

    return null;
  }

  Widget _buildDataRow(
    BuildContext context,
    List<GroupedTableDataCell> cells,
    int rowIndex,
    Set<int> skipColumns,
    List<int> flexWeights,
    int totalFlex,
    double tableWidth,
  ) {
    final isLastRow = rowIndex == dataRows.length - 1;
    final List<Widget> rowChildren = [];
    int colIndex = 0;

    for (final cell in cells) {
      while (skipColumns.contains(colIndex)) {
        rowChildren.add(
          Expanded(
            flex: colIndex < flexWeights.length ? flexWeights[colIndex] : 1,
            child: _buildEmptyDataCell(isLastRow: isLastRow),
          ),
        );
        colIndex++;
      }

      rowChildren.add(
        Expanded(
          flex: colIndex < flexWeights.length
              ? flexWeights[colIndex] * cell.colSpan
              : cell.colSpan,
          child: cell.rowSpan > 1
              ? _buildEmptyDataCell(isLastRow: isLastRow)
              : _buildDataCell(context, cell, rowIndex, colIndex, isLastRow: isLastRow),
        ),
      );

      colIndex += cell.colSpan;
    }

    while (colIndex < flexWeights.length) {
      if (!skipColumns.contains(colIndex)) {
        rowChildren.add(
          Expanded(
            flex: flexWeights[colIndex],
            child: _buildEmptyDataCell(isLastRow: isLastRow),
          ),
        );
      }
      colIndex++;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rowChildren,
    );
  }

  Widget _buildDataCell(
    BuildContext context,
    GroupedTableDataCell cell,
    int rowIndex,
    int colIndex, {
    required bool isLastRow,
  }) {
    final border = isLastRow
        ? Border(
            right: BorderSide(color: borderColor, width: borderWidth),
          )
        : Border(
            right: BorderSide(color: borderColor, width: borderWidth),
            bottom: BorderSide(color: borderColor, width: borderWidth),
          );

    Widget content = _buildCellContent(cell);

    return Container(
      height: rowHeight,
      alignment: cell.alignment,
      decoration: BoxDecoration(
        color: cell.backgroundColor ?? dataBackgroundColor ?? Colors.white,
        border: border,
      ),
      child: content,
    );
  }

  Widget _buildCellContent(GroupedTableDataCell cell) {
    Widget content = cell.child;

    if (cell.textStyle != null && content is Text) {
      content = Text(
        content.data ?? '',
        style: cell.textStyle?.merge(content.style),
        textAlign: content.textAlign,
        maxLines: content.maxLines,
        overflow: content.overflow,
      );
    }

    return content;
  }

  Widget _buildEmptyDataCell({bool isLastRow = false}) {
    return Container(
      height: rowHeight,
      decoration: BoxDecoration(
        color: dataBackgroundColor ?? Colors.white,
        border: isLastRow
            ? Border(
                right: BorderSide(color: borderColor, width: borderWidth),
              )
            : Border(
                right: BorderSide(color: borderColor, width: borderWidth),
                bottom: BorderSide(color: borderColor, width: borderWidth),
              ),
      ),
    );
  }

  int _calculateDataColumns() {
    if (dataRows.isEmpty) return 0;

    int maxColumns = 0;
    for (final row in dataRows) {
      int rowColumns = 0;
      for (final cell in row) {
        rowColumns += cell.colSpan;
      }
      maxColumns = maxColumns > rowColumns ? maxColumns : rowColumns;
    }

    return maxColumns;
  }

  int _calculateActualColSpan(GroupedTableCell cell) {
    if (cell.children != null && cell.children!.isNotEmpty) {
      return cell.children!.length;
    }
    return cell.colSpan;
  }
}

/// Extension to help with cell copying
extension GroupedTableCellExtension on GroupedTableCell {
  GroupedTableCell copyWith({
    String? text,
    int? colSpan,
    int? rowSpan,
    Color? backgroundColor,
    TextStyle? textStyle,
    Alignment? alignment,
    Widget Function(BuildContext context)? builder,
    Border? border,
    double? height,
    List<GroupedTableCell>? children,
  }) {
    return GroupedTableCell(
      text: text ?? this.text,
      colSpan: colSpan ?? this.colSpan,
      rowSpan: rowSpan ?? this.rowSpan,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textStyle: textStyle ?? this.textStyle,
      alignment: alignment ?? this.alignment,
      builder: builder ?? this.builder,
      border: border ?? this.border,
      height: height ?? this.height,
      children: children ?? this.children,
    );
  }
}

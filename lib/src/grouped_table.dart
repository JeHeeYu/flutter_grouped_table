import 'package:flutter/material.dart';
import 'grouped_table_cell.dart';

/// A table widget that supports merged cells and grouped headers
class GroupedTable extends StatelessWidget {
  /// Header rows configuration
  final List<List<GroupedTableCell>> headerRows;

  /// Data rows
  final List<List<Widget>> dataRows;

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

  /// Spacing between rows
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
    this.rowSpacing = 0,
  });

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
            _buildDataRowsWithRowSpan(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        for (int rowIndex = 0; rowIndex < headerRows.length; rowIndex++)
          _buildHeaderRow(context, headerRows[rowIndex], rowIndex),
      ],
    );
  }

  Widget _buildHeaderRow(
    BuildContext context,
    List<GroupedTableCell> cells,
    int rowIndex,
  ) {
    int totalColumns = _calculateTotalColumns(headerRows);

    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildHeaderCells(context, cells, rowIndex, totalColumns),
      ),
    );
  }

  List<Widget> _buildHeaderCells(
    BuildContext context,
    List<GroupedTableCell> cells,
    int rowIndex,
    int totalColumns,
  ) {
    List<Widget> widgets = [];
    int currentColumn = 0;

    for (final cell in cells) {
      if (_shouldSkipCell(cell, rowIndex)) {
        continue;
      }

      if (currentColumn > 0 && rowSpacing > 0) {
        widgets.add(SizedBox(width: rowSpacing));
      }

      int actualColSpan = _calculateActualColSpan(cell, totalColumns, currentColumn);

      if (rowIndex == 0 && cell.children != null && cell.children!.isNotEmpty) {
        int groupFlex = actualColSpan;
        if (columnFlexWeights != null) {
          int sumFlex = 0;
          for (int i = 0; i < actualColSpan && (currentColumn + i) < columnFlexWeights!.length; i++) {
            sumFlex += columnFlexWeights![currentColumn + i];
          }
          if (sumFlex > 0) groupFlex = sumFlex;
        }
        widgets.add(
          Expanded(
            flex: groupFlex,
            child: _buildCell(context, cell.copyWith(children: null), rowIndex),
          ),
        );
      } else {
        widgets.add(
          Expanded(
            flex: columnFlexWeights != null && currentColumn < columnFlexWeights!.length
                ? columnFlexWeights![currentColumn]
                : actualColSpan,
            child: _buildCell(context, cell, rowIndex),
          ),
        );
      }

      currentColumn += actualColSpan;
    }

    return widgets;
  }


  Widget _buildCell(
    BuildContext context,
    GroupedTableCell cell,
    int rowIndex, {
    bool isNested = false,
  }) {
    final height = cell.height ?? defaultHeaderHeight ?? 40.0;
    final bgColor = cell.backgroundColor ??
        (isNested ? Colors.black : headerBackgroundColor ?? Colors.black);
    final isLastHeaderRow = rowIndex == headerRows.length - 1;

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

  Widget _buildDataRowsWithRowSpan(BuildContext context) {
    Map<int, Map<int, int>> rowSpanMap = {};
    Map<int, Set<int>> skipCells = {};
    Map<String, GlobalKey> cellKeys = {};
    
    for (int rowIndex = 0; rowIndex < dataRows.length; rowIndex++) {
      final row = dataRows[rowIndex];
      for (int colIndex = 0; colIndex < row.length; colIndex++) {
        cellKeys['$rowIndex-$colIndex'] = GlobalKey();
      }
    }
    
    for (int rowIndex = 0; rowIndex < dataRows.length; rowIndex++) {
      final row = dataRows[rowIndex];
      for (int colIndex = 0; colIndex < row.length; colIndex++) {
        final cell = row[colIndex];
        final cellHeight = _getCellHeight(cell);
        if (cellHeight > 40) {
          final rowSpan = (cellHeight / 40).round();
          rowSpanMap[rowIndex] ??= {};
          rowSpanMap[rowIndex]![colIndex] = rowSpan;
          
          for (int nextRow = rowIndex + 1; nextRow < rowIndex + rowSpan && nextRow < dataRows.length; nextRow++) {
            skipCells[nextRow] ??= {};
            skipCells[nextRow]!.add(colIndex);
          }
        }
      }
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = constraints.maxWidth;
        final flexWeights = columnFlexWeights ?? List.generate(dataRows.isNotEmpty ? dataRows[0].length : 0, (_) => 1);
        final totalFlex = flexWeights.fold(0, (sum, w) => sum + w);
        
        Map<String, Rect> rowSpanPositions = {};
        double currentTop = 0;
        
        for (int rowIndex = 0; rowIndex < dataRows.length; rowIndex++) {
          double currentLeft = 0;
          for (int colIndex = 0; colIndex < flexWeights.length; colIndex++) {
            if (rowSpanMap[rowIndex]?[colIndex] != null) {
              final rowSpan = rowSpanMap[rowIndex]![colIndex]!;
              final colWidth = (flexWeights[colIndex] / totalFlex) * tableWidth;
              rowSpanPositions['$rowIndex-$colIndex'] = Rect.fromLTWH(
                currentLeft,
                currentTop,
                colWidth,
                40.0 * rowSpan,
              );
            }
            currentLeft += (flexWeights[colIndex] / totalFlex) * tableWidth;
          }
          currentTop += 40 + (rowIndex > 0 ? rowSpacing : 0);
        }
        
        return Stack(
          children: [
            Column(
              children: [
                for (int i = 0; i < dataRows.length; i++)
                  Padding(
                    padding: EdgeInsets.only(top: i > 0 ? rowSpacing : 0),
                    child: SizedBox(
                      height: 40,
                      child: ClipRect(
                        child: _buildDataRow(context, dataRows[i], i, skipCells[i] ?? {}),
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
              final cell = dataRows[rowIndex][colIndex];
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
                  key: cellKeys['$rowIndex-$colIndex'],
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: dataBackgroundColor ?? Colors.white,
                    border: border,
                  ),
                  child: ClipRect(
                    child: cell,
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildDataRow(
    BuildContext context,
    List<Widget> cells,
    int rowIndex,
    Set<int> skipColumns,
  ) {
    final isLastRow = rowIndex == dataRows.length - 1;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < cells.length; i++)
          Expanded(
            flex: columnFlexWeights != null && i < columnFlexWeights!.length
                ? columnFlexWeights![i]
                : 1,
            child: skipColumns.contains(i)
                ? _buildEmptyDataCell(isLastRow: isLastRow)
                : _wrapDataCell(context, cells[i], rowIndex, i, isLastRow: isLastRow),
          ),
      ],
    );
  }

  Widget _buildEmptyDataCell({bool isLastRow = false}) {
    return Container(
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

  Widget _wrapDataCell(BuildContext context, Widget child, int rowIndex, int colIndex, {bool isLastRow = false}) {
    final cellHeight = _getCellHeight(child);
    
    final border = isLastRow
        ? Border(
            right: BorderSide(color: borderColor, width: borderWidth),
          )
        : Border(
            right: BorderSide(color: borderColor, width: borderWidth),
            bottom: BorderSide(color: borderColor, width: borderWidth),
          );
    
    if (cellHeight > 40) {
      return Container(
        height: 40,
        decoration: BoxDecoration(
          color: dataBackgroundColor ?? Colors.white,
          border: border,
        ),
      );
    }
    
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: dataBackgroundColor ?? Colors.white,
        border: border,
      ),
      child: ClipRect(
        child: Align(
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }

  double _getCellHeight(Widget cell) {
    if (cell is SizedBox) {
      return _getCellHeightFromSizedBox(cell);
    }
    
    if (cell is Container) {
      return _getCellHeightFromContainer(cell);
    }
    
    return 40;
  }
  
  double _getCellHeightFromContainer(Container container) {
    if (container.constraints != null && container.constraints!.hasBoundedHeight) {
      final height = container.constraints!.maxHeight;
      if (height > 40) return height;
    }
    
    final child = container.child;
    if (child != null) {
      if (child is Container) {
        final childHeight = _getCellHeightFromContainer(child);
        if (childHeight > 40) return childHeight;
      }
    }
    
    return 40;
  }
  
  double _getCellHeightFromSizedBox(SizedBox sizedBox) {
    if (sizedBox.height != null) {
      final height = sizedBox.height!;
      if (height > 40) {
        return height;
      }
    }
    return 40;
  }

  int _calculateTotalColumns(List<List<GroupedTableCell>> rows) {
    if (rows.isEmpty) return 0;

    int maxColumns = 0;
    for (final row in rows) {
      int rowColumns = 0;
      for (final cell in row) {
        if (cell.children != null && cell.children!.isNotEmpty) {
          rowColumns += cell.children!.length;
        } else {
          rowColumns += cell.colSpan;
        }
      }
      maxColumns = maxColumns > rowColumns ? maxColumns : rowColumns;
    }

    return maxColumns;
  }

  bool _shouldSkipCell(GroupedTableCell cell, int currentRow) {
    return false;
  }

  int _calculateActualColSpan(GroupedTableCell cell, int totalColumns, int currentColumn) {
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

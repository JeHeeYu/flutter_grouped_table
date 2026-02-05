# flutter_grouped_table

[![pub package](https://img.shields.io/pub/v/flutter_grouped_table.svg)](https://pub.dev/packages/flutter_grouped_table)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/JeHeeYu/flutter_grouped_table/blob/main/LICENSE)
[![platform](https://img.shields.io/badge/platform-android%20%7C%20ios%20%7C%20linux%20%7C%20macos%20%7C%20windows%20%7C%20web-blue.svg)](https://pub.dev/packages/flutter_grouped_table)

A Flutter package for creating tables with merged cells (cell merge) support, especially useful for grouped headers.

## Features

- ✅ **Cell Merge Support**: Merge cells across multiple rows/columns in headers
- ✅ **Grouped Headers**: Support nested header structures (e.g., "Score" with "Math", "English", "Science" sub-headers)
- ✅ **Row Span**: Support vertical cell merging in data rows
- ✅ **Customizable**: Customize cell styles, colors, borders, and more
- ✅ **Responsive**: Use flex weights to control column sizes

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_grouped_table: ^0.1.0
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Example

```dart
import 'package:flutter_grouped_table/flutter_grouped_table.dart';

// Header configuration
final headerRow = [
  GroupedTableCell.simple('Name'),
  GroupedTableCell.simple('Age'),
  // Grouped header: "Score" with "Math", "English", "Science" sub-headers
  GroupedTableCell.grouped(
    text: 'Score',
    children: [
      GroupedTableCell.simple('Math'),
      GroupedTableCell.simple('English'),
      GroupedTableCell.simple('Science'),
    ],
  ),
];

// Data rows
final dataRows = [
  [
    Text('John'),
    Text('20'),
    Text('90'),
    Text('85'),
    Text('95'),
  ],
  // ... more rows
];

// Table widget
GroupedTable(
  headerRows: [headerRow],
  dataRows: dataRows,
  columnFlexWeights: [2, 1, 1, 1, 1],
)
```

### Row Span Example

To create a cell that spans multiple rows vertically, wrap your cell content in a `SizedBox` with height `40.0 * rowSpan`:

```dart
// Helper method to create a merged cell
Widget _buildMergedCell(String text, {required int rowSpan}) {
  return SizedBox(
    height: 40.0 * rowSpan,
    child: Container(
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    ),
  );
}

// Helper method to create an empty cell (for merged cells in subsequent rows)
Widget _buildEmptyCell() {
  return Container(
    height: 40,
    alignment: Alignment.center,
  );
}

// Data rows with row span
final dataRows = [
  [
    _buildDataCell('John'),
    _buildMergedCell('20', rowSpan: 2), // Spans 2 rows
    _buildDataCell('90'),
    _buildDataCell('85'),
    _buildDataCell('95'),
  ],
  [
    _buildDataCell('Jane'),
    _buildEmptyCell(), // Empty cell (merged from previous row)
    _buildDataCell('88'),
    _buildDataCell('92'),
    _buildDataCell('90'),
  ],
  [
    _buildDataCell('Bob'),
    _buildDataCell('25'), // New cell starts here
    _buildDataCell('85'),
    _buildDataCell('80'),
    _buildDataCell('88'),
  ],
];
```

**Important Notes:**
- Use `SizedBox` (not `Container`) with explicit `height` property for row span cells
- The height must be `40.0 * rowSpan` where `rowSpan` is the number of rows to merge
- For subsequent rows that are part of the merged cell, use an empty cell (e.g., `_buildEmptyCell()`)
- The default row height is 40 pixels

## API Reference

### GroupedTable

Main table widget.

#### Properties

- `headerRows` (required): List of header row configurations
- `dataRows` (required): List of data rows
- `columnFlexWeights`: Flex weights for columns (optional, for responsive sizing)
- `borderColor`: Border color (default: `Colors.black`)
- `borderWidth`: Border width (default: `1.0`)
- `borderRadius`: Table border radius
- `headerBackgroundColor`: Background color for header cells
- `dataBackgroundColor`: Background color for data cells
- `headerTextStyle`: Default text style for headers
- `dataTextStyle`: Default text style for data cells
- `defaultHeaderHeight`: Default header cell height
- `rowSpacing`: Spacing between rows

### GroupedTableCell

Represents a table cell.

#### Constructors

- `GroupedTableCell()`: Default constructor
- `GroupedTableCell.simple(String text)`: Simple text cell
- `GroupedTableCell.merged()`: Merged cell spanning multiple columns/rows
- `GroupedTableCell.grouped()`: Grouped header with nested children

#### Properties

- `text`: Cell text content
- `colSpan`: Number of columns this cell spans (default: 1)
- `rowSpan`: Number of rows this cell spans (default: 1)
- `backgroundColor`: Cell background color
- `textStyle`: Text style
- `alignment`: Cell content alignment (default: `Alignment.center`)
- `builder`: Custom widget builder (if provided, `text` is ignored)
- `border`: Border configuration
- `height`: Cell height
- `children`: Child cells (for grouped headers)

## Example

See the `example/` folder for more examples.

```bash
cd example
flutter run
```

## License

MIT License

Copyright (c) 2026 JeHee Yu

import 'package:flutter/material.dart';
import 'package:flutter_grouped_table/flutter_grouped_table.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Grouped Table Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ExamplePage(),
    );
  }
}

class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Grouped Table Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Grouped Table Example',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 32),
              _buildSimpleTable(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleTable(BuildContext context) {
    final headerRow = [
      GroupedTableCell.simple('Product'),
      GroupedTableCell.simple('Category'),
      GroupedTableCell.grouped(
        text: 'Sales',
        children: [
          GroupedTableCell.simple('Q1'),
          GroupedTableCell.simple('Q2'),
          GroupedTableCell.simple('Q3'),
          GroupedTableCell.simple('Q4'),
        ],
      ),
    ];

    final dataRows = [
      [
        _buildDataCell('Laptop'),
        _buildMergedAgeCell('Electronics', rowSpan: 3),
        _buildDataCell('120'),
        _buildDataCell('150'),
        _buildDataCell('180'),
        _buildDataCell('200'),
      ],
      [
        _buildDataCell('Smartphone'),
        _buildEmptyCell(),
        _buildDataCell('250'),
        _buildDataCell('280'),
        _buildDataCell('300'),
        _buildDataCell('320'),
      ],
      [
        _buildDataCell('Tablet'),
        _buildDataCell('Electronics'),
        _buildDataCell('80'),
        _buildDataCell('90'),
        _buildDataCell('100'),
        _buildDataCell('110'),
      ],
      [
        _buildDataCell('Desk Chair'),
        _buildDataCell('Furniture'),
        _buildDataCell('45'),
        _buildDataCell('50'),
        _buildDataCell('55'),
        _buildDataCell('60'),
      ],
      [
        _buildDataCell('Office Desk'),
        _buildDataCell('Furniture'),
        _buildDataCell('30'),
        _buildDataCell('35'),
        _buildDataCell('40'),
        _buildDataCell('45'),
      ],
      [
        _buildDataCell('Monitor'),
        _buildDataCell('Electronics'),
        _buildDataCell('95'),
        _buildDataCell('105'),
        _buildDataCell('115'),
        _buildDataCell('125'),
      ],
    ];

    return GroupedTable(
      headerRows: [headerRow],
      dataRows: dataRows,
      columnFlexWeights: [2, 1, 1, 1, 1, 1],
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      borderColor: Colors.black,
      borderWidth: 0.1,
      headerBackgroundColor: const Color.fromARGB(255, 103, 109, 122),
    );
  }

  Widget _buildDataCell(String text) {
    return Container(
      height: 40,
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMergedAgeCell(String text, {required int rowSpan}) {
    return SizedBox(
      height: 40.0 * rowSpan,
      child: Container(
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildEmptyCell() {
    return Container(
      height: 40,
      alignment: Alignment.center,
    );
  }

}

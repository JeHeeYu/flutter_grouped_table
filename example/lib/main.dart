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
      debugShowCheckedModeBanner: false,
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
      backgroundColor: const Color(0xFF0D1116),
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
                  color: Colors.white,
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
    return GroupedTable.fromSimpleData(
      headerRows: const [
        [
          'Product',
          'Category',
          {'text': 'Sales', 'children': ['Q1', 'Q2', 'Q3', 'Q4']}
        ]
      ],
      dataRows: const [
        ['Laptop', 'Electronics', '120', '150', '180', '200'],
        ['Smartphone', null, '250', '280', '300', '320'],
        ['Tablet', null, '80', '90', '100', '110'],
        ['Desk Chair', 'Furniture', '45', '50', '55', '60'],
        ['Office Desk', null, '30', '35', '40', '45'],
        ['Monitor', 'Electronics', '95', '105', '115', '125'],
      ],
      rowSpanMap: const {
        0: {1: 3},
        3: {1: 2},
      },
      columnFlexWeights: const [2, 1, 1, 1, 1, 1],
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      borderColor: Colors.black,
      borderWidth: 0.25,
      headerBackgroundColor: const Color(0xFF676B7A),
      rowHeight: 40.0,
    );
  }
}

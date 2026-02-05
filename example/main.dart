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
      appBar: AppBar(
        title: const Text('Grouped Table Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '셀 머지 예제: 오늘 섭취량',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildExampleTable(context),
            const SizedBox(height: 40),
            const Text(
              '간단한 예제',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildSimpleTable(context),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleTable(BuildContext context) {
    // 헤더 구성: 첫 번째 행
    final headerRow1 = [
      GroupedTableCell.simple('스톨번호'),
      GroupedTableCell.simple('급이유형\n스케줄'),
      GroupedTableCell.simple('모돈번호\n산차'),
      GroupedTableCell.simple('분만일\n급이일차'),
      GroupedTableCell.simple('상태'),
      GroupedTableCell.simple('메모'),
      // "오늘 섭취량" 그룹 헤더 - 아래에 "차수"와 "누적"이 있음
      GroupedTableCell.grouped(
        text: '오늘 섭취량',
        backgroundColor: const Color(0xFFF1F2F4),
        children: [
          GroupedTableCell.simple('차수'),
          GroupedTableCell.simple('누적'),
        ],
      ),
    ];

    // 두 번째 헤더 행 (빈 공간 채우기용)
    final headerRow2 = [
      // 첫 번째 행의 일반 셀들 아래는 빈 공간
      for (int i = 0; i < 6; i++)
        GroupedTableCell(
          text: '',
          height: 16.0,
          backgroundColor: Colors.white,
        ),
      // "차수" 셀
      GroupedTableCell(
        text: '',
        height: 16.0,
        backgroundColor: Colors.white,
      ),
      // "누적" 셀 (100% 표시가 들어갈 수 있음)
      GroupedTableCell(
        text: '',
        height: 16.0,
        backgroundColor: Colors.white,
        builder: (context) => const Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Text(
              '100%',
              style: TextStyle(
                fontSize: 7,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      ),
    ];

    // 데이터 행들
    final dataRows = List.generate(5, (index) {
      return [
        _buildDataCell('${index + 1}'),
        _buildDataCell('급이A\n스케줄1'),
        _buildDataCell('모돈${index + 1}\n3산차'),
        _buildDataCell('01/15\n(5일)'),
        _buildDataCell('정상'),
        _buildDataCell('메모'),
        _buildStepCell(),
        _buildAccumulatedCell(),
      ];
    });

    return GroupedTable(
      headerRows: [headerRow1, headerRow2],
      dataRows: dataRows,
      columnFlexWeights: [4, 4, 4, 4, 3, 3, 2, 4],
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      borderColor: const Color(0xFFE5E5E5),
      borderWidth: 0.25,
      headerBackgroundColor: const Color(0xFFF1F2F4),
      defaultHeaderHeight: 40.0,
    );
  }

  Widget _buildSimpleTable(BuildContext context) {
    final headerRow = [
      GroupedTableCell.simple('이름'),
      GroupedTableCell.simple('나이'),
      GroupedTableCell.grouped(
        text: '점수',
        children: [
          GroupedTableCell.simple('국어'),
          GroupedTableCell.simple('수학'),
          GroupedTableCell.simple('영어'),
        ],
      ),
    ];

    final dataRows = [
      [
        _buildDataCell('홍길동'),
        _buildDataCell('20'),
        _buildDataCell('90'),
        _buildDataCell('85'),
        _buildDataCell('95'),
      ],
      [
        _buildDataCell('김철수'),
        _buildDataCell('21'),
        _buildDataCell('88'),
        _buildDataCell('92'),
        _buildDataCell('87'),
      ],
      [
        _buildDataCell('이영희'),
        _buildDataCell('19'),
        _buildDataCell('95'),
        _buildDataCell('90'),
        _buildDataCell('93'),
      ],
    ];

    return GroupedTable(
      headerRows: [headerRow],
      dataRows: dataRows,
      columnFlexWeights: [2, 1, 1, 1, 1],
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      borderColor: const Color(0xFFE5E5E5),
      borderWidth: 0.25,
      headerBackgroundColor: const Color(0xFFF1F2F4),
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
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildStepCell() {
    return Container(
      height: 40,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < 3; i++)
            Container(
              width: 4,
              height: 22,
              margin: EdgeInsets.only(right: i < 2 ? 2 : 0),
              decoration: BoxDecoration(
                color: i < 2 ? Colors.blue : const Color(0xFFE5E5E5),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAccumulatedCell() {
    return Container(
      height: 40,
      alignment: Alignment.center,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellWidth = constraints.maxWidth;
          final blueLinePosition = cellWidth - 18.0;
          final progressBarWidth = blueLinePosition;
          final widthFactor = 0.75; // 75% 예제

          return Stack(
            children: [
              // 진행 바
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: progressBarWidth,
                  height: 22,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: widthFactor,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(3),
                          bottomRight: Radius.circular(3),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '3.5kg\n75%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // 점선 구분선
              Positioned(
                left: blueLinePosition,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 0.84,
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: Colors.blue.withOpacity(0.4),
                        width: 0.84,
                      ),
                    ),
                  ),
                  child: CustomPaint(
                    painter: _DashedLinePainter(
                      color: Colors.blue.withOpacity(0.4),
                    ),
                  ),
                ),
              ),
              // 목표 값
              Positioned(
                right: 1.0,
                top: 0,
                bottom: 0,
                child: const Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 4.0),
                    child: Text(
                      '4.5',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  static const double _dashWidth = 3.0;
  static const double _dashSpace = 2.0;

  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, (startY + _dashWidth).clamp(0.0, size.height)),
        paint,
      );
      startY += _dashWidth + _dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

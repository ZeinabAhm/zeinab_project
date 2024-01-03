import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'bar_data.dart';

class MyBarGraph extends StatelessWidget {
  final double? maxY;
  final double monAmount;
  final double tuesAmount;
  final double wedAmount;
  final double thurAmount;
  final double friAmount;
  final double satAmount;
  final double sunAmount;

  const MyBarGraph({
    Key? key,
    required this.maxY,
    required this.monAmount,
    required this.tuesAmount,
    required this.wedAmount,
    required this.thurAmount,
    required this.friAmount,
    required this.satAmount,
    required this.sunAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize bar data
    BarData myBarData = BarData(
      monAmount: monAmount,
      tuesAmount: tuesAmount,
      wedAmount: wedAmount,
      thurAmount: thurAmount,
      friAmount: friAmount,
      satAmount: satAmount,
      sunAmount: sunAmount,
    );
    myBarData.initializeBarData(maxY!);

    return BarChart(
      BarChartData(
        maxY: maxY,
        minY: 0,
        titlesData: FlTitlesData(
          show: true,
          topTitles: SideTitles(showTitles: false),
          leftTitles: SideTitles(showTitles: false),
          rightTitles: SideTitles(showTitles: false),
          bottomTitles: SideTitles(
            showTitles: true,
            getTitles: (double value) {
              return getBottomTitles(value);
            },
          ),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: myBarData.barData
            .map(
              (data) => BarChartGroupData(
            x: data.x,
            barRods: [
              BarChartRodData(
                y: data.y,
                colors: [Colors.grey.shade800],
                width: 25,
                borderRadius: BorderRadius.circular(7),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  y: maxY,
                  colors: [Colors.grey.shade200],
                ),
              ),
            ],
          ),
        )
            .toList(),
      ),
    );
  }
}

String getBottomTitles(double value) {
  const style = TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  switch (value.toInt()) {
    case 0:
      return 'M';
    case 1:
      return 'T';
    case 2:
      return 'W';
    case 3:
      return 'T';
    case 4:
      return 'F';
    case 5:
      return 'S';
    case 6:
      return 'S';
    default:
      return '';
  }
}
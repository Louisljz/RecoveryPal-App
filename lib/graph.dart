import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LineChartSample2 extends StatefulWidget {
  final List<FlSpot> spots;

  const LineChartSample2({super.key, required this.spots});

  @override
  State<LineChartSample2> createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<LineChartSample2> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.70,
      child: Padding(
        padding: const EdgeInsets.only(
          right: 18,
          left: 12,
          top: 55,
          bottom: 12,
        ),
        child: LineChart(
          mainData(),
        ),
      ),
    );
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: const FlGridData(
        show: false,
        drawVerticalLine: false, // Remove vertical lines
        drawHorizontalLine: false, // Remove horizontal lines
      ),
      titlesData: const FlTitlesData(
        show: false, // Hide all titles
      ),
      borderData: FlBorderData(
        show: false, // Hide border
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: widget.spots,
          isCurved: true,
          color: Theme.of(context).colorScheme.onSurface,
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: false, // Hide color below the graph
          ),
        ),
      ],
    );
  }
}

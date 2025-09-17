import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WeeklyGraph extends StatelessWidget {
  const WeeklyGraph({super.key});

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme.primary;

    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  const style = TextStyle(color: Colors.white54, fontSize: 10);
                  String text;
                  switch (value.toInt()) {
                    case 0: text = 'Mon'; break;
                    case 1: text = 'Tue'; break;
                    case 2: text = 'Wed'; break;
                    case 3: text = 'Thu'; break;
                    case 4: text = 'Fri'; break;
                    case 5: text = 'Sat'; break;
                    case 6: text = 'Sun'; break;
                    default: text = ''; break;
                  }
                  return SideTitleWidget(axisSide: meta.axisSide, space: 4, child: Text(text, style: style));
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: _getBarGroups(themeColor),
        ),
      ),
    );
  }

  // Sample data for the past 7 days
  List<BarChartGroupData> _getBarGroups(Color themeColor) {
    final List<double> dailyTasks = [5, 6, 5, 8, 6, 7, 9]; // Tasks completed per day
    return List.generate(7, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: dailyTasks[index],
            color: index == 2 ? themeColor : Colors.white24, // Highlight today (Wednesday)
            width: 12,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    });
  }
}
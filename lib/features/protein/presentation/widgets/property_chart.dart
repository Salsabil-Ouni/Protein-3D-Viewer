import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/protein_detail.dart';
import '../../../../core/theme/app_colors.dart';

class AminoAcidChart extends StatelessWidget {
  final PhysicoChemicalProperties properties;

  const AminoAcidChart({super.key, required this.properties});

  @override
  Widget build(BuildContext context) {
    final sorted = properties.aminoAcidComposition.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top10 = sorted.take(10).toList();

    if (top10.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: top10.first.value * 1.2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, gi, rod, ri) => BarTooltipItem(
                '${top10[group.x].key}\n${rod.toY.toStringAsFixed(1)}%',
                const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (v, _) => Text('${v.toInt()}%',
                    style: const TextStyle(fontSize: 10)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) => Text(
                  top10[v.toInt()].key,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(
            top10.length,
            (i) => BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: top10[i].value,
                  color: AppColors.chartColors[i % AppColors.chartColors.length],
                  width: 22,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PropertyRadarChart extends StatelessWidget {
  final PhysicoChemicalProperties properties;

  const PropertyRadarChart({super.key, required this.properties});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          tickCount: 4,
          ticksTextStyle: const TextStyle(fontSize: 8, color: Colors.grey),
          radarBorderData: const BorderSide(color: Colors.grey, width: 0.5),
          gridBorderData: const BorderSide(color: Colors.grey, width: 0.5),
          titleTextStyle: const TextStyle(fontSize: 11),
          dataSets: [
            RadarDataSet(
              fillColor: AppColors.primary.withValues(alpha: 0.2),
              borderColor: AppColors.primary,
              borderWidth: 2,
              dataEntries: [
                RadarEntry(value: (properties.gravy + 4.5) / 9 * 10),
                RadarEntry(value: properties.aliphaticIndex / 20),
                RadarEntry(value: (properties.isoelectricPoint / 14) * 10),
                RadarEntry(value: (properties.instabilityIndex > 40 ? 3 : 7)),
                RadarEntry(value: (properties.molecularWeight / 100).clamp(0, 10)),
              ],
            ),
          ],
          getTitle: (index, _) {
            const titles = ['GRAVY', 'Aliphatic', 'pI', 'Stability', 'MW'];
            return RadarChartTitle(text: titles[index], angle: 0);
          },
        ),
      ),
    );
  }
}

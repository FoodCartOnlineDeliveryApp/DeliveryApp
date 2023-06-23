import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:mealup_driver/model/earninghistory.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
    );
  }
}

class CustomRoundedBars extends StatelessWidget {
  final List<dynamic> data;
  final bool? animate;

  CustomRoundedBars(this.data, {this.animate});

  @override
  Widget build(BuildContext context) {
    var seriesList = _createSampleData(data);

    return new charts.BarChart(
      seriesList as List<Series<dynamic, String>>,
      primaryMeasureAxis: new charts.NumericAxisSpec(
          renderSpec: charts.GridlineRendererSpec(
            labelStyle: new charts.TextStyleSpec(
                fontSize: 12, // size in Pts.
                color: charts.MaterialPalette.white),
            lineStyle: charts.LineStyleSpec(
              dashPattern: [4, 5],

              color: charts.ColorUtil.fromDartColor(Colors.white),
            ),
          )),
      domainAxis: new charts.OrdinalAxisSpec(
          renderSpec: new charts.SmallTickRendererSpec(

              labelStyle: new charts.TextStyleSpec(
                  fontSize: 12,
                  color: charts.MaterialPalette.white),

              lineStyle: new charts.LineStyleSpec(
                color:
                charts.ColorUtil.fromDartColor(Colors.white),
                thickness: 1,
              ))),
      animate: true,
      barGroupingType: charts.BarGroupingType.stacked,
      defaultRenderer: new charts.BarRendererConfig(
          cornerStrategy: const charts.ConstCornerStrategy(30)),
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<Graph, String>> _createSampleData(dynamic data) {
    return [
      new charts.Series<Graph, String>(
        id: 'mileage1',
        colorFn: (_, __) =>
            charts.ColorUtil.fromDartColor(Colors.green),

        domainFn: (Graph graph, _) => graph.month!,
        measureFn: (Graph graph, _) => int.parse(graph.monthEarning!),
        data: data,
        fillColorFn: (Graph graph, _) =>
            charts.ColorUtil.fromDartColor(Colors.transparent),
      ),
      new charts.Series<Graph, String>(
        id: 'graph',
        colorFn: (_, __) =>
            charts.ColorUtil.fromDartColor(Colors.green),
        domainFn: (Graph graph, _) => graph.month!,
        measureFn: (Graph graph, _) => int.parse(graph.monthEarning!),
        data: data,
      ),
      new charts.Series<Graph, String>(
        id: 'graph2',
        colorFn: (_, __) =>
            charts.ColorUtil.fromDartColor(Colors.green),
        domainFn: (Graph graph, _) => graph.month!,
        measureFn: (Graph graph, _) => int.parse(graph.monthEarning!),
        data: data,
        fillColorFn: (Graph graph, _) =>
            charts.ColorUtil.fromDartColor(Colors.transparent),
      ),
    ];
  }
}

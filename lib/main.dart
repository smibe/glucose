import 'dart:io';

import 'package:csv/csv.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<FlSpot> _spots = [];

  Future<void> _loadData() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/glucose/data.csv');

    if (await file.exists()) {
      final rawData = await file.readAsString();
      List<List<dynamic>> listData = CsvToListConverter().convert(rawData);
      setState(() {
        _spots = listData.map((data) {
          DateTime date = DateTime.parse(data[0]);
          return FlSpot(
              date.millisecondsSinceEpoch / (1000 * 60), data[1] as double);
        }).toList();
      });
    }
  }

  String _formattedDate(double value) {
    DateTime date =
        DateTime.fromMillisecondsSinceEpoch((value as int) * (1000 * 60));
    return date.toString();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: _spots.isEmpty
            ? const CircularProgressIndicator()
            : LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: SideTitles(
                      showTitles: true,
                      getTitles: _formattedDate,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(spots: _spots, isCurved: true),
                  ],
                ),
              ),
      ),
    );
  }
}

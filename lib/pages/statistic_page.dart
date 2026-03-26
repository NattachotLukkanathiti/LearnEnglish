import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key});

  @override
  State<StatisticPage> createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {
  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('history_v1') ?? '[]';
    final List<dynamic> arr = jsonDecode(raw);
    setState(() {
      history = arr.map((e) => Map<String, dynamic>.from(e)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('สถิติ')),
      body: history.isEmpty
          ? const Center(child: Text('ยังไม่มีข้อมูลการเรียน/สอบ'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: history.length,
              itemBuilder: (ctx, i) {
                final h = history[i];
                return Card(
                  child: ListTile(
                    title: Text('ประเภท: ${h['type']}'),
                    subtitle: Text('เวลา: ${h['time']}\nรายละเอียด: ${h['words'] ?? h['level'] ?? ''}'),
                  ),
                );
              },
            ),
    );
  }
}

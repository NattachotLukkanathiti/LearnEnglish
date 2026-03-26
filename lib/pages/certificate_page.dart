import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CertificatePage extends StatefulWidget {
  const CertificatePage({super.key});

  @override
  State<CertificatePage> createState() => _CertificatePageState();
}

class _CertificatePageState extends State<CertificatePage> {
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
    // เอาเฉพาะ test ที่สอบ "ผ่าน" (>= 30 คะแนน)
    final passedTests = history.where((h) => h['type'] == 'test' && (h['score'] ?? 0) >= 30).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('ใบประกาศนียบัตร')),
      body: passedTests.isEmpty
          ? const Center(child: Text('ยังไม่มีใบประกาศนียบัตร'))
          : ListView.builder(
              itemCount: passedTests.length,
              itemBuilder: (ctx, i) {
                final h = passedTests[i];
                return Card(
                  margin: const EdgeInsets.all(12),
                  color: Colors.amber[100],
                  child: ListTile(
                    leading: const Icon(Icons.card_membership, color: Colors.orange),
                    title: Text('ประกาศนียบัตรการสอบ ${h['level']}'),
                    subtitle: Text('คะแนน: ${h['score']}/${h['total']}'),
                  ),
                );
              },
            ),
    );
  }
}

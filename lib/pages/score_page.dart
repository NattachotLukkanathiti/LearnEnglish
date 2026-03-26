import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // สำหรับจัดรูปแบบวันที่

class HistoryPage extends StatefulWidget {
  final String username; // รับ username จาก widget ก่อนหน้า
  const HistoryPage({super.key , required this.username});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final String level = 'Advanced';

  int? highestScore;
  Timestamp? latestTimestamp;
  bool isLoading = true; // เพิ่มสถานะโหลด

  @override
  void initState() {
    super.initState();
    fetchScoreHistory();
  }

  Future<void> fetchScoreHistory() async {
    setState(() => isLoading = true);
    final userId = widget.username; // รับ userId จาก widget ก่อนหน้า
    final snapshot = await FirebaseFirestore.instance
        .collection('scores')
        .where('userId', isEqualTo: userId)
        .where('level', isEqualTo: level)
        .get();

    if (snapshot.docs.isNotEmpty) {
      int maxScore = 0;
      Timestamp? latest;

      for (var doc in snapshot.docs) {
        int score = doc['score'] ?? 0;
        Timestamp timestamp = doc['timestamp'] ?? Timestamp.now();

        if (score > maxScore) {
          maxScore = score;
          latest = timestamp;
        }
      }

      setState(() {
        highestScore = maxScore;
        latestTimestamp = latest;
        isLoading = false;
      });
    } else {
      setState(() {
        highestScore = 0;
        latestTimestamp = null;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ประวัติการทดสอบ"),
        centerTitle: true,
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : (highestScore == null || latestTimestamp == null
                ? const Text(
                    "ยังไม่มีประวัติการทดสอบ",
                    style: TextStyle(fontSize: 20),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history, size: 80, color: Colors.blueAccent),
                      const SizedBox(height: 20),
                      Text(
                        "คะแนนที่ดีที่สุด: $highestScore",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "เมื่อ: ${DateFormat('dd MMM yyyy, HH:mm').format(latestTimestamp!.toDate())}",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  )),
      ),
    );
  }
}

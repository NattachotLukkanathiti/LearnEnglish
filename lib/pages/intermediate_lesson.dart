import 'package:flutter/material.dart';
import 'learn_page.dart';
import 'beginner_lesson.dart' show buildChapterText;

/// ----------------------
/// Chapter 1 : is
/// ----------------------
class IntermediateLessonPage extends StatelessWidget {
  const IntermediateLessonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return buildChapterScaffold(
      context,
      title: "Chapter 1 : is",
      content: buildChapterText(
        "is ใช้กับประธานเอกพจน์ (He, She, It หรือคำนามที่มีเพียงสิ่งเดียว)\n\n"
        "ตัวอย่าง:\n- He is a student.\n- She is my sister.\n- It is a cat.",
        context,
        height: 1.5,
      ),
      onNext: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Chapter1IsExamplePage()),
      ),
    );
  }
}

class Chapter1IsExamplePage extends StatelessWidget {
  const Chapter1IsExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return buildExampleScaffold(
      context,
      title: "Examples : is",
      examples: const [
        ["He is a doctor.", "เขาเป็นหมอ", Icons.local_hospital],
        ["She is a teacher.", "เธอเป็นครู", Icons.school],
        ["It is a dog.", "มันเป็นสุนัข", Icons.pets],
        ["This is my pen.", "นี่คือปากกาของฉัน", Icons.edit],
        ["That is a book.", "นั่นคือหนังสือ", Icons.menu_book],
      ],
      onNext: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Chapter2AmPage()),
      ),
    );
  }
}

/// ----------------------
/// Chapter 2 : am
/// ----------------------
class Chapter2AmPage extends StatelessWidget {
  const Chapter2AmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return buildChapterScaffold(
      context,
      title: "Chapter 2 : am",
      content: buildChapterText(
        "am ใช้กับประธาน I เท่านั้น\n\n"
        "ตัวอย่าง:\n- I am a student.\n- I am happy.\n- I am ready.",
        context,
        height: 1.5,
      ),
      onNext: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Chapter2AmExamplePage()),
      ),
    );
  }
}

class Chapter2AmExamplePage extends StatelessWidget {
  const Chapter2AmExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return buildExampleScaffold(
      context,
      title: "Examples : am",
      examples: const [
        ["I am a student.", "ฉันเป็นนักเรียน", Icons.school],
        ["I am happy.", "ฉันมีความสุข", Icons.sentiment_satisfied],
        ["I am hungry.", "ฉันหิว", Icons.restaurant],
        ["I am ready.", "ฉันพร้อมแล้ว", Icons.done_all],
        ["I am at home.", "ฉันอยู่บ้าน", Icons.home],
      ],
      onNext: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Chapter3ArePage()),
      ),
    );
  }
}

/// ----------------------
/// Chapter 3 : are
/// ----------------------
class Chapter3ArePage extends StatelessWidget {
  const Chapter3ArePage({super.key});

  @override
  Widget build(BuildContext context) {
    return buildChapterScaffold(
      context,
      title: "Chapter 3 : are",
      content: buildChapterText(
        "are ใช้กับประธานพหูพจน์ (You, We, They หรือคำนามที่มีมากกว่า 1 สิ่ง)\n\n"
        "ตัวอย่าง:\n- You are my friend.\n- They are students.\n- We are ready.",
        context,
        height: 1.5,
      ),
      onNext: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Chapter3AreExamplePage()),
      ),
    );
  }
}

class Chapter3AreExamplePage extends StatelessWidget {
  const Chapter3AreExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return buildExampleScaffold(
      context,
      title: "Examples : are",
      examples: const [
        ["You are my friend.", "คุณเป็นเพื่อนของฉัน", Icons.people],
        ["They are doctors.", "พวกเขาเป็นหมอ", Icons.local_hospital],
        ["We are happy.", "พวกเรามีความสุข", Icons.emoji_emotions],
        ["You are students.", "พวกคุณเป็นนักเรียน", Icons.school],
        ["They are at the park.", "พวกเขาอยู่ที่สวนสาธารณะ", Icons.park],
      ],
      // ✅ จบ Chapter 3 → ไปหน้า LearnPage และย้อนกลับไม่ได้
      onNext: () => Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LearnPage()),
        (route) => false,
      ),
    );
  }
}

/// ----------------------
/// Helper Widgets
/// ----------------------

Widget buildChapterScaffold(
  BuildContext context, {
  required String title,
  required Widget content,
  required VoidCallback onNext,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final textColor = isDark ? Colors.white : Colors.black;
  return Scaffold(
    appBar: AppBar(
      title: const Text("Intermediate Lesson"),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LearnPage()),
          (route) => false,
        ),
      ),
      backgroundColor: Colors.blueAccent,
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 16),
          content,
          const Spacer(),
          buildNavButtons(context, onNext),
        ],
      ),
    ),
  );
}

Widget buildExampleScaffold(
  BuildContext context, {
  required String title,
  required List<List<dynamic>> examples,
  required VoidCallback onNext,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final textColor = isDark ? Colors.white : Colors.black;
  return Scaffold(
    appBar: AppBar(
      title: const Text("Examples"),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LearnPage()),
          (route) => false,
        ),
      ),
      backgroundColor: Colors.blueAccent,
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: examples.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = examples[index];
                return buildExample(item[0], item[1], item[2]);
              },
            ),
          ),
          buildNavButtons(context, onNext),
        ],
      ),
    ),
  );
}

Widget buildNavButtons(BuildContext context, VoidCallback onNext) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: const Icon(Icons.arrow_back, size: 28),
          ),
        ),
        InkWell(
          onTap: onNext,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: const Icon(Icons.arrow_forward, size: 28),
          ),
        ),
      ],
    ),
  );
}

Widget buildExample(String sentence, String meaning, IconData icon) {
  return Builder(
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final textColor = isDark ? Colors.white : Colors.black;
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sentence,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                Text(meaning, style: TextStyle(fontSize: 16, color: textColor)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Icon(icon, size: 50, color: Colors.blueAccent),
        ],
      );
    },
  );
}

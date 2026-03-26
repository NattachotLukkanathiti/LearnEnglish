
import 'package:flutter/material.dart';
import 'learn_page.dart';

/// Helper สำหรับสร้าง Text ที่เปลี่ยนสีตามธีม
Widget buildChapterText(String text, BuildContext context, {double fontSize = 18, FontWeight? fontWeight, double? height}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final textColor = isDark ? Colors.white : Colors.black;
  return Text(
    text,
    style: TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      color: textColor,
    ),
  );
}

/// ----------------------
/// Chapter 1 : What is this?
/// ----------------------
class BeginnerLessonPage extends StatelessWidget {
  const BeginnerLessonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return buildChapterScaffold(
      context,
      title: "Chapter 1 : What is this ?",
      content: buildChapterText(
        "ใช้เมื่อสิ่งของอยู่ใกล้ตัวผู้พูด และเป็นคำนามเอกพจน์ (มีสิ่งเดียว) "
        "หรือนามนับไม่ได้ เช่น\n\n\"What is this?\" → \"This is a pen.\"",
        context,
        height: 1.5,
      ),
      onNext: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Chapter1ExamplePage()),
      ),
    );
  }
}

class Chapter1ExamplePage extends StatelessWidget {
  const Chapter1ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return buildExampleScaffold(
      context,
      title: "Chapter 1 Examples",
      examples: const [
        ["What is this?", "It is a Cup", Icons.coffee],
        ["What is this?", "It is a Ball", Icons.sports_soccer],
        ["What is this?", "It is a Hat", Icons.hiking],
        ["What is this?", "It is an Egg", Icons.egg],
        ["What is this?", "It is a Book", Icons.menu_book],
      ],
      onNext: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Chapter2Page()),
      ),
    );
  }
}

/// ----------------------
/// Chapter 2 : What is that?
/// ----------------------
class Chapter2Page extends StatelessWidget {
  const Chapter2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return buildChapterScaffold(
      context,
      title: "Chapter 2 : What is that ?",
      content: buildChapterText(
        "ใช้เมื่อสิ่งของอยู่ไกลจากตัวผู้พูด และเป็นคำนามเอกพจน์ "
        "หรือนามนับไม่ได้ เช่น\n\n\"What is that?\" → \"That is a chair.\"",
        context,
        height: 1.5,
      ),
      onNext: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Chapter2ExamplePage()),
      ),
    );
  }
}

class Chapter2ExamplePage extends StatelessWidget {
  const Chapter2ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return buildExampleScaffold(
      context,
      title: "Chapter 2 Examples",
      examples: const [
        ["What is that?", "That is a Tree", Icons.park],
        ["What is that?", "That is a Car", Icons.directions_car],
        ["What is that?", "That is a House", Icons.home],
        ["What is that?", "That is a Dog", Icons.pets],
        ["What is that?", "That is a Lamp", Icons.light],
      ],
      onNext: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Chapter3Page()),
      ),
    );
  }
}

/// ----------------------
/// Chapter 3 : These or Those?
/// ----------------------
class Chapter3Page extends StatelessWidget {
  const Chapter3Page({super.key});

  @override
  Widget build(BuildContext context) {
    return buildChapterScaffold(
      context,
      title: "Chapter 3 : These or Those ?",
      content: buildChapterText(
        "ใช้เมื่อสิ่งของมีหลายชิ้น (พหูพจน์)\n\n"
        "• These = สิ่งของที่ใกล้\n"
        "• Those = สิ่งของที่ไกล\n\n"
        "เช่น \"What are these?\" → \"These are books.\"",
        context,
        height: 1.5,
      ),
      onNext: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Chapter3ExamplePage()),
      ),
    );
  }
}

class Chapter3ExamplePage extends StatelessWidget {
  const Chapter3ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return buildExampleScaffold(
      context,
      title: "Chapter 3 Examples",
      examples: const [
        ["What are these?", "These are Apples", Icons.apple],
        ["What are those?", "Those are Stars", Icons.star],
        ["What are these?", "These are Chairs", Icons.chair],
        ["What are those?", "Those are Birds", Icons.flight],
        ["What are these?", "These are Shoes", Icons.checkroom],
      ],
      onNext: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Chapter4Page()),
      ),
    );
  }
}

/// ----------------------
/// Chapter 4 : Those or These?
/// ----------------------
class Chapter4Page extends StatelessWidget {
  const Chapter4Page({super.key});

  @override
  Widget build(BuildContext context) {
    return buildChapterScaffold(
      context,
      title: "Chapter 4 : Those or These ?",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildChapterText(
            "ฝึกการเลือกใช้ These/Those ในประโยคถาม-ตอบให้คล่องขึ้น",
            context,
            height: 1.5,
          ),
          const SizedBox(height: 16),
          buildChapterText(
            "ตัวอย่าง:",
            context,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          buildChapterText(
            '"Are those your books?" → "Yes, those are mine."',
            context,
            fontSize: 16,
          ),
        ],
      ),
      onNext: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Chapter4ExamplePage()),
      ),
    );
  }
}

class Chapter4ExamplePage extends StatelessWidget {
  const Chapter4ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return buildExampleScaffold(
      context,
      title: "Chapter 4 Examples",
      examples: const [
        ["Are these your pens?", "Yes, these are mine.", Icons.edit],
        ["Are those your cars?", "Yes, those are mine.", Icons.car_rental],
        ["Are these your bags?", "Yes, these are mine.", Icons.backpack],
        ["Are those your friends?", "Yes, those are mine.", Icons.people],
        ["Are these your phones?", "Yes, these are mine.", Icons.phone_android],
      ],
      onNext: () => Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LearnPage()),
        (route) => false, // ลบ stack หน้าเก่าทั้งหมด
      ),
    );
  }
}


/// ----------------------
/// Widget Helper
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
      title: const Text("Beginner Lesson"),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LearnPage()),
          (route) => false,
        ),
      ),
      backgroundColor: Colors.teal,
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold)),
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
      backgroundColor: Colors.teal,
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

Widget buildExample(String question, String answer, IconData icon) {
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
                Text(question, style: TextStyle(fontSize: 18, color: textColor)),
                Text(answer,
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Icon(icon, size: 50, color: Colors.teal),
        ],
      );
    },
  );
}

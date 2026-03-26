import 'package:flutter/material.dart';
import 'learn_page.dart'; // <-- import หน้า LearnPage ของคุณ

class AdvancedLessonPage extends StatelessWidget {
  const AdvancedLessonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Advanced Lessons"),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        children: [
          _buildLessonTile(context, "Chapter 1: Fruits", const FruitsPage()),
          _buildLessonTile(context, "Chapter 2: Locations", const LocationsPage()),
          _buildLessonTile(context, "Chapter 3: Occupations", const OccupationsPage()),
        ],
      ),
    );
  }

  Widget _buildLessonTile(BuildContext context, String title, Widget page) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    return ListTile(
      title: Text(title, style: TextStyle(color: textColor)),
      trailing: const Icon(Icons.arrow_forward),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
    );
  }
}

//
// ---------------- CHAPTER 1: Fruits ----------------
//
class FruitsPage extends StatelessWidget {
  const FruitsPage({super.key});

  final List<String> fruits = const [
    "apple", "banana", "orange", "grape", "mango",
    "pineapple", "papaya", "watermelon", "strawberry", "blueberry",
    "cherry", "pear", "peach", "plum", "kiwi",
    "lemon", "lime", "coconut", "pomegranate", "guava"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chapter 1: Fruits"),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Builder(
              builder: (context) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                final textColor = isDark ? Colors.white : Colors.black;
                return Text(
                  "Vocabulary: Fruits",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: fruits.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(fruits[index]),
              ),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FruitsExamplePage()),
              ),
              child: const Text("See Examples"),
            ),
          ),
        ],
      ),
    );
  }
}

class FruitsExamplePage extends StatelessWidget {
  const FruitsExamplePage({super.key});

  final List<String> examples = const [
    "This is an apple.",
    "That is a mango.",
    "These are bananas.",
    "Those are grapes.",
    "The pineapple is on the table. It is sweet."
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Examples: Fruits"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LearnPage()),
            (route) => false,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: examples.length,
        itemBuilder: (context, index) => ListTile(
          leading: const Icon(Icons.circle, size: 10),
          title: Text(examples[index]),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LearnPage()),
            (route) => false,
          ),
          child: const Text("Back to Learn Page"),
        ),
      ),
    );
  }
}

//
// ---------------- CHAPTER 2: Locations ----------------
//
class LocationsPage extends StatelessWidget {
  const LocationsPage({super.key});

  final List<String> locations = const [
    "school", "hospital", "market", "park", "bank",
    "library", "restaurant", "café", "hotel", "airport",
    "station", "post office", "museum", "zoo", "temple",
    "supermarket", "cinema", "stadium", "police station", "office"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chapter 2: Locations"),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Builder(
              builder: (context) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                final textColor = isDark ? Colors.white : Colors.black;
                return Text(
                  "Vocabulary: Locations",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: locations.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(locations[index]),
              ),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LocationsExamplePage()),
              ),
              child: const Text("See Examples"),
            ),
          ),
        ],
      ),
    );
  }
}

class LocationsExamplePage extends StatelessWidget {
  const LocationsExamplePage({super.key});

  final List<String> examples = const [
    "This is a school.",
    "That is a hospital.",
    "These are restaurants.",
    "Those are hotels.",
    "The library is near the park. It is big."
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Examples: Locations"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LearnPage()),
            (route) => false,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: examples.length,
        itemBuilder: (context, index) => ListTile(
          leading: const Icon(Icons.circle, size: 10),
          title: Text(examples[index]),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LearnPage()),
            (route) => false,
          ),
          child: const Text("Back to Learn Page"),
        ),
      ),
    );
  }
}

//
// ---------------- CHAPTER 3: Occupations ----------------
//
class OccupationsPage extends StatelessWidget {
  const OccupationsPage({super.key});

  final List<String> jobs = const [
    "teacher", "doctor", "nurse", "police officer", "firefighter",
    "engineer", "driver", "chef", "farmer", "soldier",
    "pilot", "actor", "musician", "artist", "writer",
    "student", "lawyer", "scientist", "worker", "dentist"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chapter 3: Occupations"),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Builder(
              builder: (context) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                final textColor = isDark ? Colors.white : Colors.black;
                return Text(
                  "Vocabulary: Occupations",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: jobs.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(jobs[index]),
              ),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OccupationsExamplePage()),
              ),
              child: const Text("See Examples"),
            ),
          ),
        ],
      ),
    );
  }
}

class OccupationsExamplePage extends StatelessWidget {
  const OccupationsExamplePage({super.key});

  final List<String> examples = const [
    "This is a teacher.",
    "That is a doctor.",
    "These are students.",
    "Those are farmers.",
    "He is an engineer."
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Examples: Occupations"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LearnPage()),
            (route) => false,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: examples.length,
        itemBuilder: (context, index) => ListTile(
          leading: const Icon(Icons.circle, size: 10),
          title: Text(examples[index]),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LearnPage()),
            (route) => false,
          ),
          child: const Text("Back to Learn Page"),
        ),
      ),
    );
  }
}

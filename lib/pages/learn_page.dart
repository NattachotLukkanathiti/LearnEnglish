import 'dart:math';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'beginner_lesson.dart';
import 'intermediate_lesson.dart';
import 'advanced_lesson.dart';

class LearnPage extends StatefulWidget {
  final void Function(Map<String, dynamic>)? onCompleteLesson;

  const LearnPage({super.key, this.onCompleteLesson});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _titleController;
  late List<Offset> _particles;

  @override
  void initState() {
    super.initState();

    _bgController =
        AnimationController(vsync: this, duration: const Duration(seconds: 20))
          ..repeat();

    _titleController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat(reverse: true);

    _particles = List.generate(20, (index) {
      final rand = Random();
      return Offset(rand.nextDouble(), rand.nextDouble());
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _saveHistory(String level, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('history_v1') ?? '[]';
    final List<dynamic> arr = jsonDecode(raw);
    arr.add({
      'type': 'lesson',
      'level': level,
      'score': score,
      'time': DateTime.now().toIso8601String(),
    });
    await prefs.setString('history_v1', jsonEncode(arr));
  }

  void _openLesson(BuildContext context, String level) {
    final score = Random().nextInt(100);

    widget.onCompleteLesson?.call({
      'type': 'lesson',
      'level': level,
      'time': DateTime.now().toIso8601String(),
      'score': score,
    });

    _saveHistory(level, score);

    Widget page;
    switch (level) {
      case "Beginner":
        page = const BeginnerLessonPage();
        break;
      case "Intermediate":
        page = const IntermediateLessonPage();
        break;
      case "Advanced":
        page = const AdvancedLessonPage();
        break;
      default:
        page = const Scaffold(
          body: Center(child: Text("Lesson not found")),
        );
    }

    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (context, anim, secAnim, child) {
        final fade = Tween<double>(begin: 0, end: 1).animate(anim);
        final scale = Tween<double>(begin: 0.9, end: 1.0).animate(
          CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        );
        return FadeTransition(
          opacity: fade,
          child: ScaleTransition(scale: scale, child: child),
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              title: const Text("Lessons"),
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.black.withOpacity(0.2),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _bgController,
            builder: (_, __) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [Colors.indigo.shade900, Colors.black]
                        : [Colors.teal.shade200, Colors.blue.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              );
            },
          ),
          ..._buildParticles(context),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(color: Colors.black.withOpacity(0.05)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildAnimatedTitle(isDark),
                  const SizedBox(height: 40),
                  _buildLessonCard(
                    number: 1,
                    title: "Beginner",
                    description: "Start with the basics. (20 Lessons)",
                    color: Colors.teal.shade400,
                    onTap: () => _openLesson(context, "Beginner"),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 24),
                  _buildLessonCard(
                    number: 2,
                    title: "Intermediate",
                    description: "Level up your knowledge. (25 Lessons)",
                    color: Colors.orange.shade400,
                    onTap: () => _openLesson(context, "Intermediate"),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 24),
                  _buildLessonCard(
                    number: 3,
                    title: "Advanced",
                    description: "Master the concepts. (30 Lessons)",
                    color: Colors.purple.shade400,
                    onTap: () => _openLesson(context, "Advanced"),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 50),
                  _buildInfoCard(isDark),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTitle(bool isDark) {
    return AnimatedBuilder(
      animation: _titleController,
      builder: (context, _) {
        final dy = sin(_titleController.value * 2 * pi) * 5;
        return Transform.translate(
          offset: Offset(0, dy),
          child: Column(
            children: [
              Text(
                "Choose Your Path",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Start learning step by step",
                style: TextStyle(
                  fontSize: 16,
                  color: isDark
                      ? Colors.white70
                      : Colors.black.withOpacity(0.6),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLessonCard({
    required int number,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.8),
              color.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
              child: Text(
                number.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.indigo.shade700, Colors.black]
              : [Colors.white, Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.school, size: 48, color: Colors.teal),
          const SizedBox(height: 12),
          Text(
            "Daily Tip",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Practice a little every day to boost your skills.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildParticles(BuildContext context) {
    return List.generate(_particles.length, (i) {
      final anim = CurvedAnimation(
        parent: _bgController,
        curve: Interval(i * 0.05, 1, curve: Curves.easeInOut),
      );

      return AnimatedBuilder(
        animation: anim,
        builder: (_, __) {
          final dx = MediaQuery.of(context).size.width *
              ((_particles[i].dx + anim.value) % 1);
          final dy = MediaQuery.of(context).size.height *
              ((_particles[i].dy + anim.value) % 1);

          return Positioned(
            left: dx,
            top: dy,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      );
    });
  }
}

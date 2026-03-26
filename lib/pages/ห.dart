import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';

class SentenceModel {
  final int id;
  final List<String> sentence;
  final List<String> choices;
  final List<String> answers;
  final String? image; // เพิ่มตัวแปร image สำหรับเก็บลิงก์รูปภาพ

  SentenceModel({
    required this.id,
    required this.sentence,
    required this.choices,
    required this.answers,
    this.image,
  });

  factory SentenceModel.fromFirestore(Map<String, dynamic> data) {
    return SentenceModel(
      id: data['id'] ?? 0,
      sentence: List<String>.from(data['sentence'] ?? []),
      choices: List<String>.from(data['choices'] ?? []),
      answers: List<String>.from(data['answers'] ?? []),
      image: data['image'], // ดึงลิงก์รูปภาพจาก Firestore
    );
  }
}

class Advanced extends StatefulWidget {
  const Advanced({super.key});

  @override
  State<Advanced> createState() => _BeginnerState();
}

class _BeginnerState extends State<Advanced> with SingleTickerProviderStateMixin {
  int currentId = 1;
  int totalQuestions = 5;
  int score = 0;

  SentenceModel? currentQuestion;
  String? selectedAnswer;

  Timer? _questionTimer;
  int timeLeft = 60;

  bool _showCountdown = true;
  int _countdown = 3;

  Color? _feedbackColor;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();

    // เริ่มเล่นเพลง
    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _audioPlayer.play(AssetSource('audio/Advanced.mp3'));

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 16)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);

    loadQuestionById(currentId);
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    _shakeController.dispose();
    _audioPlayer.stop(); // หยุดเพลงเมื่อออก
    super.dispose();
  }

  Future<void> loadQuestionById(int id) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('advanced')
        .where('id', isEqualTo: id)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        currentQuestion = SentenceModel.fromFirestore(snapshot.docs.first.data());
        selectedAnswer = null;
        timeLeft = 15;
        _startCountdown();
      });
    } else {
      await saveScoreToFirebase();

      setState(() {
        currentQuestion = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("🎉 You finished all questions! Your score: $score")),
      );
    }
  }

  void _startCountdown() {
    setState(() {
      _showCountdown = true;
      _countdown = 2;
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
        setState(() => _showCountdown = false);
        _startQuestionTimer();
      }
    });
  }

  void _startQuestionTimer() {
    _questionTimer?.cancel();
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 1) {
        setState(() => timeLeft--);
      } else {
        timer.cancel();
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      currentId++;
    });
    loadQuestionById(currentId);
  }

  void checkAnswer(String choice) {
    if (currentQuestion == null) return;

    final isCorrect = currentQuestion!.answers.contains(choice);

    setState(() {
      selectedAnswer = choice;
    });

    if (isCorrect) {
      score++;

      setState(() => _feedbackColor = const Color.fromARGB(172, 47, 255, 0));
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() => _feedbackColor = null);
        _nextQuestion();
      });
    } else {
      _shakeController.forward(from: 0);
      setState(() => _feedbackColor = Colors.red.withOpacity(0.6));
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() => _feedbackColor = null);
        _nextQuestion();
      });
    }
  }

  Future<void> saveScoreToFirebase() async {
    final userId = "demoUser";
    await FirebaseFirestore.instance.collection('scores').add({
      'userId': userId,
      'score': score,
      'timestamp': FieldValue.serverTimestamp(),
      'level': 'beginner',
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentQuestion == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final q = currentQuestion!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("English Tutorial", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _shakeController,
            builder: (context, child) {
              final offset = _shakeAnimation.value;
              return Transform.translate(
                offset: Offset(offset, 0),
                child: child,
              );
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                        value: currentId / totalQuestions,
                        backgroundColor: Colors.grey.shade300,
                        color: Colors.green,
                        minHeight: 10,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Time : $timeLeft",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                // แสดงรูปภาพถ้ามี
                if (q.image != null && q.image!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Image.network(
                      q.image!,
                      height: 200,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Text("Image load error");
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                Expanded(
                  child: Center(
                    child: Wrap(
                      spacing: 8,
                      alignment: WrapAlignment.center,
                      children: q.sentence.map((word) {
                        if (word == "__") {
                          if (selectedAnswer != null &&
                              q.answers.contains(selectedAnswer)) {
                            return Text(
                              selectedAnswer!,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(84, 159, 255, 163),
                              ),
                            );
                          }
                          return const Text(
                            "____",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 255, 17, 0),
                            ),
                          );
                        } else {
                          return Text(word,
                              style: const TextStyle(
                                  fontSize: 28, fontWeight: FontWeight.w500));
                        }
                      }).toList(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    children: q.choices.map((choice) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color.fromARGB(157, 87, 87, 87),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () => checkAnswer(choice),
                          child: Text(choice),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          if (_showCountdown)
            Container(
              color: const Color.fromARGB(255, 91, 0, 0).withOpacity(0.6),
              child: Center(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Text(
                    "$_countdown",
                    style: const TextStyle(
                      fontSize: 120,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          if (_feedbackColor != null)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              color: _feedbackColor,
              width: double.infinity,
              height: double.infinity,
            ),
        ],
      ),
    );
  }
}

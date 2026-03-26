import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';


class SentenceModel {
  final int id;
  final List<String> sentence;
  final List<String> choices;
  final List<String> answers;
  final String? image;
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
      image: data['image'],
    );
  }
}

class Advanced extends StatefulWidget {
  final String username;
  const Advanced({super.key, required this.username});
  

  @override
  State<Advanced> createState() => _AdvancedState();
}

class _AdvancedState extends State<Advanced> with SingleTickerProviderStateMixin {
  int currentId = 1;
  int totalQuestions = 1;
  int score = 0;

  SentenceModel? currentQuestion;
  String? selectedAnswer;

  Timer? _questionTimer;
  int timeLeft = 15;

  bool _showCountdown = true;
  int _countdown = 0;

  Color? _feedbackColor;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  late AudioPlayer _audioPlayer;
  late AudioPlayer _answerFeedbackPlayer;

  bool _isLoading = true;

  List<Color> buttonColors = [];

  @override
  void initState() {
    super.initState();

    _audioPlayer = AudioPlayer();
    _answerFeedbackPlayer = AudioPlayer();
    _audioPlayer.play(
      AssetSource('audio/pre.mp3'),
      mode: PlayerMode.mediaPlayer,
    );
    _audioPlayer.onPlayerComplete.listen((event) {
      _audioPlayer.setReleaseMode(ReleaseMode.loop);
      _audioPlayer.play(AssetSource('audio/Advanced.mp3'));
    });

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 40).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.elasticOut,
      ),
    );

    _loadTotalQuestionsAndFirst();
  }

  Future<void> _loadTotalQuestionsAndFirst() async {
    final snapshot = await FirebaseFirestore.instance.collection('advanced').get();
    totalQuestions = snapshot.docs.length;

    if (totalQuestions == 0) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    await loadQuestionById(currentId);
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    _shakeController.dispose();
    _audioPlayer.stop();
    _answerFeedbackPlayer.stop();
    super.dispose();
  }

  Future<void> loadQuestionById(int id) async {
    setState(() {
      _isLoading = true;
      selectedAnswer = null;
      _feedbackColor = null;
      timeLeft = 15;
      buttonColors = _generateRandomButtonColors();
    });

    final snapshot = await FirebaseFirestore.instance
        .collection('advanced')
        .where('id', isEqualTo: id)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        currentQuestion = SentenceModel.fromFirestore(snapshot.docs.first.data());
        _showCountdown = true;
        _countdown = 2;
        _isLoading = false;
      });

      _startCountdown();
    } else {
      setState(() {
        currentQuestion = null;
        _isLoading = false;
      });
    }
  }

  // สุ่มสีปุ่มไม่ซ้ำ
  List<Color> _generateRandomButtonColors() {
    List<Color> colors = [];
    List<Color> possibleColors = [
      const Color.fromARGB(255, 255, 17, 0),
      const Color.fromARGB(255, 0, 140, 255),
      const Color.fromARGB(255, 3, 255, 11),
      const Color.fromARGB(255, 255, 230, 0),
    ];

    Random random = Random();
    while (colors.length < 4) {
      Color randomColor = possibleColors[random.nextInt(possibleColors.length)];
      if (!colors.contains(randomColor)) {
        colors.add(randomColor);
      }
    }
    return colors;
  }

  void _showFinishedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(135, 33, 33, 33),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: const [
              Icon(Icons.emoji_events, color: Color.fromARGB(255, 255, 255, 254), size: 32),
              SizedBox(width: 10),
              Text(
                "END OF TEST",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            "Score: $score / $totalQuestions",
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.amber,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                goBack();
              },
              child: const Text(
                "กลับหน้าเดิม",
                style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void goBack() {
    // TODO: ใส่โค้ดกลับหน้าเดิม
  }

  void _startCountdown() {
  Timer.periodic(const Duration(seconds: 1), (timer) {
    if (_countdown > 1) {
      setState(() => _countdown--);
    } else {
      timer.cancel();
      setState(() {
        _showCountdown = false;
        timeLeft = 15; 
      });
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
    if (currentId < totalQuestions) {
      setState(() {
        currentId++;
      });
      loadQuestionById(currentId);
    } else {
      _showFinishedDialog();
    }
  }

    void checkAnswer(String choice) {
    if (currentQuestion == null) return;

    final isCorrect = currentQuestion!.answers.contains(choice);

    setState(() {
      selectedAnswer = choice;
    });

    if (currentId == totalQuestions) {
      // คำถามสุดท้าย → ไม่ต้องเล่นเสียงสั่นอะไร
      setState(() {
        _feedbackColor = isCorrect
            ? const Color.fromARGB(136, 13, 255, 0).withOpacity(0.7)
            : Colors.red.withOpacity(0.6);
      });

      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() => _feedbackColor = null);
        _nextQuestion();
      });
    } else {
      if (isCorrect) {
        score++;
        _playFeedbackSound('correctforAdvanced.mp3');
        setState(() => _feedbackColor = const Color.fromARGB(136, 13, 255, 0).withOpacity(0.7));
        // 🔹 อัปเดตคะแนนสะสมใน Firestore
  final userId = widget.username; 
  final docRef = FirebaseFirestore.instance.collection('scores').doc(userId);

  FirebaseFirestore.instance.runTransaction((transaction) async {
    final snapshot = await transaction.get(docRef);

    if (!snapshot.exists) {
      transaction.set(docRef, {
        'userId': widget.username,
        'score': score,
        'level': 'Advanced',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      
      final newScore = (snapshot['score'] ?? 0) + 1;
      transaction.update(docRef, {
        'score': newScore,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

  });
      } else {
        _playFeedbackSound('incorrectforAdvanced.mp3');
        _shakeController.forward(from: 0); 
        setState(() => _feedbackColor = Colors.red.withOpacity(0.6));
      }

      Future.delayed(const Duration(milliseconds: 700), () {
        setState(() => _feedbackColor = null);
        _nextQuestion();
      });
    }
  }


  Future<void> _playFeedbackSound(String soundFile) async {
    if (_answerFeedbackPlayer.state == PlayerState.playing) {
      await _answerFeedbackPlayer.stop();
    }
    await _answerFeedbackPlayer.play(AssetSource('audio/$soundFile'));
  }



  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Color.fromARGB(221, 0, 255, 13)),
          ),
        ),
      );
    }

    if (currentQuestion == null) {
      return Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: const Center(
          child: Text(
            "ไม่มีคำถามให้แสดง",
            style: TextStyle(fontSize: 20, color: Colors.black87),
          ),
        ),
      );
    }

    final q = currentQuestion!;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Advanced Test",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: const Color.fromARGB(255, 217, 0, 255),
        centerTitle: true,
        elevation: 6,
        shadowColor: const Color.fromARGB(134, 112, 0, 101),
      ),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _shakeController,
            builder: (context, child) {
              final double progress = _shakeController.value;
              final double offset = sin(progress * pi * 20) * _shakeAnimation.value * (1 - progress);
              return Transform.translate(
                offset: Offset(offset, 0),
                child: child,
              );
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: LinearProgressIndicator(
                              value: currentId / totalQuestions,
                              backgroundColor: Colors.black12,
                              color: const Color.fromARGB(221, 72, 255, 0),
                              minHeight: 40,
                            ),
                          ),
                          Text(
                            "$currentId /$totalQuestions",
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "TIME: $timeLeft ",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const Icon(
                            Icons.timer,
                            color: Colors.black87,
                            size: 15,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: q.sentence.map((word) {
                          if (word == "__") {
                            if (selectedAnswer != null && q.answers.contains(selectedAnswer)) {
                              return AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 400),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 0),
                                    )
                                  ],
                                ),
                                child: Text(selectedAnswer!),
                              );
                            }
                            return const Text(
                              "____",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            );
                          } else {
                            return Text(
                              word,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            );
                          }
                        }).toList(),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: MediaQuery.of(context).size.width /
                        (MediaQuery.of(context).size.height / 4),
                    physics: const NeverScrollableScrollPhysics(),
                    children: q.choices.asMap().entries.map((entry) {
                      final choice = entry.value;
                      final index = entry.key;
                      final bool isSelected = selectedAnswer == choice;
                      final bool isCorrect = q.answers.contains(choice);

                      Color bgColor = buttonColors[index];
                      Color textColor;

                      if (selectedAnswer == null) {
                        textColor = const Color.fromARGB(221, 0, 0, 0);
                      } else if (isSelected) {
                        if (isCorrect) {
                          textColor = const Color.fromARGB(255, 0, 255, 72);
                        } else {
                          textColor = Colors.white;
                        }
                      } else if (isCorrect) {
                        textColor = Colors.white;
                      } else {
                        textColor = Colors.black54;
                      }

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.black26,
                            width: 1.2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    offset: const Offset(0, 3),
                                    blurRadius: 6,
                                  )
                                ]
                              : [],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: selectedAnswer == null ? () => checkAnswer(choice) : null,
                          child: Text(
                            choice,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20)
              ],
            ),
          ),
          if (_showCountdown)
            Container(
              color: Colors.black87.withOpacity(0.85),
              child: Center(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Text(
                      "$_countdown",
                      key: ValueKey<int>(_countdown),
                      style: const TextStyle(
                        fontSize: 140,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 20,
                            color: Color.fromARGB(255, 255, 255, 255),
                            offset: Offset(0, 0),
                          )
                        ],
                      ),
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

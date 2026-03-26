import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'Beginner.dart';
import 'Intermediate.dart';
import 'Advanced.dart';

class TestMenu extends StatefulWidget {
  final String username;
  const TestMenu({super.key, required this.username});


  @override
  State<TestMenu> createState() => _TestMenuState();
}

class _TestMenuState extends State<TestMenu>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _bgController;
  late AnimationController _particleController;
  late Animation<double> _pulseAnimation;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _pulseController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);

    _pulseAnimation =
        Tween<double>(begin: 1.0, end: 1.05).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _bgController =
        AnimationController(vsync: this, duration: const Duration(seconds: 15))
          ..repeat();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bgController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _startTest(BuildContext ctx, String level) {
    Widget page;
    switch (level) {
      case 'Beginner':
        page = Beginner(username: widget.username);
        break;
      case 'Intermediate':
        page = Intermediate(username: widget.username);
        break;
      case 'Advanced':
        page = Advanced(username: widget.username);
        break;
      default:
        page = Intermediate(username: widget.username);
    }

    Navigator.of(ctx).push(PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 800),
      transitionsBuilder: (context, anim, secAnim, child) {
        final fade = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: anim, curve: Curves.easeInOut),
        );
        final scale = Tween<double>(begin: 0.8, end: 1).animate(
          CurvedAnimation(parent: anim, curve: Curves.elasticOut),
        );
        final slide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut));

        return FadeTransition(
          opacity: fade,
          child: ScaleTransition(
            scale: scale,
            child: SlideTransition(position: slide, child: child),
          ),
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Choose Level"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildAnimatedBackground(isDark),
          _buildParticles(),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: Container(color: Colors.black.withOpacity(0.2)),
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAnimatedTitle(isDark),
                  const SizedBox(height: 50),
                  _buildAnimatedButton(
                    context,
                    label: 'Beginner (60 ques, 1 hr)',
                    onTap: () => _startTest(context, 'Beginner'),
                    isDark: isDark,
                    icon: Icons.star_border,
                  ),
                  const SizedBox(height: 24),
                  _buildAnimatedButton(
                    context,
                    label: 'Intermediate (60 ques, 1 hr)',
                    onTap: () => _startTest(context, 'Intermediate'),
                    isDark: isDark,
                    icon: Icons.auto_graph,
                  ),
                  const SizedBox(height: 24),
                  _buildAnimatedButton(
                    context,
                    label: 'Advanced (60 ques, 1 hr)',
                    onTap: () => _startTest(context, 'Advanced'),
                    isDark: isDark,
                    icon: Icons.local_fire_department,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground(bool isDark) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, _) {
        final t = _bgController.value;
        final colors = isDark
            ? [
                Color.lerp(Colors.indigo.shade900, Colors.deepPurple, t)!,
                Color.lerp(Colors.black, Colors.blueGrey.shade900, t)!,
              ]
            : [
                Color.lerp(Colors.blue.shade200, Colors.pink.shade200, t)!,
                Color.lerp(Colors.yellow.shade200, Colors.orange.shade200, t)!,
              ];

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, _) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _ParticlePainter(
            animationValue: _particleController.value,
            random: _random,
          ),
        );
      },
    );
  }

  Widget _buildAnimatedTitle(bool isDark) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, 10 * sin(_bgController.value * 2 * pi)),
          child: Text(
            "Choose Your Level",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(2, 2),
                )
              ],
              letterSpacing: 1.5,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedButton(BuildContext context,
      {required String label,
      required VoidCallback onTap,
      required bool isDark,
      required IconData icon}) {
    final textColor = isDark ? Colors.white : Colors.black87;

    return ScaleTransition(
      scale: _pulseAnimation,
      child: GestureDetector(
        onTap: () {
          _buttonRippleEffect(context, onTap);
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              colors: isDark
                  ? [Colors.deepPurpleAccent, Colors.indigo]
                  : [Colors.pinkAccent, Colors.orangeAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.deepPurpleAccent.withOpacity(0.6)
                    : Colors.orange.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: onTap,
            icon: Icon(icon, color: textColor),
            label: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 1.1,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _buttonRippleEffect(BuildContext context, VoidCallback onTap) async {
    await Future.delayed(const Duration(milliseconds: 120));
    onTap();
  }
}

class _ParticlePainter extends CustomPainter {
  final double animationValue;
  final Random random;

  _ParticlePainter({required this.animationValue, required this.random});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.05);
    const particleCount = 40;

    for (int i = 0; i < particleCount; i++) {
      final dx = (size.width * ((i / particleCount) + animationValue)) %
          size.width;
      final dy = (size.height * ((i / particleCount) + animationValue)) %
          size.height;

      canvas.drawCircle(Offset(dx, dy), 6 + random.nextDouble() * 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}

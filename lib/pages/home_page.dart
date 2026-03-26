// home_page.dart
// Keep constructor signature and navigation logic intact.
// UI: pastel animated blobs, progress animation, improved feature cards with micro interactions.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'learn_page.dart';
import 'test_menu.dart';
import 'profile_page.dart';
import 'statistic_page.dart';
import 'score_page.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onLogout;
  final void Function(bool) onToggleTheme;
  final bool isDark;
  final String currentUsername;

  const HomePage({
    super.key,
    required this.onLogout,
    required this.onToggleTheme,
    required this.isDark,
    required this.currentUsername,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? currentUserData;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  // gamification fields
  int _level = 1;
  int _exp = 0;
  int _badgesCount = 0;

  // animate exp changes
  double _animatedExpPercent = 0.0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.0, end: 6.0)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('users') ?? '{}';
    final Map<String, dynamic> users = jsonDecode(raw);
    if (users.containsKey(widget.currentUsername)) {
      setState(() {
        currentUserData = Map<String, dynamic>.from(users[widget.currentUsername]);

        final levelRaw = currentUserData?['level'];
        _level = levelRaw is int ? levelRaw : int.tryParse(levelRaw?.toString() ?? '') ?? 1;

        final expRaw = currentUserData?['exp'];
        _exp = expRaw is int ? expRaw : int.tryParse(expRaw?.toString() ?? '') ?? 0;

        final badgesRaw = currentUserData?['badges'];
        _badgesCount = badgesRaw is List ? badgesRaw.length : 0;
      });

      final expPercent = ((_exp % 100) / 100.0).clamp(0.0, 1.0);
      setState(() => _animatedExpPercent = 0.0);
      Future.delayed(const Duration(milliseconds: 80), () {
        setState(() => _animatedExpPercent = expPercent);
      });
    } else {
      setState(() {
        currentUserData = null;
        _level = 1;
        _exp = 0;
        _badgesCount = 0;
        _animatedExpPercent = 0.0;
      });
    }
  }

  void _openDrawerItem(String key) {
    if (key == 'profile') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(username: widget.currentUsername)));
    } else if (key == 'stats') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const StatisticPage()));
    } else if (key == 'score') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryPage(username: widget.currentUsername)));
    }
  }

  Route _animatedRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, anim, sec) => page,
      transitionDuration: const Duration(milliseconds: 420),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        final slide = Tween<Offset>(begin: const Offset(0.12, 0), end: Offset.zero).animate(curved);
        final fade = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
        return SlideTransition(position: slide, child: FadeTransition(opacity: fade, child: child));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pastelBlue = const Color(0xFF9AD3E6);
    final pastelPink = const Color(0xFFF4C2C2);
    final pastelGreen = const Color(0xFFD6F5D6);

    ImageProvider? avatar;
    if (currentUserData != null && currentUserData!['photo'] != null) {
      try {
        avatar = MemoryImage(base64Decode(currentUserData!['photo']));
      } catch (_) {
        avatar = null;
      }
    }

    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [pastelBlue.withOpacity(0.25), pastelPink.withOpacity(0.18)]),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0,6))],
                ),
                child: Row(
                  children: [
                    Hero(
                      tag: 'profile-avatar',
                      child: CircleAvatar(
                        radius: 32,
                        backgroundImage: avatar,
                        child: avatar == null ? const Icon(Icons.person, size: 36,color: Colors.white) : null,
                        backgroundColor: pastelBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.currentUsername, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(12)),
                                child: Text('Level $_level', style: const TextStyle(fontSize: 12)),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(12)),
                                child: Text('Badges $_badgesCount', style: const TextStyle(fontSize: 12)),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ListTile(leading: const Icon(Icons.person), title: const Text('โปรไฟล์'), onTap: () => _openDrawerItem('profile')),
              ListTile(leading: const Icon(Icons.bar_chart), title: const Text('สถิติ'), onTap: () => _openDrawerItem('stats')),
              ListTile(leading: const Icon(Icons.history), title: const Text('ประวัติผลสอบ'), onTap: () => _openDrawerItem('score')),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('ออกจากระบบ'),
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isLoggedIn', false);
                  widget.onLogout();
                },
              ),
            ],
          ),
        ),
      ),

      body: Stack(
        children: [
          // animated background blobs
          Positioned.fill(child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final offset = _pulseAnim.value;
              return CustomPaint(painter: _BlobsPainter(offset));
            },
          )),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(ctx).openDrawer())),
                      Expanded(
                        child: Center(
                          child: _ProgressCard(
                            level: _level,
                            expPercent: _animatedExpPercent,
                            avatar: avatar,
                            username: widget.currentUsername,
                            pastelBlue: pastelBlue,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(onPressed: () => Navigator.push(context, _animatedRoute(const StatisticPage())), icon: const Icon(Icons.auto_graph)),
                          GestureDetector(
                            onTap: () => setState(() {}),
                            child: CircleAvatar(backgroundImage: avatar, child: avatar == null ? const Icon(Icons.person) : null),
                          ),
                        ],
                      )
                    ],
                  ),

                  const SizedBox(height: 18),

                  // grid scrollable
                  Expanded(
                    child: SingleChildScrollView(
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.03,
                        children: [
                          _FeatureCard(
                            title: 'เรียนรู้',
                            subtitle: 'บทเรียนแบบละเอียด',
                            icon: Icons.menu_book,
                            color: pastelBlue,
                            onTap: () => Navigator.push(context, _animatedRoute(LearnPage(onCompleteLesson: (m) {}))),
                          ),
                          _FeatureCard(
                            title: 'สอบ',
                            subtitle: 'แบบทดสอบ (เก็บ EXP)',
                            icon: Icons.quiz,
                            color: pastelPink,
                            onTap: () => Navigator.push(context, _animatedRoute(TestMenu(username: widget.currentUsername,))),
                          ),
                          _FeatureCard(
                            title: 'โปรไฟล์',
                            subtitle: 'แก้ไขข้อมูลส่วนตัว',
                            icon: Icons.person,
                            color: pastelGreen,
                            onTap: () => Navigator.push(context, _animatedRoute(ProfilePage(username: widget.currentUsername))),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('ธีม'),
                      Switch(value: widget.isDark, onChanged: widget.onToggleTheme),
                      const SizedBox(width: 12),
                      TextButton.icon(onPressed: () {}, icon: const Icon(Icons.info_outline), label: const Text('เวอร์ชัน 1.0')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ✅ แก้ dialog ไม่ให้ล้นจอ
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final pastelBlueLocal = const Color(0xFF9AD3E6);
          final pastelPinkLocal = const Color(0xFFF4C2C2);
          showDialog(
            context: context,
            builder: (c) {
              return Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [pastelBlueLocal, pastelPinkLocal]),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.emoji_events, color: Colors.white, size: 36),
                        ),
                        const SizedBox(height: 12),
                        const Text('Keep going!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        const Text('ทำแบบฝึกหัดเพื่อเก็บ EXP และรับ Badge', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        child: const Icon(Icons.emoji_events),
      ),
    );
  }
}

/// Painter for background blobs
class _BlobsPainter extends CustomPainter {
  final double offset;
  _BlobsPainter(this.offset);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    paint.shader = RadialGradient(colors: [const Color(0xFFEEF9FF).withOpacity(0.85), Colors.transparent]).createShader(
      Rect.fromCircle(center: Offset(size.width * 0.12, size.height * 0.12 + offset), radius: 180),
    );
    canvas.drawCircle(Offset(size.width * 0.12, size.height * 0.12 + offset), 160, paint);

    paint.shader = RadialGradient(colors: [const Color(0xFFFFF0F5).withOpacity(0.75), Colors.transparent]).createShader(
      Rect.fromCircle(center: Offset(size.width * 0.9, size.height * 0.78 - offset), radius: 220),
    );
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.78 - offset), 160, paint);
  }

  @override
  bool shouldRepaint(covariant _BlobsPainter old) => old.offset != offset;
}

/// Progress Card
class _ProgressCard extends StatelessWidget {
  final int level;
  final double expPercent;
  final ImageProvider? avatar;
  final String username;
  final Color pastelBlue;

  const _ProgressCard({required this.level, required this.expPercent, required this.avatar, required this.username, required this.pastelBlue});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0,8))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: expPercent),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
                builder: (context, value, _) {
                  return SizedBox(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(value: value, strokeWidth: 6, color: pastelBlue, backgroundColor: Colors.grey.shade200),
                  );
                },
              ),
              CircleAvatar(radius: 24, backgroundImage: avatar, child: avatar == null ? const Icon(Icons.person) : null),
            ],
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(username, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('${(expPercent * 100).round()}% to next', style: const TextStyle(color: Colors.black54, fontSize: 12)),
            const SizedBox(height: 6),
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)), child: Text('Level $level')),
              const SizedBox(width: 8),
            ])
          ])
        ],
      ),
    );
  }
}

/// Feature card
class _FeatureCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({required this.title, required this.subtitle, required this.icon, required this.color, required this.onTap});

  @override
  State<_FeatureCard> createState() => __FeatureCardState();
}

class __FeatureCardState extends State<_FeatureCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 160));
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    setState(() => _pressed = true);
    _ctrl.forward();
  }

  void _onTapUp(_) {
    _ctrl.reverse().then((_) {
      setState(() => _pressed = false);
      widget.onTap();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: () {
          _ctrl.reverse();
          setState(() => _pressed = false);
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.06)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(_pressed ? 0.02 : 0.04), blurRadius: 10, offset: const Offset(0,8))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CircleAvatar(backgroundColor: widget.color, radius: 20, child: Icon(widget.icon, color: Colors.white)),
            const Spacer(),
            Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(widget.subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ]),
        ),
      ),
    );
  }
}

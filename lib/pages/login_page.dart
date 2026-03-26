// login_page.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'register_page.dart';
import '../error/validators.dart';
import 'authenticationService.dart';

/// LoginPage (UI-heavy, animated, keeps logic calls and props intact)
class LoginPage extends StatefulWidget {
  final void Function(bool) onToggleTheme;
  final bool isDark;
  final void Function(String username) onLogin;

  const LoginPage({
    super.key,
    required this.onToggleTheme,
    required this.isDark,
    required this.onLogin,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {

  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _loading = false;
  bool _showPassword = false;

  // background moving shapes controller
  late AnimationController _bgController;
  late Animation<double> _blobAnim;

  // press animation for buttons
  late AnimationController _pressController;
  late Animation<double> _pressAnim;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 10));
    _blobAnim = Tween<double>(begin: -40.0, end: 40.0).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));
    _bgController.repeat(reverse: true);

    _pressController = AnimationController(vsync: this, duration: const Duration(milliseconds: 140));
    _pressAnim = Tween<double>(begin: 1.0, end: 0.96).animate(CurvedAnimation(parent: _pressController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    _bgController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _onPressDown() => _pressController.forward();
  void _onPressUp() => _pressController.reverse();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final username = _userCtrl.text.trim();
    final password = _passCtrl.text.trim();

    final auth = Authenticationservice();
    final success = await auth.login(username, password);

    setState(() => _loading = false);

    if (success) {
      widget.onLogin(username);
    } else {
      _showMsg('ชื่อผู้ใช้/รหัสผ่านไม่ถูกต้อง');
    }
  }

  void _showMsg(String s) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));

  void _socialSign(String name) async {
    final auth = Authenticationservice();

    if (name == 'Google') {
      final user = await auth.signInWithGoogle();
      if (user != null) {
        widget.onLogin(user.email ?? user.displayName ?? 'Google User');
      } else {
        _showMsg('เข้าสู่ระบบด้วย Google ไม่สำเร็จ');
      }
    } else if (name == 'Facebook') {
      final user = await auth.signInWithFacebook();
      if (user != null) {
        widget.onLogin(user.email ?? user.displayName ?? 'Facebook User');
      } else {
        _showMsg('เข้าสู่ระบบด้วย Facebook ไม่สำเร็จ');
      }
    } else {
      _showMsg('$name sign-in is a placeholder in demo.');
    }
  }

  Route _createRegisterRoute() {
    // keep navigation target same but provide nicer transition
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (context, animation, secondaryAnimation) => const RegisterPage(),
      transitionsBuilder: (context, anim, secAnim, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        final slide = Tween<Offset>(begin: const Offset(0.0, 0.12), end: Offset.zero).animate(curved);
        final fade = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
        return SlideTransition(
          position: slide,
          child: FadeTransition(opacity: fade, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color.fromARGB(255, 30, 30, 30);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF0F1724), const Color(0xFF0B1220)]
                    : [const Color(0xFFE8F6FF), const Color(0xFFFFF6F8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // animated decorative blobs
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              final v = _blobAnim.value;
              return Stack(
                children: [
                  Positioned(
                    top: 60 + v * 0.2,
                    left: -40 + v * 0.6,
                    child: _DecorBlob(size: 160, colors: const [Color(0xFF9AD3E6), Color(0xFFF4C2C2)], blur: 40),
                  ),
                  Positioned(
                    bottom: 40 - v * 0.4,
                    right: -30 - v * 0.5,
                    child: _DecorBlob(size: 220, colors: const [Color(0xFFD6F5D6), Color(0xFFFFF0F5)], blur: 34),
                  ),
                ],
              );
            },
          ),

          // glass overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.35)
                  : Colors.white.withOpacity(0.12),
            ),
          ),

          // main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // header / title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _LogoBadge(),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Learn English', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: textColor)),
                            const SizedBox(height: 4),
                            Text('ฝึกภาษาแบบสนุกและชัด', style: TextStyle(color: textColor.withOpacity(0.75))),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 26),

                    // animated login card
                    _AnimatedGlassCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // email
                            _buildInputField(
                              controller: _userCtrl,
                              hint: 'Email',
                              prefix: Icons.email_outlined,
                              textColor: textColor,
                              validator: Validators.required(errorMessage: 'กรุณากรอกอีเมล'),
                            ),
                            const SizedBox(height: 12),
                            // password
                            _buildInputField(
                              controller: _passCtrl,
                              hint: 'Password',
                              prefix: Icons.lock_outline,
                              obscure: !_showPassword,
                              textColor: textColor,
                              suffixWidget: IconButton(
                                icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility, color: textColor.withOpacity(0.7)),
                                onPressed: () => setState(() => _showPassword = !_showPassword),
                              ),
                              validator: Validators.multiValidator([
                                Validators.required(errorMessage: 'กรุณากรอกรหัสผ่าน'),
                                Validators.minValue(minValue: 6, errorMessage: 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร'),
                              ]),
                            ),

                            const SizedBox(height: 14),

                            // login + register buttons (animated press)
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTapDown: (_) => _onPressDown(),
                                    onTapUp: (_) {
                                      _onPressUp();
                                      _login();
                                    },
                                    onTapCancel: _onPressUp,
                                    child: AnimatedBuilder(
                                      animation: _pressController,
                                      builder: (context, child) {
                                        final scale = _pressAnim.value;
                                        return Transform.scale(
                                          scale: scale,
                                          child: Container(
                                            height: 52,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(colors: [const Color(0xFF9AD3E6), const Color(0xFF6EC1D7)]),
                                              borderRadius: BorderRadius.circular(14),
                                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12, offset: const Offset(0,8))],
                                            ),
                                            child: Center(
                                              child: _loading
                                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4))
                                                  : const Text('Login', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => Navigator.of(context).push(_createRegisterRoute()),
                                    child: Container(
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: Colors.grey.withOpacity(0.08)),
                                      ),
                                      child: Center(child: Text('Register', style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold))),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // social row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _SocialButton(icon: Icons.g_mobiledata, color: Colors.redAccent, label: 'Google', onTap: () => _socialSign('Google')),
                                const SizedBox(width: 10),
                                _SocialButton(icon: Icons.facebook, color: Colors.blue, label: 'Facebook', onTap: () => _socialSign('Facebook')),
                                const SizedBox(width: 10),
                                _SocialButton(icon: Icons.email, color: Colors.orange, label: 'Gmail', onTap: () => _socialSign('Gmail')),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // theme switcher compact
                            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              const Text('🌞'),
                              Switch(value: widget.isDark, onChanged: widget.onToggleTheme),
                              const Text('🌙'),
                            ]),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // footer micro-help
                    Text('ปลอดภัย ใช้งานง่าย — เก็บความคืบหน้าในเครื่องคุณ', style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData prefix,
    bool obscure = false,
    Widget? suffixWidget,
    required Color textColor,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        prefixIcon: Icon(prefix, color: textColor.withOpacity(0.85)),
        suffixIcon: suffixWidget,
        hintText: hint,
        hintStyle: TextStyle(color: textColor.withOpacity(0.55)),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.04) : Colors.white.withOpacity(0.6),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: validator,
    );
  }
}

/// small reusable widgets
class _DecorBlob extends StatelessWidget {
  final double size;
  final List<Color> colors;
  final double blur;
  const _DecorBlob({required this.size, required this.colors, this.blur = 30});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: RadialGradient(colors: colors),
        borderRadius: BorderRadius.circular(size * 0.5),
        boxShadow: [BoxShadow(color: colors.last.withOpacity(0.18), blurRadius: blur, spreadRadius: 8)],
      ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF9AD3E6), Color(0xFFF4C2C2)]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 10, offset: const Offset(0,6))],
      ),
      child: const Icon(Icons.language, color: Colors.white, size: 30),
    );
  }
}

class _AnimatedGlassCard extends StatefulWidget {
  final Widget child;
  const _AnimatedGlassCard({required this.child});

  @override
  State<_AnimatedGlassCard> createState() => _AnimatedGlassCardState();
}

class _AnimatedGlassCardState extends State<_AnimatedGlassCard> with SingleTickerProviderStateMixin {
  late AnimationController _ani;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ani = AnimationController(vsync: this, duration: const Duration(milliseconds: 560));
    _scale = Tween<double>(begin: 0.98, end: 1.0).animate(CurvedAnimation(parent: _ani, curve: Curves.elasticOut));
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ani, curve: Curves.easeIn));
    _ani.forward();
  }

  @override
  void dispose() {
    _ani.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: FadeTransition(
        opacity: _fade,
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.03) : Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0,8))],
            border: Border.all(color: Colors.grey.withOpacity(0.06)),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  const _SocialButton({required this.icon, required this.color, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(10)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 13)),
        ]),
      ),
    );
  }
}

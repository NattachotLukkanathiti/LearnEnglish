// register_page.dart
// Preserves logic: calls Authenticationservice().register(email, password)
// UI: multi-step animated form, glass card, background hero image, animated result dialog.
// Keep constructor/class name the same as original file.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'authenticationService.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
  String email = '';
  String password = '';
  String confirm = '';
  bool isLoading = false;
  bool agreed = false;
  String? _error;

  // animation controllers for multi-step
  late PageController _pageController;
  int _page = 0;

  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _entranceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnimation = CurvedAnimation(parent: _entranceController, curve: Curves.easeIn);
    _scaleAnimation = Tween<double>(begin: 0.98, end: 1.0).animate(CurvedAnimation(parent: _entranceController, curve: Curves.elasticOut));
    _entranceController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _showResultDialog(bool success) {
    // Keep behavior same as previous: show dialog (but now with prettier UI)
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "ResultDialog",
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.center,
          child: Material(
            color: Colors.transparent,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 360,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: success ? Colors.green.shade600 : Colors.red.shade600,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 20, offset: const Offset(0,10))],
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(success ? Icons.check_circle : Icons.error, size: 56, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(success ? "🎉 ลงทะเบียนสำเร็จ!" : "❌ ล้มเหลว", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 8),
                  Text(success ? "คุณสามารถเข้าสู่ระบบได้แล้ว" : "เกิดข้อผิดพลาด กรุณาลองอีกครั้ง", style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: Colors.white24), child: const Text('ตกลง', style: TextStyle(color: Colors.white))),
                ]),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(opacity: anim1, child: SlideTransition(position: Tween(begin: const Offset(0,0.06), end: Offset.zero).animate(anim1), child: child));
      },
      transitionDuration: const Duration(milliseconds: 360),
    );
  }

  void _nextStep() {
    if (_page == 0) {
      // validate email field
      if (email.trim().isEmpty) {
        setState(() => _error = 'กรุณากรอกอีเมล');
        return;
      }
    } else if (_page == 1) {
      if (password.length < 6) {
        setState(() => _error = 'รหัสผ่านอย่างน้อย 6 ตัว');
        return;
      }
      if (confirm != password) {
        setState(() => _error = 'รหัสผ่านไม่ตรงกัน');
        return;
      }
    }
    setState(() {
      _error = null;
      _page = (_page + 1).clamp(0, 2);
      _pageController.animateToPage(_page, duration: const Duration(milliseconds: 420), curve: Curves.easeOut);
    });
  }

  void _prevStep() {
    setState(() {
      _error = null;
      _page = (_page - 1).clamp(0, 2);
      _pageController.animateToPage(_page, duration: const Duration(milliseconds: 320), curve: Curves.easeOut);
    });
  }

  void _register() async {
    if (!agreed) {
      setState(() => _error = "ต้องยอมรับข้อกำหนดการใช้งาน");
      return;
    }

    setState(() { isLoading = true; _error = null; });

    bool success = await Authenticationservice().register(email.trim(), password);

    setState(() { isLoading = false; });

    _showResultDialog(success);
    if (success) {
      // do not alter navigation logic beyond popping like before
      Future.delayed(const Duration(milliseconds: 800), () => Navigator.pop(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context))),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // background image
          Image.asset('assets/image/fuji.jpeg', fit: BoxFit.cover),
          BackdropFilter(filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18), child: Container(color: isDark ? Colors.black.withOpacity(0.45) : Colors.white.withOpacity(0.08))),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 6),
                      // big title
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                          Text('สร้างบัญชีใหม่', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('เริ่มเรียนภาษาอังกฤษกับเราได้ทันที', style: TextStyle(color: Colors.white70)),
                        ]),
                      ),
                      const SizedBox(height: 18),

                      // step indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            _StepDot(active: _page >= 0, label: '1'),
                            const SizedBox(width: 8),
                            Expanded(child: Divider(color: Colors.white24)),
                            const SizedBox(width: 8),
                            _StepDot(active: _page >= 1, label: '2'),
                            const SizedBox(width: 8),
                            Expanded(child: Divider(color: Colors.white24)),
                            const SizedBox(width: 8),
                            _StepDot(active: _page >= 2, label: '3'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.92),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0,8))],
                          ),
                          child: PageView(
                            controller: _pageController,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              // step 0: email
                              _stepEmail(),
                              // step 1: password
                              _stepPassword(),
                              // step 2: confirm + policy
                              _stepConfirm(),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),
                      // navigation buttons
                      Row(
                        children: [
                          if (_page > 0)
                            OutlinedButton(onPressed: _prevStep, child: const Text('ย้อนกลับ')),
                          const Spacer(),
                          if (_page < 2)
                            ElevatedButton(
                              onPressed: _nextStep,
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12)),
                              child: const Text('ถัดไป'),
                            )
                          else
                            ElevatedButton(
                              onPressed: isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12)),
                              child: isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('ลงทะเบียน'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepEmail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('อีเมล', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          onChanged: (v) => email = v,
          validator: (v) => v == null || v.isEmpty ? 'กรุณากรอกอีเมล' : null,
          decoration: InputDecoration(prefixIcon: const Icon(Icons.email), hintText: 'you@example.com'),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 10),
        const Text('โปรดใช้เมลที่ใช้งานได้จริงเพื่อรับการยืนยัน', style: TextStyle(color: Colors.black54)),
      ],
    );
  }

  Widget _stepPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ตั้งรหัสผ่าน', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          onChanged: (v) => password = v,
          obscureText: true,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.lock), hintText: 'รหัสผ่านอย่างน้อย 6 ตัว'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          onChanged: (v) => confirm = v,
          obscureText: true,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.lock_clock), hintText: 'ยืนยันรหัสผ่าน'),
        ),
        const SizedBox(height: 10),
        const Text('เคล็ดลับ: ใช้ตัวอักษร, ตัวเลข และอักขระพิเศษเพื่อความปลอดภัย', style: TextStyle(color: Colors.black54)),
      ],
    );
  }

  Widget _stepConfirm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ข้อกำหนดการใช้งาน', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            child: Text(
              'เมื่อกดยืนยัน คุณยอมรับข้อกำหนดการใช้งานของเรา ข้อมูลจะถูกเก็บในเครื่องเพื่อให้ประสบการณ์เป็นไปอย่างต่อเนื่อง...',
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ),
        Row(
          children: [
            Checkbox(value: agreed, onChanged: (v) => setState(() => agreed = v ?? false)),
            const SizedBox(width: 6),
            Expanded(child: Text('ฉันยอมรับข้อกำหนดและเงื่อนไข')),
          ],
        ),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  final bool active;
  final String label;
  const _StepDot({required this.active, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.white24,
        borderRadius: BorderRadius.circular(10),
        boxShadow: active ? [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8)] : null,
      ),
      child: Center(child: Text(label, style: TextStyle(color: active ? Colors.black : Colors.white70, fontWeight: FontWeight.bold))),
    );
  }
}

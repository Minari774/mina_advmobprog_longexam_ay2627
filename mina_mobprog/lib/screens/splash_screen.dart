import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mina_mobprog/constants.dart';
import 'package:mina_mobprog/models/user.dart';
import 'package:mina_mobprog/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _goNext();
  }

  Future<void> _goNext() async {
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();

    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!mounted) return;

    if (isLoggedIn) {
      final String? userJson = prefs.getString('user');

      if (userJson != null) {
        try {
          final User user = User.fromJson(
            Map<String, dynamic>.from(jsonDecode(userJson)),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
          );

          return;
        } catch (e) {
          await prefs.remove('isLoggedIn');
          await prefs.remove('user');
        }
      }
    }

    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: FB_PRIMARY,
                borderRadius: BorderRadius.circular(36),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x336A1B9A),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Text(
                'LM',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 58,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
            SizedBox(height: ScreenUtil().setHeight(24)),
            const Text(
              'PesBok',
              style: TextStyle(
                color: FB_PRIMARY,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: ScreenUtil().setHeight(32)),

            const HexagonDotLoader(color: FB_PRIMARY, size: 10),
          ],
          ),
        ),
      ),
    );
  }
}

class HexagonDotLoader extends StatefulWidget {
  final Color color;
  final double size;

  const HexagonDotLoader({super.key, required this.color, required this.size});

  @override
  State<HexagonDotLoader> createState() => _HexagonDotLoaderState();
}

class _HexagonDotLoaderState extends State<HexagonDotLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<double> _angles = [
    0,
    math.pi / 3,
    2 * math.pi / 3,
    math.pi,
    4 * math.pi / 3,
    5 * math.pi / 3,
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return Stack(
            alignment: Alignment.center,
            children: List.generate(6, (index) {
              final progress = (_controller.value + index / 6) % 1.0;

              final scale = 0.5 + (math.sin(progress * 2 * math.pi) + 1) / 4;

              return Transform.translate(
                offset: Offset(
                  math.cos(_angles[index]) * 20,
                  math.sin(_angles[index]) * 20,
                ),
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      color: widget.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _scale, _fade;
  Timer? _completionTimer;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _scale = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _c, curve: const Interval(0, 0.6, curve: Curves.elasticOut)));
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _c, curve: const Interval(0.3, 0.8, curve: Curves.easeIn)));
    _c.forward();
    _completionTimer = Timer(const Duration(milliseconds: 2000), () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _completionTimer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [AppColors.accent, AppColors.accent2])),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ScaleTransition(
              scale: _scale,
              child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 30, offset: const Offset(0, 10))]),
                child: const Center(child: Text('سوق', style: TextStyle(color: AppColors.accent, fontSize: 28, fontWeight: FontWeight.w900))),
              ),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _fade,
              child: Column(children: [
                const Text('سوق الجملة B2B للخليج', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('نقطة تجمع المشترين مع الموردين والمصانع', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

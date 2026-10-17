import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'theme/app_colors.dart';
import 'sonexa_shell.dart';

class SonexaSplashScreen extends StatefulWidget {
  const SonexaSplashScreen({super.key});

  @override
  State<SonexaSplashScreen> createState() => _SonexaSplashScreenState();
}

class _SonexaSplashScreenState extends State<SonexaSplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..forward();
  late final AnimationController _orbit = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..repeat();
  late final AnimationController _glow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);
  Timer? _timer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2900), _openHome);
  }

  void _openHome() {
    if (!mounted || _navigated) return;
    _navigated = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, animation, _) => const SonexaShell(),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _intro.dispose();
    _orbit.dispose();
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE8FFF4),
                  Color(0xFFF7F8FC),
                  Color(0xFFFFF8E7),
                ],
              ),
            ),
          ),
          Positioned(
            top: -size.width * .28,
            right: -size.width * .2,
            child: _GlowOrb(controller: _glow, color: AppColors.mint),
          ),
          Positioned(
            bottom: -size.width * .30,
            left: -size.width * .2,
            child: _GlowOrb(controller: _glow, color: AppColors.lavender),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _orbit,
                builder: (_, _) => CustomPaint(
                  painter: _SparklePainter(progress: _orbit.value),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                AnimatedBuilder(
                  animation: Listenable.merge([_intro, _orbit, _glow]),
                  builder: (_, _) {
                    final entrance = Curves.easeOutBack.transform(
                      _intro.value.clamp(0.0, 1.0),
                    );
                    final pulse = .96 + (_glow.value * .04);
                    return Opacity(
                      opacity: _intro.value.clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: entrance * pulse,
                        child: SizedBox(
                          width: 220,
                          height: 220,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Transform.rotate(
                                angle: _orbit.value * math.pi * 2,
                                child: Container(
                                  width: 204,
                                  height: 204,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFBA9144)
                                          .withValues(alpha: .42),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: Container(
                                      width: 9,
                                      height: 9,
                                      margin: const EdgeInsets.only(top: 8),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFD1A44D),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0x66D1A44D),
                                            blurRadius: 12,
                                            spreadRadius: 3,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 164,
                                height: 164,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF124735).withValues(
                                        alpha: .14 + (_glow.value * .08),
                                      ),
                                      blurRadius: 34,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 14),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/sonexa_appicon.jpg',
                                    fit: BoxFit.cover,
                                    semanticLabel: 'Sonexa',
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 8,
                                top: 42,
                                child: _Twinkle(
                                  animation: _glow,
                                  size: 23,
                                  color: const Color(0xFFD1A44D),
                                ),
                              ),
                              Positioned(
                                left: 11,
                                bottom: 43,
                                child: _Twinkle(
                                  animation: ReverseAnimation(_glow),
                                  size: 15,
                                  color: const Color(0xFF43876B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0, .22),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(parent: _intro, curve: Curves.easeOut),
                      ),
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _intro,
                      curve: const Interval(.18, 1, curve: Curves.easeOut),
                    ),
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Color(0xFF174F3D),
                              Color(0xFFBA9144),
                              Color(0xFF174F3D),
                            ],
                          ).createShader(bounds),
                          child: const Text(
                            'SONEXA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 33,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 7,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'METALS, AT A GLANCE',
                          style: TextStyle(
                            color: Color(0xFF65766E),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.2,
                          ),
                        ),
                        const SizedBox(height: 17),
                        const Text(
                          'Clarity in every gram.',
                          style: TextStyle(
                            color: Color(0xFF68746E),
                            fontSize: 13,
                            letterSpacing: .3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(flex: 2),
                AnimatedBuilder(
                  animation: _intro,
                  builder: (_, _) => Opacity(
                    opacity: _intro.value.clamp(0.0, 1.0),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 128,
                          height: 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: null,
                              backgroundColor: const Color(0xFF174F3D)
                                  .withValues(alpha: .1),
                              color: const Color(0xFFBA9144),
                              minHeight: 3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'PREPARING YOUR MARKET VIEW',
                          style: TextStyle(
                            color: Color(0xFF819087),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 26),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.controller, required this.color});
  final Animation<double> controller;
  final Color color;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (_, _) => Container(
      width: MediaQuery.sizeOf(context).width * .8,
      height: MediaQuery.sizeOf(context).width * .8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: .34 + (controller.value * .12)),
            color.withValues(alpha: .08),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    ),
  );
}

class _Twinkle extends StatelessWidget {
  const _Twinkle({
    required this.animation,
    required this.size,
    required this.color,
  });
  final Animation<double> animation;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: Tween<double>(begin: .35, end: 1).animate(animation),
    child: ScaleTransition(
      scale: Tween<double>(begin: .75, end: 1.15).animate(animation),
      child: Icon(Icons.auto_awesome, size: size, color: color),
    ),
  );
}

class _SparklePainter extends CustomPainter {
  const _SparklePainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final flecks = [
      (x: .13, y: .23, phase: .1, radius: 2.2),
      (x: .82, y: .30, phase: .6, radius: 1.7),
      (x: .22, y: .71, phase: .4, radius: 1.5),
      (x: .89, y: .76, phase: .8, radius: 2.1),
      (x: .69, y: .15, phase: .2, radius: 1.4),
      (x: .38, y: .84, phase: .7, radius: 1.6),
    ];
    for (final fleck in flecks) {
      final shimmer =
          (math.sin((progress + fleck.phase) * math.pi * 2) + 1) / 2;
      final paint = Paint()
        ..color = const Color(0xFFBA9144).withValues(alpha: .14 + shimmer * .5)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shimmer * 2.5);
      final drift = math.sin((progress + fleck.phase) * math.pi * 2) * 7;
      canvas.drawCircle(
        Offset(size.width * fleck.x, size.height * fleck.y + drift),
        fleck.radius + shimmer,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

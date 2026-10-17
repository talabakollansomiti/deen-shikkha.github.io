import 'package:flutter/material.dart';
import 'dart:math' as math;

// ============ ফিউচারিস্টিক পেজ ট্রানজিশন ============
class FuturisticPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  FuturisticPageRoute({required this.page})
      : super(
          transitionDuration:
              const Duration(milliseconds: 450),
          reverseTransitionDuration:
              const Duration(milliseconds: 350),
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder:
              (_, animation, secAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale: Tween<double>(
                        begin: 0.92, end: 1.0)
                    .animate(curved),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.06),
                    end: Offset.zero,
                  ).animate(curved),
                  child: child,
                ),
              ),
            );
          },
        );
}

// ============ Staggered entrance (spring) ============
class StaggeredEntrance extends StatefulWidget {
  final int index;
  final Widget child;
  const StaggeredEntrance(
      {super.key, required this.index, required this.child});

  @override
  State<StaggeredEntrance> createState() =>
      _StaggeredEntranceState();
}

class _StaggeredEntranceState
    extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    final delay =
        (widget.index * 60).clamp(0, 600) / 600;
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Interval(delay, 1.0, curve: Curves.easeOut),
      ),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve:
            Interval(delay, 1.0, curve: Curves.easeOutBack),
      ),
    );
    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Interval(delay, 1.0,
            curve: Curves.easeOutBack),
      ),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: ScaleTransition(
          scale: _scale,
          child: widget.child,
        ),
      ),
    );
  }
}

// ============ Shimmer loading ============
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final double radius;
  const ShimmerLoading(
      {super.key,
      required this.width,
      required this.height,
      this.radius = 12});

  @override
  State<ShimmerLoading> createState() =>
      _ShimmerLoadingState();
}

class _ShimmerLoadingState
    extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1 - _ctrl.value * 2, 0),
              end: Alignment(1 - _ctrl.value * 2, 0),
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============ Confetti celebration ============
class ConfettiOverlay extends StatefulWidget {
  final Widget child;
  const ConfettiOverlay(
      {super.key, required this.child});

  @override
  State<ConfettiOverlay> createState() =>
      _ConfettiOverlayState();
}

class _ConfettiOverlayState
    extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final _rand = math.Random();
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _particles = List.generate(
        80,
        (_) => _Particle(
              x: _rand.nextDouble(),
              y: -0.1 - _rand.nextDouble() * 0.3,
              size: 6 + _rand.nextDouble() * 8,
              speed: 0.4 + _rand.nextDouble() * 0.8,
              color: [
                const Color(0xFF0E6B3E),
                const Color(0xFFD4AF37),
                const Color(0xFFB23A48),
                const Color(0xFF1B6FA8),
                const Color(0xFF6A4FB3),
              ][_rand.nextInt(5)],
              sway: _rand.nextDouble() * 2 * math.pi,
            ));
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            return CustomPaint(
              painter: _ConfettiPainter(
                  _particles, _ctrl.value),
              size: Size.infinite,
            );
          },
        ),
      ],
    );
  }
}

class _Particle {
  double x, y, size, speed, sway;
  Color color;
  _Particle(
      {required this.x,
      required this.y,
      required this.size,
      required this.speed,
      required this.color,
      required this.sway});
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  _ConfettiPainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final y = (p.y + progress * p.speed * 1.5) %
          1.4;
      if (y < 0 || y > 1.1) continue;
      final x =
          p.x + math.sin(progress * 6 + p.sway) * 0.03;
      final paint = Paint()
        ..color =
            p.color.withOpacity(1 - progress * 0.5);
      canvas.save();
      canvas.translate(x * size.width, y * size.height);
      canvas.rotate(progress * 8 + p.sway);
      canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero,
              width: p.size,
              height: p.size * 0.6),
          paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) =>
      old.progress != progress;
}

// ============ Bounce tap wrapper ============
class BounceTap extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const BounceTap(
      {super.key,
      required this.child,
      required this.onTap});

  @override
  State<BounceTap> createState() => _BounceTapState();
}

class _BounceTapState extends State<BounceTap>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.93)
        .animate(CurvedAnimation(
            parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
          scale: _scale, child: widget.child),
    );
  }
}

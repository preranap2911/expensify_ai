import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AiCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const AiCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withOpacity(0.22),
            cs.secondary.withOpacity(0.12),
            cs.tertiary.withOpacity(0.08),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: cs.secondary.withOpacity(0.12),
            blurRadius: 18,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: cs.primary.withOpacity(0.10),
            blurRadius: 24,
            spreadRadius: 1,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      padding: padding,
      child: child,
    ).animate().fadeIn(duration: 220.ms).slideY(begin: 0.06, end: 0);
  }
}

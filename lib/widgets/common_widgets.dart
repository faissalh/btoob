import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ─── Animated Counter ─────────────────────────────────────
class AnimatedCounter extends StatefulWidget {
  final int value;
  final String label;
  const AnimatedCounter({super.key, required this.value, required this.label});

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _a = Tween<double>(begin: 0, end: widget.value.toDouble())
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
    _c.forward();
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      builder: (context, _) => Column(
        children: [
          Text(
            _a.value.toInt().toString(),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.accent),
          ),
          const SizedBox(height: 4),
          Text(widget.label, style: const TextStyle(fontSize: 11, color: AppColors.muted), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;
  const SectionHeader({super.key, required this.title, this.actionText, this.onAction});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: TextStyle(
              color: isDark ? AppColors.darkFg : AppColors.fg, fontSize: 18, fontWeight: FontWeight.w800)),
          ),
          if (actionText != null)
            TextButton(
              onPressed: onAction,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(actionText!, style: const TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_back_ios, size: 12, color: AppColors.accent),
              ]),
            ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  const EmptyState({super.key, required this.icon, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final m = Theme.of(context).brightness == Brightness.dark ? AppColors.darkMuted : AppColors.muted;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 64, color: m.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(color: m, fontSize: 16, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle!, style: TextStyle(color: m.withValues(alpha: 0.7), fontSize: 13), textAlign: TextAlign.center),
          ],
        ]),
      ),
    );
  }
}

// ─── Search Field ─────────────────────────────────────────
class SearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  const SearchField({super.key, this.hint = 'بحث...', this.onChanged, this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search, color: AppColors.muted2),
      ),
    );
  }
}

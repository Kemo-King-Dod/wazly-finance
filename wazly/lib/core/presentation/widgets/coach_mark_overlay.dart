import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:wazly/core/theme/app_theme.dart';
import 'package:wazly/core/services/coach_mark_service.dart';
import 'package:wazly/l10n/app_localizations.dart';

// ─────────────────────────────────────────────────────
//  AppShellScope — communicates the active tab index
// ─────────────────────────────────────────────────────
class AppShellScope extends InheritedWidget {
  final int currentTab;

  const AppShellScope({
    super.key,
    required this.currentTab,
    required super.child,
  });

  static int? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppShellScope>()?.currentTab;
  }

  @override
  bool updateShouldNotify(AppShellScope old) => old.currentTab != currentTab;
}

// ─────────────────────────────────────────────────────
//  Data model
// ─────────────────────────────────────────────────────
class CoachMarkStep {
  final GlobalKey targetKey;
  final String text;
  final IconData icon;

  const CoachMarkStep({
    required this.targetKey,
    required this.text,
    required this.icon,
  });
}

// ─────────────────────────────────────────────────────
//  Global lock — prevents simultaneous overlays
// ─────────────────────────────────────────────────────
OverlayEntry? _activeOverlay;
bool get _isCoachMarkActive => _activeOverlay != null;

/// Checks if a tour has been seen, verifies visibility, then shows it.
///
/// [requiredTabIndex]: if set, only shows when this tab is active in AppShellScope.
/// If null (e.g. pushed screens), skips the tab check.
Future<void> maybeShowCoachMarks({
  required BuildContext context,
  required String tourId,
  required List<CoachMarkStep> steps,
  int? requiredTabIndex,
  Duration delay = const Duration(milliseconds: 700),
}) async {
  final seen = await CoachMarkService.hasSeenTour(tourId);
  if (seen) return;

  await Future.delayed(delay);
  if (!context.mounted) return;

  if (_isCoachMarkActive) return;

  if (requiredTabIndex != null) {
    final currentTab = AppShellScope.of(context);
    if (currentTab != requiredTabIndex) return;
  }

  _showCoachMarkTour(context: context, tourId: tourId, steps: steps);
}

void _showCoachMarkTour({
  required BuildContext context,
  required String tourId,
  required List<CoachMarkStep> steps,
}) {
  final overlay = Overlay.of(context);

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _CoachMarkOverlayWidget(
      steps: steps,
      tourId: tourId,
      onFinish: () {
        entry.remove();
        _activeOverlay = null;
      },
    ),
  );

  _activeOverlay = entry;
  overlay.insert(entry);
}

// ─────────────────────────────────────────────────────
//  Overlay Widget
// ─────────────────────────────────────────────────────
class _CoachMarkOverlayWidget extends StatefulWidget {
  final List<CoachMarkStep> steps;
  final String tourId;
  final VoidCallback onFinish;

  const _CoachMarkOverlayWidget({
    required this.steps,
    required this.tourId,
    required this.onFinish,
  });

  @override
  State<_CoachMarkOverlayWidget> createState() =>
      _CoachMarkOverlayWidgetState();
}

class _CoachMarkOverlayWidgetState extends State<_CoachMarkOverlayWidget>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentStep < widget.steps.length - 1) {
      _controller.reverse().then((_) {
        if (mounted) {
          setState(() => _currentStep++);
          _controller.forward();
        }
      });
    } else {
      _complete();
    }
  }

  void _complete() {
    CoachMarkService.completeTour(widget.tourId);
    _controller.reverse().then((_) {
      widget.onFinish();
    });
  }

  Rect? _getTargetRect(GlobalKey key) {
    final renderObject = key.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;
    final position = renderObject.localToGlobal(Offset.zero);
    return Rect.fromLTWH(
      position.dx,
      position.dy,
      renderObject.size.width,
      renderObject.size.height,
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_currentStep];
    final l = AppLocalizations.of(context)!;
    final targetRect = _getTargetRect(step.targetKey);
    final screenSize = MediaQuery.of(context).size;

    if (targetRect == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _next();
      });
      return const SizedBox.shrink();
    }

    final spotlightRect = RRect.fromRectAndRadius(
      targetRect.inflate(6),
      const Radius.circular(14),
    );

    final bool showAbove = targetRect.center.dy > screenSize.height * 0.55;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _next,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _SpotlightPainter(spotlight: spotlightRect),
                ),
              ),
              Positioned.fromRect(
                rect: targetRect.inflate(6),
                child: IgnorePointer(
                  child: _PulseRing(color: Theme.of(context).primaryColor),
                ),
              ),
              Positioned(
                left: 24,
                right: 24,
                top: showAbove ? null : spotlightRect.outerRect.bottom + 20,
                bottom: showAbove
                    ? screenSize.height - spotlightRect.outerRect.top + 20
                    : null,
                child: _TooltipCard(
                  step: step,
                  stepIndex: _currentStep,
                  totalSteps: widget.steps.length,
                  isLast: _currentStep == widget.steps.length - 1,
                  onNext: _next,
                  onSkip: _complete,
                  l: l,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
//  Spotlight Painter
// ─────────────────────────────────────────────────────
class _SpotlightPainter extends CustomPainter {
  final RRect spotlight;

  _SpotlightPainter({required this.spotlight});

  @override
  void paint(Canvas canvas, Size size) {
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = Path()
      ..addRect(fullRect)
      ..addRRect(spotlight)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(
      path,
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );

    canvas.drawRRect(
      spotlight,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter old) =>
      old.spotlight != spotlight;
}

// ─────────────────────────────────────────────────────
//  Pulse Ring Animation
// ─────────────────────────────────────────────────────
class _PulseRing extends StatefulWidget {
  final Color color;
  const _PulseRing({required this.color});

  @override
  State<_PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<_PulseRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
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
        final scale = 1.0 + _ctrl.value * 0.15;
        final opacity = (1.0 - _ctrl.value) * 0.35;
        return Transform.scale(
          scale: scale,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: widget.color.withValues(alpha: opacity),
                width: 2.5,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────
//  Tooltip Card
// ─────────────────────────────────────────────────────
class _TooltipCard extends StatelessWidget {
  final CoachMarkStep step;
  final int stepIndex;
  final int totalSteps;
  final bool isLast;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final AppLocalizations l;

  const _TooltipCard({
    required this.step,
    required this.stepIndex,
    required this.totalSteps,
    required this.isLast,
    required this.onNext,
    required this.onSkip,
    required this.l,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(step.icon, color: primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step.text,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Row(
                children: List.generate(totalSteps, (i) {
                  final isActive = i == stepIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsetsDirectional.only(end: 5),
                    width: isActive ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive ? primary : AppTheme.borderLight,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
              const Spacer(),
              if (!isLast)
                GestureDetector(
                  onTap: onSkip,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    child: Text(
                      l.skip,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onNext,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isLast ? l.gotIt : l.next,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

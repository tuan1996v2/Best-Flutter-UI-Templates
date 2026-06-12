import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A drop-in replacement for [Scaffold] that overlays the screen name
/// in the top-right corner **only in debug mode** (`kDebugMode == true`).
///
/// In release builds, `kDebugMode` is a compile-time constant `false`,
/// so the overlay branch is completely tree-shaken — zero overhead.
///
/// Usage:
/// ```dart
/// // Before
/// return Scaffold(appBar: ..., body: ...);
///
/// // After
/// return DebugOverlayScaffold(
///   screenName: 'MyScreen',
///   appBar: ...,
///   body: ...,
/// );
/// ```
class DebugOverlayScaffold extends StatelessWidget {
  const DebugOverlayScaffold({
    super.key,
    required this.screenName,
    // ── All Scaffold properties ──────────────────────────────
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.floatingActionButtonAnimator,
    this.persistentFooterButtons,
    this.persistentFooterAlignment = AlignmentDirectional.centerEnd,
    this.drawer,
    this.onDrawerChanged,
    this.endDrawer,
    this.onEndDrawerChanged,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.primary = true,
    this.drawerDragStartBehavior = DragStartBehavior.start,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.drawerScrimColor,
    this.drawerEdgeDragWidth,
    this.drawerEnableOpenDragGesture = true,
    this.endDrawerEnableOpenDragGesture = true,
    this.restorationId,
  });

  /// The name displayed on the debug overlay badge.
  final String screenName;

  // ── Scaffold property forwarding ────────────────────────────
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;
  final List<Widget>? persistentFooterButtons;
  final AlignmentDirectional persistentFooterAlignment;
  final Widget? drawer;
  final DrawerCallback? onDrawerChanged;
  final Widget? endDrawer;
  final DrawerCallback? onEndDrawerChanged;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;
  final bool primary;
  final DragStartBehavior drawerDragStartBehavior;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final Color? drawerScrimColor;
  final double? drawerEdgeDragWidth;
  final bool drawerEnableOpenDragGesture;
  final bool endDrawerEnableOpenDragGesture;
  final String? restorationId;

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      floatingActionButtonAnimator: floatingActionButtonAnimator,
      persistentFooterButtons: persistentFooterButtons,
      persistentFooterAlignment: persistentFooterAlignment,
      drawer: drawer,
      onDrawerChanged: onDrawerChanged,
      endDrawer: endDrawer,
      onEndDrawerChanged: onEndDrawerChanged,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      primary: primary,
      drawerDragStartBehavior: drawerDragStartBehavior,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      drawerScrimColor: drawerScrimColor,
      drawerEdgeDragWidth: drawerEdgeDragWidth,
      drawerEnableOpenDragGesture: drawerEnableOpenDragGesture,
      endDrawerEnableOpenDragGesture: endDrawerEnableOpenDragGesture,
      restorationId: restorationId,
    );

    // In release mode, kDebugMode is a compile-time constant `false`.
    // The compiler will tree-shake the entire overlay branch.
    if (!kDebugMode) return scaffold;

    return Stack(
      children: [
        scaffold,
        Positioned(
          top: MediaQuery.of(context).padding.top + 6,
          right: 8,
          child: _DebugBadgeOverlay(screenName: screenName),
        ),
      ],
    );
  }
}

class _DebugBadgeOverlay extends StatefulWidget {
  final String screenName;
  const _DebugBadgeOverlay({required this.screenName});

  @override
  State<_DebugBadgeOverlay> createState() => _DebugBadgeOverlayState();
}

class _DebugBadgeOverlayState extends State<_DebugBadgeOverlay>
    with SingleTickerProviderStateMixin {
  bool _copied = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    // Copy to Clipboard
    await Clipboard.setData(ClipboardData(text: widget.screenName));
    HapticFeedback.mediumImpact();

    // Pulse feedback animation
    await _controller.forward();
    if (mounted) {
      setState(() {
        _copied = true;
      });
    }
    await _controller.reverse();

    // Revert copied state after a brief delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _copied = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: _handleTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _copied
                    ? Colors.green.withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: _copied
                      ? Colors.greenAccent.withValues(alpha: 0.4)
                      : Colors.white.withValues(alpha: 0.12),
                  width: 0.7,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                child: Material(
                  color: Colors.transparent,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated status indicator icon
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 150),
                        transitionBuilder: (child, anim) => ScaleTransition(
                          scale: anim,
                          child: child,
                        ),
                        child: _copied
                            ? Icon(
                                Icons.check_circle_rounded,
                                key: const ValueKey('check'),
                                color: Colors.greenAccent,
                                size: 13,
                              )
                            : const Icon(
                                Icons.screen_search_desktop_outlined,
                                key: ValueKey('screen'),
                                color: Colors.white70,
                                size: 13,
                              ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _copied ? 'Copied!' : widget.screenName,
                        style: TextStyle(
                          color: _copied
                              ? Colors.greenAccent
                              : Colors.white.withValues(alpha: 0.9),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                          fontFamily: '.SF Pro Text',
                          letterSpacing: -0.2,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

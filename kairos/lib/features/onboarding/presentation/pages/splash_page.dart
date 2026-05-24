import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/kairos_colors.dart';
import '../../../../core/theme/kairos_logo.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    Future.delayed(const Duration(milliseconds: 1800), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('kairos_onboarding_done') ?? false;
    final user = Supabase.instance.client.auth.currentUser;
    if (!mounted) return;

    if (onboardingDone && user != null) {
      context.go('/dashboard');
    } else if (onboardingDone) {
      context.go('/login');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return Scaffold(
      backgroundColor: kc.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (_, __) {
                return SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Círculo exterior — rotación lenta
                      Transform.rotate(
                        angle: _controller.value * 2 * 3.14159,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: kc.line),
                          ),
                        ),
                      ),
                      // Círculo medio — estático
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: kc.accent.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      // Círculo interior — relleno sutil
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: kc.accent.withValues(alpha: 0.1),
                          border: Border.all(
                            color: kc.accent.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      // Logo KAIROS centrado con color acento
                      KairosLogoMark(
                        size: 48,
                        color: kc.accent,
                        strokeWidth: 1.5,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'KAIROS',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: kc.text,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'v3.0.0 · INICIANDO',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: kc.text3,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'realm · syncing local store...',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                color: kc.text4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

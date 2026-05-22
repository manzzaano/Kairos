import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/kairos_colors.dart';
import '../../../../core/theme/kairos_logo.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_shapes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo es obligatorio';
    }
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Correo inválido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (value.length < 6) {
      return 'Mínimo 6 caracteres';
    }
    return null;
  }

  void _login() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _loading = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _loading = false);
        context.go('/dashboard');
      }
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return Scaffold(
      backgroundColor: kc.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 48, 20, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    KairosLogoMark(
                        size: 36,
                        color: kc.text,
                        strokeWidth: 1.4,
                    ),
                    const SizedBox(width: 12),
                    Text('KAIROS',
                        style: GoogleFonts.inter(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: kc.text)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0x1F4ADE80),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text('ONLINE',
                          style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              color: kc.success,
                              fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                Text('Bienvenido de vuelta',
                    style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.7,
                        color: kc.text)),
                const SizedBox(height: 8),
                Text('Sincroniza tus tareas con la nube',
                    style: AppTypography.body15
                        .copyWith(color: kc.text2)),
                const SizedBox(height: 40),
                Text('Correo electrónico',
                    style: AppTypography.mono11
                        .copyWith(color: kc.text3)),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: AppTypography.body15,
                  validator: _validateEmail,
                  decoration: InputDecoration(
                    hintText: 'email@ejemplo.com',
                    filled: true,
                    fillColor: kc.bg2,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppShapes.inputRadius),
                      borderSide: BorderSide(color: kc.line),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppShapes.inputRadius),
                      borderSide: BorderSide(color: kc.line),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppShapes.inputRadius),
                      borderSide:
                          BorderSide(color: kc.accent, width: 1.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppShapes.inputRadius),
                      borderSide:
                          BorderSide(color: kc.danger, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Text('Contraseña',
                        style: AppTypography.mono11
                            .copyWith(color: kc.text3)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Recuperación de contraseña no disponible en modo offline'),
                          ),
                        );
                      },
                      child: Text('Olvidaste tu contraseña?',
                          style: AppTypography.caption12
                              .copyWith(color: kc.accent)),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: true,
                  style: AppTypography.body15,
                  validator: _validatePassword,
                  decoration: InputDecoration(
                    hintText: 'Contraseña',
                    filled: true,
                    fillColor: kc.bg2,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppShapes.inputRadius),
                      borderSide: BorderSide(color: kc.line),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppShapes.inputRadius),
                      borderSide: BorderSide(color: kc.line),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppShapes.inputRadius),
                      borderSide:
                          BorderSide(color: kc.accent, width: 1.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppShapes.inputRadius),
                      borderSide:
                          BorderSide(color: kc.danger, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kc.accent,
                      foregroundColor: const Color(0xFF1A0A00),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppShapes.btnRadius),
                      ),
                      textStyle: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF1A0A00),
                            ),
                          )
                        : const Text('Iniciar sesión y sincronizar'),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => context.go('/dashboard'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kc.text,
                      side: BorderSide(color: kc.line),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppShapes.btnRadius),
                      ),
                      textStyle: GoogleFonts.inter(
                          fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    child: const Text('Continuar sin sincronizar'),
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('No tienes cuenta? ',
                          style: AppTypography.body13
                              .copyWith(color: kc.text2)),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Registro disponible próximamente'),
                            ),
                          );
                        },
                        child: Text('Crear una',
                            style: AppTypography.body13.copyWith(
                                color: kc.accent,
                                fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

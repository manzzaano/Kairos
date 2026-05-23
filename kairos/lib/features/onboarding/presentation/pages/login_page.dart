import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  bool _isSignUp = false;
  bool _obscurePass = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo es obligatorio';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Introduce un correo válido';
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

  String _humanizeAuthError(dynamic e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('invalid login credentials') || msg.contains('invalid_credentials')) {
      return 'Correo o contraseña incorrectos';
    }
    if (msg.contains('user already registered') || msg.contains('already registered')) {
      return 'Ya existe una cuenta con ese correo. Inicia sesión.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Confirma tu correo antes de iniciar sesión';
    }
    if (msg.contains('network') || msg.contains('socket') || msg.contains('connection')) {
      return 'Sin conexión. Comprueba tu red e inténtalo de nuevo';
    }
    if (msg.contains('rate limit') || msg.contains('too many')) {
      return 'Demasiados intentos. Espera unos minutos';
    }
    if (msg.contains('weak_password') || msg.contains('password')) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return 'Error al conectar. Inténtalo de nuevo';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final supabase = Supabase.instance.client;
      if (_isSignUp) {
        await supabase.auth.signUp(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        );
      } else {
        await supabase.auth.signInWithPassword(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        );
      }
      if (mounted) context.go('/dashboard');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_humanizeAuthError(e)),
            backgroundColor: Theme.of(context).extension<KairosColors>()?.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || _validateEmail(email) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introduce tu correo para recuperar la contraseña')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email de recuperación enviado a $email')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_humanizeAuthError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
                // Header
                Row(
                  children: [
                    KairosLogoMark(size: 36, color: kc.text, strokeWidth: 1.4),
                    const SizedBox(width: 12),
                    Text('KAIROS',
                        style: GoogleFonts.inter(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: kc.text)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                Text(
                  _isSignUp ? 'Crear cuenta' : 'Bienvenido de vuelta',
                  style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.7,
                      color: kc.text),
                ),
                const SizedBox(height: 8),
                Text(
                  _isSignUp
                      ? 'Crea tu cuenta y sincroniza tus tareas'
                      : 'Sincroniza tus tareas con la nube',
                  style: AppTypography.body15.copyWith(color: kc.text2),
                ),
                const SizedBox(height: 40),

                // Email field
                Text('Correo electrónico',
                    style: AppTypography.mono11.copyWith(color: kc.text3)),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  style: AppTypography.body15,
                  validator: _validateEmail,
                  decoration: InputDecoration(
                    hintText: 'email@ejemplo.com',
                    filled: true,
                    fillColor: kc.bg2,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppShapes.inputRadius),
                      borderSide: BorderSide(color: kc.line),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppShapes.inputRadius),
                      borderSide: BorderSide(color: kc.line),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppShapes.inputRadius),
                      borderSide: BorderSide(color: kc.accent, width: 1.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppShapes.inputRadius),
                      borderSide: BorderSide(color: kc.danger, width: 1.5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppShapes.inputRadius),
                      borderSide: BorderSide(color: kc.danger, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Password field
                Row(
                  children: [
                    Text('Contraseña',
                        style: AppTypography.mono11.copyWith(color: kc.text3)),
                    const Spacer(),
                    if (!_isSignUp)
                      GestureDetector(
                        onTap: _loading ? null : _resetPassword,
                        child: Text('¿Olvidaste tu contraseña?',
                            style: AppTypography.caption12.copyWith(color: kc.accent)),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscurePass,
                  style: AppTypography.body15,
                  validator: _validatePassword,
                  decoration: InputDecoration(
                    hintText: 'Contraseña',
                    filled: true,
                    fillColor: kc.bg2,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        size: 18,
                        color: kc.text3,
                      ),
                      onPressed: () => setState(() => _obscurePass = !_obscurePass),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppShapes.inputRadius),
                      borderSide: BorderSide(color: kc.line),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppShapes.inputRadius),
                      borderSide: BorderSide(color: kc.line),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppShapes.inputRadius),
                      borderSide: BorderSide(color: kc.accent, width: 1.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppShapes.inputRadius),
                      borderSide: BorderSide(color: kc.danger, width: 1.5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppShapes.inputRadius),
                      borderSide: BorderSide(color: kc.danger, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 32),

                // Primary button
                Semantics(
                  label: _isSignUp ? 'Crear cuenta y sincronizar' : 'Iniciar sesión y sincronizar',
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kc.accent,
                        foregroundColor: const Color(0xFF1A0A00),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppShapes.btnRadius),
                        ),
                        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
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
                          : Text(_isSignUp ? 'Crear cuenta' : 'Iniciar sesión y sincronizar'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Guest button
                Semantics(
                  label: 'Continuar sin cuenta en modo offline',
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _loading ? null : () => context.go('/dashboard'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kc.text,
                        side: BorderSide(color: kc.line),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppShapes.btnRadius),
                        ),
                        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      child: const Text('Continuar sin sincronizar'),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Toggle login/signup
                Center(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _isSignUp = !_isSignUp;
                      _formKey.currentState?.reset();
                    }),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isSignUp ? '¿Ya tienes cuenta? ' : '¿No tienes cuenta? ',
                          style: AppTypography.body13.copyWith(color: kc.text2),
                        ),
                        Text(
                          _isSignUp ? 'Inicia sesión' : 'Crear una',
                          style: AppTypography.body13.copyWith(
                              color: kc.accent, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
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

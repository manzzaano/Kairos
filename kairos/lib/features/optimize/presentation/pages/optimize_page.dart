import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/kairos_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../tasks/presentation/bloc/task_bloc.dart';
import '../../../tasks/presentation/bloc/task_event.dart';
import '../../../tasks/presentation/bloc/task_state.dart';
import '../../../tasks/domain/entities/task.dart';

class OptimizePage extends StatefulWidget {
  const OptimizePage({super.key});

  @override
  State<OptimizePage> createState() => _OptimizePageState();
}

class _OptimizePageState extends State<OptimizePage>
    with TickerProviderStateMixin {
  int _step = 0;
  bool _hasError = false;
  String? _errorMessage;
  String? _aiExplanation;
  List<Map<String, dynamic>>? _optimizedOrder;
  bool _sheetDismissedByButton = false;

  late final AnimationController _orbitCtrl;

  static const _steps = [
    'Analizando tareas pendientes',
    'Calculando prioridades',
    'Evaluando niveles de energía',
    'Reorganizando secuencia',
    'Aplicando plan óptimo',
  ];

  @override
  void initState() {
    super.initState();
    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Obtener tareas del BLoC y lanzar la optimización
    WidgetsBinding.instance.addPostFrameCallback((_) => _runOptimize());
  }

  Future<void> _runOptimize() async {
    final taskState = context.read<TaskBloc>().state;
    final tasks = taskState is TaskLoaded
        ? taskState.tasks.where((t) => !t.isDone).toList()
        : <Task>[];

    if (tasks.isEmpty) {
      // Sin tareas pendientes: avanzar animación y salir
      await _animateSteps(null);
      return;
    }

    // Comprobar autenticación
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      // Sin auth: animar de todos modos (modo demo)
      await _animateSteps(null);
      return;
    }

    try {
      // Step 1 y 2 — animación mientras preparamos datos
      await _advanceTo(1);

      final taskPayload = tasks.map((t) => {
        'id': t.id,
        'title': t.title,
        'priority': t.priority.name,
        'energy': t.energyLevel,
        'estimate_minutes': t.estimateMinutes,
        'project': t.project,
      }).toList();

      // Step 2 — llamada real a la Edge Function
      await _advanceTo(2);

      final response = await Supabase.instance.client.functions
          .invoke(
            'optimize-tasks',
            body: {'tasks': taskPayload},
          )
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () => throw Exception('La IA tardó demasiado. Inténtalo de nuevo.'),
          );

      // Step 3 — procesando resultado
      await _advanceTo(3);

      final data = response.data as Map<String, dynamic>?;
      _optimizedOrder = data?['optimized'] != null
          ? List<Map<String, dynamic>>.from(data!['optimized'] as List)
          : null;
      _aiExplanation = data?['explanation'] as String?;

      // Step 4 + 5
      await _advanceTo(4);
      await _advanceTo(5);

      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) _showResult();
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
        await _animateSteps(null);
      }
    }
  }

  Future<void> _animateSteps(List<Map<String, dynamic>>? result) async {
    for (var i = 0; i <= _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 1100));
      if (!mounted) return;
      setState(() => _step = i);
    }
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      if (_hasError) {
        _showErrorAndPop();
      } else {
        context.pop();
      }
    }
  }

  Future<void> _advanceTo(int step) async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) setState(() => _step = step);
  }

  void _showResult() {
    final kc = context.kc;
    final explanation = _aiExplanation ?? 'Tus tareas han sido reorganizadas según prioridad y energía disponible.';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        decoration: BoxDecoration(
          color: kc.bg2,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(top: BorderSide(color: kc.line)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: kc.line2,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: kc.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.auto_awesome, color: kc.accent, size: 18),
                ),
                const SizedBox(width: 12),
                Text('Plan optimizado',
                    style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: kc.text)),
              ],
            ),
            const SizedBox(height: 16),
            Text(explanation,
                style: AppTypography.body13.copyWith(color: kc.text2, height: 1.5)),
            if (_optimizedOrder != null && _optimizedOrder!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('ORDEN SUGERIDO',
                  style: AppTypography.mono11.copyWith(color: kc.text3, letterSpacing: 1.1)),
              const SizedBox(height: 8),
              ...List.generate(_optimizedOrder!.length.clamp(0, 5), (i) {
                final t = _optimizedOrder![i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 22, height: 22,
                        decoration: BoxDecoration(
                          color: kc.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text('${i + 1}',
                              style: AppTypography.mono11.copyWith(color: kc.accent)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          t['title'] as String? ?? '',
                          style: AppTypography.body13.copyWith(color: kc.text),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  _sheetDismissedByButton = true;
                  Navigator.of(context).pop(); // Cierra bottom sheet
                  context.pop(); // Vuelve al dashboard
                  // Recargar tareas para reflejar posibles cambios
                  context.read<TaskBloc>().add(const LoadTasksRequested());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kc.accent,
                  foregroundColor: const Color(0xFF1A0A00),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Aplicar y volver'),
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      // Si se cierra el sheet sin pulsar botón (swipe down), también volvemos
      if (mounted && !_sheetDismissedByButton) context.pop();
      _sheetDismissedByButton = false;
    });
  }

  void _showErrorAndPop() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_errorMessage ?? 'Error al optimizar. Inténtalo de nuevo.'),
        backgroundColor: context.kc.danger,
      ),
    );
    context.pop();
  }

  @override
  void dispose() {
    _orbitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return Scaffold(
      backgroundColor: kc.bg,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 16,
              right: 16,
              child: Semantics(
                label: 'Cerrar optimización',
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: kc.bg2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kc.line),
                    ),
                    child: Icon(Icons.close, size: 18, color: kc.text3),
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _OrbitRing(
                          radius: 90,
                          border: kc.line,
                          duration: 6,
                          child: _Planet(accent: kc.accent),
                        ),
                        _OrbitRing(
                          radius: 65,
                          border: kc.line2,
                          duration: 4,
                          child: _Planet(accent: kc.accent2),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: kc.bg2,
                            border: Border.all(color: kc.line2),
                          ),
                          child: Icon(Icons.auto_awesome, size: 20, color: kc.accent),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text('OPTIMIZANDO CON IA',
                      style: AppTypography.mono11.copyWith(color: kc.accent)),
                  const SizedBox(height: 8),
                  Text('Reorganizando tu día',
                      style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: kc.text)),
                  const SizedBox(height: 32),
                  ...List.generate(_steps.length, (i) {
                    final done = i < _step;
                    final active = i == _step;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (done)
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _hasError && i == _step - 1
                                    ? kc.danger
                                    : kc.accent,
                              ),
                              child: Icon(
                                _hasError && i == _step - 1
                                    ? Icons.close
                                    : Icons.check,
                                size: 14,
                                color: const Color(0xFF1A0A00),
                              ),
                            )
                          else if (active)
                            _PulseDot(color: kc.accent)
                          else
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: kc.line2),
                              ),
                            ),
                          const SizedBox(width: 12),
                          Text(_steps[i],
                              style: AppTypography.body13.copyWith(
                                color: done
                                    ? kc.text2
                                    : active
                                        ? kc.text
                                        : kc.text3,
                              )),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Widgets auxiliares (sin cambios)
// ──────────────────────────────────────────────

class _OrbitRing extends StatelessWidget {
  final double radius;
  final Color border;
  final int duration;
  final Widget child;
  const _OrbitRing({
    required this.radius,
    required this.border,
    required this.duration,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: border),
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 2 * 3.14159),
            duration: Duration(seconds: duration),
            builder: (_, t, __) => Transform.rotate(
              angle: t,
              child: Align(
                alignment: Alignment.topCenter,
                child: Transform.translate(
                  offset: Offset(0, -radius),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Planet extends StatelessWidget {
  final Color accent;
  const _Planet({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(shape: BoxShape.circle, color: accent),
    );
  }
}

class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
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
      builder: (_, __) => Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color.withValues(alpha: 0.3 + _ctrl.value * 0.5),
        ),
        child: Center(
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color),
          ),
        ),
      ),
    );
  }
}

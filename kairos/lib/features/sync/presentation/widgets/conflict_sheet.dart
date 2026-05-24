import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/kairos_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_shapes.dart';

class ConflictSheet extends StatelessWidget {
  const ConflictSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F0F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: kc.line2,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 20),
          // Icono advertencia
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0x1FFACC15),
              border: Border.all(color: const Color(0x4DFACC15)),
            ),
            child: Icon(Icons.warning_amber_outlined, color: kc.warning, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            'Conflicto de sincronización',
            style: GoogleFonts.inter(
                fontSize: 18, fontWeight: FontWeight.w600, color: kc.text),
          ),
          const SizedBox(height: 8),
          Text(
            'Los datos locales difieren de los datos del servidor. '
            'Se ha conservado la versión local (modo offline-first). '
            'Sincroniza de nuevo para resolver.',
            textAlign: TextAlign.center,
            style: AppTypography.body13.copyWith(color: kc.text2),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: kc.accent,
                foregroundColor: const Color(0xFF1A0A00),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppShapes.btnRadius)),
              ),
              child: const Text('Entendido'),
            ),
          ),
        ],
      ),
    );
  }
}

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
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: kc.line2,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0x1FFACC15),
              border: Border.all(color: const Color(0x4DFACC15)),
            ),
            child:
                Icon(Icons.warning_amber_outlined, color: kc.warning, size: 24),
          ),
          const SizedBox(height: 12),
          Text('Conflicto de versión',
              style: GoogleFonts.inter(
                  fontSize: 18, fontWeight: FontWeight.w600, color: kc.text)),
          const SizedBox(height: 8),
          Text(
              'Hay diferencias entre los datos de este dispositivo y el servidor.',
              textAlign: TextAlign.center,
              style: AppTypography.body13.copyWith(color: kc.text2)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: kc.bg2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kc.accent.withValues(alpha: 0.25)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.phone_iphone, color: kc.accent, size: 20),
                      const SizedBox(height: 6),
                      Text('LOCAL',
                          style: AppTypography.mono11.copyWith(color: kc.text3)),
                      Text('iPhone',
                          style:
                              AppTypography.body13.copyWith(color: kc.text)),
                      Text('Hace 2 min',
                          style: AppTypography.mono11.copyWith(color: kc.text3)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: kc.bg2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kc.line),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.laptop_mac, color: kc.text2, size: 20),
                      const SizedBox(height: 6),
                      Text('REMOTO',
                          style: AppTypography.mono11.copyWith(color: kc.text3)),
                      Text('MacBook',
                          style:
                              AppTypography.body13.copyWith(color: kc.text)),
                      Text('Hace 5 min',
                          style: AppTypography.mono11.copyWith(color: kc.text3)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
              child: const Text('Mantener local'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: kc.text,
                side: BorderSide(color: kc.line),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppShapes.btnRadius)),
              ),
              child: const Text('Más tarde'),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/kairos_colors.dart';
import '../../core/constants/app_typography.dart';

class OfflineBanner extends StatelessWidget {
  final bool isOffline;
  const OfflineBanner({required this.isOffline, super.key});

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      offset: isOffline ? Offset.zero : const Offset(0, -1.5),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isOffline ? 1 : 0,
        child: IgnorePointer(
          ignoring: !isOffline,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0x1FFACC15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x40FACC15)),
            ),
            child: Row(
              children: [
                Icon(Icons.wifi_off,
                    size: 16, color: kc.warning),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Sin conexin',
                          style: AppTypography.body13
                              .copyWith(color: kc.warning)),
                      Text('Se sincronizar al recuperar red',
                          style: AppTypography.caption12
                              .copyWith(color: kc.text3)),
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

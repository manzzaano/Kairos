import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../../core/theme/kairos_colors.dart';
import '../../core/constants/app_typography.dart';

class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  bool _isOffline = false;
  late final StreamSubscription<List<ConnectivityResult>> _sub;

  @override
  void initState() {
    super.initState();
    // Comprobar estado inicial
    Connectivity().checkConnectivity().then((results) {
      if (mounted) {
        setState(() => _isOffline = _noConnection(results));
      }
    });
    // Escuchar cambios
    _sub = Connectivity().onConnectivityChanged.listen((results) {
      if (mounted) {
        setState(() => _isOffline = _noConnection(results));
      }
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  bool _noConnection(List<ConnectivityResult> results) =>
      results.isEmpty || results.every((r) => r == ConnectivityResult.none);

  @override
  Widget build(BuildContext context) {
    final kc = context.kc;
    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      offset: _isOffline ? Offset.zero : const Offset(0, -1.5),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _isOffline ? 1 : 0,
        child: IgnorePointer(
          ignoring: !_isOffline,
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
                Icon(Icons.wifi_off, size: 16, color: kc.warning),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Sin conexión',
                          style: AppTypography.body13
                              .copyWith(color: kc.warning)),
                      Text('Se sincronizará al recuperar red',
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

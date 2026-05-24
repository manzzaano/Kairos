import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/di/injection_container.dart';
import 'core/constants/app_constants.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Usar fuentes bundled del paquete — no descargar desde Google Fonts en runtime
  GoogleFonts.config.allowRuntimeFetching = false;

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  setupServiceLocator();
  await NotificationService.init();
  runApp(const KairosApp());
}

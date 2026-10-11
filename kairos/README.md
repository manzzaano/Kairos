# Kairos · app Flutter

La app de Kairos. Qué hace, cómo está hecha y el stack completo están en el [README principal](../README.md).

```
lib/
├── core/       constantes, inyección de dependencias (GetIt), router, servicios y tema
├── features/   una carpeta por funcionalidad (tasks, focus, habits, stats, optimize, sync, profile, onboarding...),
│               cada una con sus capas de datos, dominio y presentación
└── shared/     widgets reutilizables (TaskCard, OfflineBanner...)
```

```bash
flutter pub get
flutter run
flutter test
flutter build apk --release --split-per-abi
```

La URL y la clave pública de Supabase están en `lib/core/constants/app_constants.dart`.

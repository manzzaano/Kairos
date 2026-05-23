# KAIROS

**Aplicación de productividad personal con IA, offline-first y sincronización en la nube.**

> TFG – Entrega 3 · Ismael Manzano León · v3.0.0

---

## Descripción

KAIROS es una app Flutter que te ayuda a gestionar tus tareas de forma inteligente:

- 📱 **Offline-first**: Funciona sin conexión gracias a Realm (base de datos local)
- ☁️ **Sync en la nube**: Sincronización bidireccional con Supabase cuando hay conexión
- 🤖 **IA**: Optimización del orden de tareas mediante Gemini (Supabase Edge Function)
- ⏱️ **Pomodoro**: Timer de enfoque integrado (25 min)
- 📊 **Estadísticas**: KPIs, gráfico 7 días, heatmap 28 días, racha diaria
- 🎨 **Personalización**: Tema dark/light + 8 colores de acento

---

## Arquitectura

```
Clean Architecture + BLoC Pattern

lib/
├── core/           # Constantes, DI (GetIt), router, servicios, tema
├── features/       # Módulos por funcionalidad
│   ├── onboarding/ # Splash, onboarding, login (Supabase Auth)
│   ├── dashboard/  # Pantalla principal con resumen y CTA IA
│   ├── tasks/      # CRUD de tareas (domain/data/presentation)
│   ├── focus/      # Timer pomodoro (BLoC)
│   ├── optimize/   # Optimización IA (Edge Function Gemini)
│   ├── stats/      # Estadísticas y productividad
│   ├── sync/       # Sheets de sincronización Supabase
│   └── profile/    # Perfil, apariencia, logout
└── shared/         # Widgets reutilizables (TaskCard, OfflineBanner, etc.)
```

**Stack técnico:**

| Paquete | Uso |
|---------|-----|
| `flutter_bloc` | Gestión de estado (BLoC + Cubit) |
| `realm` | Base de datos local offline-first |
| `supabase_flutter` | Auth, sync y Edge Functions |
| `go_router` | Navegación declarativa con guards |
| `get_it` | Inyección de dependencias |
| `dartz` | Either<Failure, T> para manejo de errores |
| `connectivity_plus` | Detección de conectividad en tiempo real |
| `google_fonts` | Inter + JetBrains Mono |

---

## Requisitos previos

- Flutter SDK `>=3.3.0 <4.0.0`
- Android Studio / VS Code con extensión Flutter
- Emulador Android (recomendado: Medium Phone API 35) o dispositivo físico

---

## Setup y ejecución

```bash
# 1. Instalar dependencias
flutter pub get

# 2. Ejecutar en modo debug (emulador o dispositivo)
flutter run

# 3. Generar APK debug
flutter build apk --debug

# 4. Generar APK release (split por ABI — recomendado)
flutter build apk --release --split-per-abi
# Output: build/app/outputs/apk/release/
```

Las credenciales de Supabase están en `lib/core/constants/app_constants.dart`. Para usar tu propio proyecto, actualiza `supabaseUrl` y `supabaseAnonKey`.

---

## Funcionalidades (v3.0.0)

| Feature | Descripción |
|---------|-------------|
| Splash + Onboarding | Animación de logo + 3 slides con features |
| Auth real (Supabase) | Login, registro y recuperación de contraseña |
| Dashboard | Resumen de energía, tareas pendientes, CTA optimize |
| CRUD Tareas | Crear, ver, completar, eliminar — persistido en Realm |
| Swipe actions | Deslizar para completar (izquierda) o eliminar (derecha) |
| Filtros + grupos | Por estado y por proyecto |
| Timer Pomodoro | 25 min con pause/reset, ligado a tarea opcional |
| Optimización IA | Llama a Edge Function Gemini y muestra orden sugerido |
| Sincronización | Push de tareas locales a Supabase + pull bidireccional |
| Estadísticas | KPIs, barras 7 días, heatmap 28 días, racha |
| Perfil | Tema, color acento, logout |
| Offline banner | Detecta cambios de red en tiempo real |
| Accesibilidad | Semantics en elementos clave |

---

## Base de datos (Supabase)

```sql
-- Tabla tasks (RLS habilitado por user_id)
CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users NOT NULL,
  title TEXT NOT NULL,
  priority INT,             -- 1=low, 2=medium, 3=high
  energy INT,
  estimated_minutes INT,
  completed BOOLEAN DEFAULT FALSE,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "user_isolation" ON tasks
  USING (auth.uid() = user_id);
```

---

## Tests

```bash
flutter test
```

---

## Autor

**Ismael Manzano León** · ismaelmanzanoleon@gmail.com

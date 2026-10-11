# Kairos

App de productividad en Flutter que funciona sin conexión: tareas, modo foco, hábitos y estadísticas, con las tareas guardadas en el móvil y sincronizadas con Supabase cuando hay red. Gemini sugiere el orden de las tareas desde el servidor, sin que la clave viaje en el móvil.

Caso de estudio: [leosoftware.dev/sistemas/kairos](https://leosoftware.dev/sistemas/kairos).

## Qué hace

- **Tareas:** crear, completar y borrar (también deslizando), con prioridad, energía, tiempo estimado y proyectos; filtros por estado y por proyecto.
- **Modo foco:** temporizador de 25 minutos ligado a una tarea, con sonido al terminar.
- **Hábitos:** seguimiento diario de hábitos propios.
- **Estadísticas:** indicadores, barras de los últimos 7 días, mapa de calor de 28 días y racha.
- **Orden sugerido por IA:** Gemini reordena las tareas pendientes por prioridad.
- **Cuenta y sincronización:** registro, inicio de sesión y recuperación de contraseña con Supabase Auth.
- **Personalización:** tema claro u oscuro y 8 colores de acento.

## Cómo está hecha

- **Primero el móvil.** Las tareas se guardan en Realm, así que se crean y completan sin conexión. Cada una lleva una marca de sincronización, y cuando hay sesión y red las pendientes suben a Supabase. Un aviso indica cuándo no hay conexión.
- **Cada usuario solo ve lo suyo.** PostgreSQL con Row Level Security en Supabase: la comprobación vive en la base de datos, no en cada petición.
- **La IA, en el servidor.** La app llama a la Edge Function `optimize-tasks`, que habla con Gemini. Si Gemini falla o no hay clave configurada, la función devuelve las tareas tal cual, así que la app nunca se queda esperando.
- **Organizada por funcionalidades.** Cada una (`tasks`, `focus`, `habits`, `stats`...) separa datos, lógica y pantalla. El estado lo lleva BLoC, las dependencias se inyectan con GetIt y los errores se devuelven como `Either` (dartz), lo que permite testear la lógica sin levantar la interfaz.

## Estructura

```
KAIROS/
├── kairos/      la app Flutter (lib/core, lib/features, lib/shared, test/)
└── supabase/    migraciones y Edge Functions (optimize-tasks, debt-reflection)
```

La función `debt-reflection` y la tabla de deuda de tiempo están preparadas en Supabase para la "deuda productiva" de la primera versión; la app actual no las usa.

## Stack

| | |
|---|---|
| App | Flutter (Dart ≥ 3.3), flutter_bloc, Realm, GetIt, go_router, dartz |
| Backend | Supabase: Auth, PostgreSQL con RLS, Edge Functions en Deno |
| IA | Google Gemini, desde la Edge Function |
| CI | GitHub Actions: análisis estático y tests de Flutter, comprobación de las Edge Functions y build de iOS en macOS |

## En local

```bash
cd kairos
flutter pub get
flutter run                                   # emulador o dispositivo Android
flutter test
flutter build apk --release --split-per-abi   # APKs en build/app/outputs/apk/release/
```

La URL y la clave pública de Supabase están en `kairos/lib/core/constants/app_constants.dart`; para usar otro proyecto, se cambian ahí. El esquema de la base de datos está en `supabase/migrations/` y la clave de Gemini se configura como secreto de la Edge Function.

Plataforma principal: Android. El build de iOS se comprueba en CI.

## Historia

La primera versión era una app Flutter con Provider que dependía de un servidor FastAPI propio: guardaba las tareas y la deuda de tiempo, y tenía "el confesionario" (una reflexión estoica generada por Gemini) y geovallado. Sin conexión no servía, así que la rehíce con el móvil en el centro y Supabase en lugar del servidor propio. La historia completa está en el caso de estudio.

---

Hecho por [Ismael Manzano León](https://leosoftware.dev).

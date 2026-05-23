import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Error del servidor. La tarea se guardó localmente.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sin conexión. La tarea se sincronizará cuando vuelvas online.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Error al guardar la tarea. Inténtalo de nuevo.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Sesión expirada. Inicia sesión de nuevo.']);
}

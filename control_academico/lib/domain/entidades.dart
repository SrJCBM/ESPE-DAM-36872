abstract interface class Registro {
  int get id;
}

class DatosEstudiante {
  const DatosEstudiante(this.codigo, this.nombres, this.apellidos, this.correo);

  final String codigo;
  final String nombres;
  final String apellidos;
  final String correo;
}

class Estudiante implements Registro {
  const Estudiante(this.id, this.datos);
  @override
  final int id;
  final DatosEstudiante datos;
  String get nombreCompleto => '${datos.nombres} ${datos.apellidos}';
}

class DatosAsignatura {
  const DatosAsignatura(this.codigo, this.nombre);

  final String codigo;
  final String nombre;
}

class Asignatura implements Registro {
  const Asignatura(this.id, this.datos);
  @override
  final int id;
  final DatosAsignatura datos;
}

enum EstadoNota {
  aprobado('Aprobado'),
  recuperacion('Recuperación'),
  reprobado('Reprobado');

  const EstadoNota(this.etiqueta);
  final String etiqueta;

  static EstadoNota para(double nota) {
    if (nota >= 14) return aprobado;
    if (nota >= 9) return recuperacion;
    return reprobado;
  }
}

/// Convierte valores como 14,50 y 14.5. Rechaza más de dos decimales.
double? interpretarNota(String texto) {
  final limpio = texto.trim();
  if (!RegExp(r'^\d{1,2}(?:[.,]\d{1,2})?$').hasMatch(limpio)) return null;
  final valor = double.tryParse(limpio.replaceAll(',', '.'));
  return valor != null && valor >= 0 && valor <= 20 ? valor : null;
}

class Nota implements Registro {
  const Nota({
    required this.id,
    required this.estudianteId,
    required this.asignaturaId,
    required this.valor,
    required this.estado,
  });

  @override
  final int id;
  final int estudianteId;
  final int asignaturaId;
  final double valor;
  final EstadoNota estado;
}

class NotaPorAsignatura {
  const NotaPorAsignatura(this.nota, this.asignatura);
  final Nota nota;
  final Asignatura asignatura;
}

class ResumenAcademico {
  const ResumenAcademico({
    required this.estudiante,
    required this.promedio,
    required this.notas,
  });

  final Estudiante estudiante;
  final double? promedio;
  final List<NotaPorAsignatura> notas;
}

class ErrorAcademico implements Exception {
  const ErrorAcademico(this.mensaje, {this.codigo});
  final String mensaje;
  final String? codigo;
  @override
  String toString() => mensaje;
}

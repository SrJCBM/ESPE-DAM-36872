import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/casos_de_uso.dart';
import '../domain/entidades.dart';
import '../presentation/view_models/view_models.dart';
import '../presentation/views/formularios.dart';
import '../presentation/views/inicio_view.dart';
import '../presentation/views/resumen_view.dart';

class ArgumentosNota {
  const ArgumentosNota({this.nota, this.estudianteId});
  final Nota? nota;
  final int? estudianteId;
}

abstract final class AppRoutes {
  static const inicio = '/';
  static const estudianteFormulario = '/estudiantes/formulario';
  static const estudianteResumen = '/estudiantes/resumen';
  static const asignaturaFormulario = '/asignaturas/formulario';
  static const notaFormulario = '/notas/formulario';

  static Route<dynamic> generar(RouteSettings settings) {
    final argumentos = settings.arguments;
    final contenido = switch ((settings.name, argumentos)) {
      (inicio, _) => const InicioView(),
      (estudianteFormulario, Estudiante? dato) => FormularioCatalogo.estudiante(
        estudiante: dato,
      ),
      (asignaturaFormulario, Asignatura? dato) => FormularioCatalogo.asignatura(
        asignatura: dato,
      ),
      (notaFormulario, ArgumentosNota dato) => FormularioNota(argumentos: dato),
      (estudianteResumen, int id) => ChangeNotifierProvider(
        create: (context) =>
            ResumenViewModel(context.read<GestionarNotas>(), id)..cargar(),
        child: const ResumenView(),
      ),
      _ => Scaffold(
        appBar: AppBar(title: const Text('Ruta no disponible')),
        body: const Center(child: Text('No encontramos esta pantalla.')),
      ),
    };
    if (settings.name == estudianteFormulario ||
        settings.name == asignaturaFormulario ||
        settings.name == notaFormulario) {
      return MaterialPageRoute<bool>(
        settings: settings,
        builder: (_) => contenido,
      );
    }
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => contenido,
    );
  }
}

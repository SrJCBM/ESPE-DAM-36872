import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'data/academico_api.dart';
import 'data/repositorios_api.dart';
import 'domain/casos_de_uso.dart';
import 'domain/entidades.dart';
import 'presentation/tema.dart';
import 'presentation/view_models/view_models.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const ControlAcademicoApp());
}

class ControlAcademicoApp extends StatelessWidget {
  const ControlAcademicoApp({
    super.key,
    this.cliente,
    this.baseUrl = urlAcademica,
  });

  final http.Client? cliente;
  final String baseUrl;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<http.Client>(
          create: (_) => cliente ?? http.Client(),
          dispose: (_, client) => client.close(),
        ),
        Provider<AcademicoApi>(
          create: (context) =>
              AcademicoApi(context.read<http.Client>(), baseUrl: baseUrl),
        ),
        Provider<GestionarCatalogo<Estudiante, DatosEstudiante>>(
          create: (context) =>
              GestionarCatalogo(estudiantesApi(context.read<AcademicoApi>())),
        ),
        Provider<GestionarCatalogo<Asignatura, DatosAsignatura>>(
          create: (context) =>
              GestionarCatalogo(asignaturasApi(context.read<AcademicoApi>())),
        ),
        Provider<GestionarNotas>(
          create: (context) =>
              GestionarNotas(NotasApiRepository(context.read<AcademicoApi>())),
        ),
        ChangeNotifierProvider<EstudiantesViewModel>(
          create: (context) => EstudiantesViewModel(context.read())..cargar(),
        ),
        ChangeNotifierProvider<AsignaturasViewModel>(
          create: (context) => AsignaturasViewModel(context.read())..cargar(),
        ),
        ChangeNotifierProvider<NotasViewModel>(
          create: (context) => NotasViewModel(context.read())..cargar(),
        ),
      ],
      child: MaterialApp(
        title: 'Control académico',
        debugShowCheckedModeBanner: false,
        theme: temaAcademico(Brightness.light),
        darkTheme: temaAcademico(Brightness.dark),
        locale: const Locale('es'),
        supportedLocales: const [Locale('es')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        initialRoute: AppRoutes.inicio,
        onGenerateRoute: AppRoutes.generar,
      ),
    );
  }
}

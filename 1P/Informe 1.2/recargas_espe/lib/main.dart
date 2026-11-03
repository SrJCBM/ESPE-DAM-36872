import 'package:flutter/material.dart';

import 'controlador/sesion_controlador.dart';
import 'controlador/recarga_controlador.dart';
import 'tema/tema_aplicacion.dart';
import 'vista/pantallas/inicio_sesion_pantalla.dart';
import 'vista/pantallas/recarga_pantalla.dart';
import 'vista/pantallas/comprobante_pantalla.dart';

void main() {
  runApp(const MainApp());
}

class RutasApp {
  static const login = '/';
  static const recarga = '/recarga';
  static const comprobante = '/comprobante';
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final _navegador = GlobalKey<NavigatorState>();
  final _auth = SesionControlador();
  final _recargas = RecargaControlador();

  void _ir(String ruta) =>
      _navegador.currentState!.pushNamedAndRemoveUntil(ruta, (_) => false);

  void _salir() {
    _auth.cerrarSesion();
    _recargas.limpiar();
    _ir(RutasApp.login);
  }

  Route<dynamic> _ruta(RouteSettings settings) {
    Widget pantalla;
    final nombre = settings.name;
    if (!_auth.autenticado || nombre == RutasApp.login) {
      pantalla = InicioSesionPantalla(
        auth: _auth,
        onSuccess: () => _ir(RutasApp.recarga),
      );
    } else if (nombre == RutasApp.comprobante && _recargas.ultimo != null) {
      pantalla = ComprobantePantalla(
        comprobante: _recargas.ultimo!,
        onLogout: _salir,
        onNueva: () {
          _recargas.limpiar();
          _ir(RutasApp.recarga);
        },
      );
    } else {
      pantalla = RecargaPantalla(
        controller: _recargas,
        usuario: _auth.usuario!,
        onLogout: _salir,
        onConfirm: () => _ir(RutasApp.comprobante),
      );
    }
    return MaterialPageRoute(settings: settings, builder: (_) => pantalla);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Recargas ESPE',
    debugShowCheckedModeBanner: false,
    theme: TemaAplicacion.claro,
    navigatorKey: _navegador,
    initialRoute: RutasApp.login,
    onGenerateRoute: _ruta,
  );
}

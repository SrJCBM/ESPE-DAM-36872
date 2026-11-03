import 'package:flutter/material.dart';

import '../../controlador/sesion_controlador.dart';
import '../organismos/pagina_base.dart';
import '../organismos/formulario_acceso.dart';

class InicioSesionPantalla extends StatelessWidget {
  const InicioSesionPantalla({
    super.key,
    required this.auth,
    required this.onSuccess,
  });
  final SesionControlador auth;
  final VoidCallback onSuccess;

  @override
  Widget build(BuildContext context) => PaginaBase(
    paso: '01 / ACCESO',
    titulo: 'Todo empieza aquí.',
    descripcion: 'Ingresa para simular una nueva recarga.',
    child: FormularioAcceso(auth: auth, onSuccess: onSuccess),
  );
}

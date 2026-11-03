import 'package:flutter/material.dart';

import '../../controlador/recarga_controlador.dart';
import '../organismos/pagina_base.dart';
import '../organismos/formulario_recarga.dart';

class RecargaPantalla extends StatelessWidget {
  const RecargaPantalla({
    super.key,
    required this.controller,
    required this.usuario,
    required this.onConfirm,
    required this.onLogout,
  });
  final RecargaControlador controller;
  final String usuario;
  final VoidCallback onConfirm;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) => PaginaBase(
    paso: '02 / NUEVA RECARGA',
    titulo: 'Conecta en segundos.',
    descripcion: 'Hola, $usuario. Completa los datos y revisa el total.',
    onLogout: onLogout,
    child: FormularioRecarga(
      controller: controller,
      usuario: usuario,
      onConfirm: onConfirm,
    ),
  );
}

import 'package:flutter/material.dart';

import '../atomos/etiqueta_estado.dart';

/// Organismo que da la misma estructura adaptable a las tres pantallas.
class PaginaBase extends StatelessWidget {
  const PaginaBase({
    super.key,
    required this.titulo,
    required this.descripcion,
    required this.paso,
    required this.child,
    this.onLogout,
  });
  final String titulo;
  final String descripcion;
  final String paso;
  final Widget child;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt_rounded),
          SizedBox(width: 6),
          Flexible(
            child: Text(
              'Recargas ESPE',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ),
        ],
      ),
      actions: onLogout == null
          ? null
          : [
              IconButton(
                tooltip: 'Cerrar sesión',
                onPressed: onLogout,
                icon: const Icon(Icons.logout),
              ),
            ],
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EtiquetaEstado(texto: paso),
                const SizedBox(height: 20),
                Text(titulo, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(descripcion, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 28),
                child,
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    'Simulación académica · sin recargas reales',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Color(0xFF53665C)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

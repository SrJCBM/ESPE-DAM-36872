import 'package:flutter/material.dart';

import '../../domain/entidades.dart';

class Contenido extends StatelessWidget {
  const Contenido({super.key, required this.children, this.recargar});

  final List<Widget> children;
  final Future<void> Function()? recargar;

  @override
  Widget build(BuildContext context) {
    final lista = ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ],
    );
    return recargar == null
        ? lista
        : RefreshIndicator(onRefresh: recargar!, child: lista);
  }
}

class Encabezado extends StatelessWidget {
  const Encabezado(this.titulo, this.subtitulo, {super.key});

  final String titulo;
  final String subtitulo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: tema.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitulo,
            style: tema.textTheme.bodyMedium?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class PanelEstado extends StatelessWidget {
  const PanelEstado({
    super.key,
    required this.icono,
    required this.titulo,
    required this.mensaje,
    this.accion,
    this.etiqueta = 'Reintentar',
  });

  final IconData icono;
  final String titulo;
  final String mensaje;
  final VoidCallback? accion;
  final String etiqueta;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: tema.colorScheme.surfaceContainerLow,
        border: Border.all(color: tema.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
      child: Column(
        children: [
          Icon(icono, color: tema.colorScheme.primary, size: 34),
          const SizedBox(height: 12),
          Text(
            titulo,
            style: tema.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(mensaje, textAlign: TextAlign.center),
          if (accion != null) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: accion, child: Text(etiqueta)),
          ],
        ],
      ),
    );
  }
}

class FilaRegistro extends StatelessWidget {
  const FilaRegistro({
    super.key,
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    this.onTap,
    this.trailing,
    this.detalle,
  });

  final IconData icono;
  final String titulo;
  final String subtitulo;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Widget? detalle;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: tema.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: tema.colorScheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: tema.colorScheme.primaryContainer,
            foregroundColor: tema.colorScheme.onPrimaryContainer,
            child: Icon(icono, size: 20),
          ),
          title: Text(
            titulo,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: detalle == null
              ? Text(subtitulo)
              : Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(subtitulo),
                      const SizedBox(height: 5),
                      detalle!,
                    ],
                  ),
                ),
          trailing:
              trailing ??
              (onTap == null ? null : const Icon(Icons.chevron_right_rounded)),
          onTap: onTap,
        ),
      ),
    );
  }
}

class EstadoEtiqueta extends StatelessWidget {
  const EstadoEtiqueta(this.estado, {super.key});
  final EstadoNota estado;

  @override
  Widget build(BuildContext context) {
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    final (fondo, tinta) = switch (estado) {
      EstadoNota.aprobado =>
        oscuro
            ? (const Color(0xFF184938), const Color(0xFFAFF5C8))
            : (const Color(0xFFD9F4E2), const Color(0xFF155339)),
      EstadoNota.recuperacion =>
        oscuro
            ? (const Color(0xFF503715), const Color(0xFFFFD595))
            : (const Color(0xFFFFEBC8), const Color(0xFF704300)),
      EstadoNota.reprobado =>
        oscuro
            ? (const Color(0xFF632B31), const Color(0xFFFFCCD0))
            : (const Color(0xFFFFE1E3), const Color(0xFF84232E)),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(
          estado.etiqueta,
          style: TextStyle(
            color: tinta,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

String notaVisible(double valor) =>
    valor.toStringAsFixed(2).replaceAll('.', ',');

void informar(BuildContext context, String mensaje) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
}

Future<bool> confirmarBorrado(BuildContext context, String mensaje) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    ) ??
    false;

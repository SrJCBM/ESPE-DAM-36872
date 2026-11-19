import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entidades.dart';
import '../../routes/app_routes.dart';
import '../view_models/view_models.dart';
import '../widgets/comunes.dart';

class EstudiantesView extends StatelessWidget {
  const EstudiantesView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EstudiantesViewModel>();
    return _Listado<Estudiante>(
      titulo: 'Estudiantes',
      subtitulo: 'Consulta sus fichas y promedios.',
      buscador: 'Buscar por nombre o código',
      etiquetaNuevo: 'Nuevo estudiante',
      tituloVacio: 'Aún no hay estudiantes',
      detalleVacio: 'Registra el primero para asignarle calificaciones.',
      icono: Icons.groups_2_outlined,
      vm: vm,
      buscar: (dato) => '${dato.nombreCompleto} ${dato.datos.codigo}',
      nuevo: () async {
        if (await Navigator.pushNamed<bool>(
                  context,
                  AppRoutes.estudianteFormulario,
                ) ==
                true &&
            context.mounted) {
          informar(context, 'Estudiante registrado.');
        }
      },
      fila: (dato) => FilaRegistro(
        icono: Icons.person_outline_rounded,
        titulo: dato.nombreCompleto,
        subtitulo: dato.datos.codigo,
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.estudianteResumen,
          arguments: dato.id,
        ),
      ),
    );
  }
}

class AsignaturasView extends StatelessWidget {
  const AsignaturasView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AsignaturasViewModel>();
    return _Listado<Asignatura>(
      titulo: 'Asignaturas',
      subtitulo: 'Administra las materias del registro académico.',
      buscador: 'Buscar por nombre o código',
      etiquetaNuevo: 'Nueva asignatura',
      tituloVacio: 'Aún no hay asignaturas',
      detalleVacio: 'Crea una asignatura para registrar sus notas.',
      icono: Icons.menu_book_outlined,
      vm: vm,
      buscar: (dato) => '${dato.datos.nombre} ${dato.datos.codigo}',
      nuevo: () async {
        if (await Navigator.pushNamed<bool>(
                  context,
                  AppRoutes.asignaturaFormulario,
                ) ==
                true &&
            context.mounted) {
          informar(context, 'Asignatura registrada.');
        }
      },
      fila: (dato) => FilaRegistro(
        icono: Icons.menu_book_outlined,
        titulo: dato.datos.nombre,
        subtitulo: dato.datos.codigo,
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.asignaturaFormulario,
          arguments: dato,
        ),
        trailing: PopupMenuButton<String>(
          tooltip: 'Opciones de ${dato.datos.nombre}',
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'editar', child: Text('Editar')),
            PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
          ],
          onSelected: (accion) async {
            if (accion == 'editar') {
              if (await Navigator.pushNamed<bool>(
                        context,
                        AppRoutes.asignaturaFormulario,
                        arguments: dato,
                      ) ==
                      true &&
                  context.mounted) {
                informar(context, 'Asignatura actualizada.');
              }
              return;
            }
            final confirmar = await confirmarBorrado(
              context,
              '¿Eliminar ${dato.datos.nombre}?',
            );
            if (!confirmar || !context.mounted) return;
            final ok = await vm.eliminar(dato.id);
            if (!context.mounted) return;
            informar(
              context,
              ok
                  ? 'Asignatura eliminada.'
                  : vm.errorOperacion ?? 'Intenta de nuevo.',
            );
          },
        ),
      ),
    );
  }
}

class NotasView extends StatelessWidget {
  const NotasView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotasViewModel>();
    final estudiantes = context.watch<EstudiantesViewModel>();
    final asignaturas = context.watch<AsignaturasViewModel>();

    String estudiante(Nota nota) =>
        estudiantes.buscar(nota.estudianteId)?.nombreCompleto ??
        'Estudiante #${nota.estudianteId}';
    String asignatura(Nota nota) =>
        asignaturas.buscar(nota.asignaturaId)?.datos.nombre ??
        'Asignatura #${nota.asignaturaId}';

    return _Listado<Nota>(
      titulo: 'Notas',
      subtitulo: 'Registra y revisa las calificaciones finales.',
      buscador: 'Buscar por estudiante o asignatura',
      etiquetaNuevo: 'Registrar nota',
      tituloVacio: 'Aún no hay notas',
      detalleVacio: 'Selecciona un estudiante y una asignatura para registrar una calificación.',
      icono: Icons.assignment_outlined,
      vm: vm,
      buscar: (dato) => '${estudiante(dato)} ${asignatura(dato)}',
      refrescar: () async {
        await Future.wait([
          vm.cargar(),
          estudiantes.cargar(),
          asignaturas.cargar(),
        ]);
      },
      nuevo: () async {
        if (await Navigator.pushNamed<bool>(
                  context,
                  AppRoutes.notaFormulario,
                  arguments: const ArgumentosNota(),
                ) ==
                true &&
            context.mounted) {
          informar(context, 'Nota registrada.');
        }
      },
      fila: (dato) => FilaNota(
        nota: dato,
        titulo: asignatura(dato),
        subtitulo: estudiante(dato),
      ),
    );
  }
}

class FilaNota extends StatelessWidget {
  const FilaNota({
    super.key,
    required this.nota,
    required this.titulo,
    this.subtitulo,
    this.alCambiar,
  });

  final Nota nota;
  final String titulo;
  final String? subtitulo;
  final Future<void> Function()? alCambiar;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotasViewModel>();
    return FilaRegistro(
      icono: Icons.assignment_outlined,
      titulo: titulo,
      subtitulo: [?subtitulo, '${notaVisible(nota.valor)} / 20'].join(' · '),
      detalle: EstadoEtiqueta(nota.estado),
      onTap: vm.guardando ? null : () => _editar(context),
      trailing: PopupMenuButton<String>(
        enabled: !vm.guardando,
        tooltip: 'Opciones de la nota',
        itemBuilder: (context) => const [
          PopupMenuItem(value: 'editar', child: Text('Editar nota')),
          PopupMenuItem(value: 'eliminar', child: Text('Eliminar nota')),
        ],
        onSelected: (accion) async {
          if (accion == 'editar') {
            await _editar(context);
            return;
          }
          if (!await confirmarBorrado(
                context,
                '¿Eliminar la nota de $titulo?',
              ) ||
              !context.mounted) {
            return;
          }
          final ok = await vm.eliminar(nota.id);
          if (!context.mounted) return;
          informar(
            context,
            ok ? 'Nota eliminada.' : vm.errorOperacion ?? 'Intenta de nuevo.',
          );
          if (ok) await alCambiar?.call();
        },
      ),
    );
  }

  Future<void> _editar(BuildContext context) async {
    final ok = await Navigator.pushNamed<bool>(
      context,
      AppRoutes.notaFormulario,
      arguments: ArgumentosNota(nota: nota),
    );
    if (ok != true || !context.mounted) return;
    informar(context, 'Nota actualizada.');
    await alCambiar?.call();
  }
}

class _Listado<T extends Registro> extends StatefulWidget {
  const _Listado({
    required this.titulo,
    required this.subtitulo,
    required this.buscador,
    required this.etiquetaNuevo,
    required this.tituloVacio,
    required this.detalleVacio,
    required this.icono,
    required this.vm,
    required this.buscar,
    required this.nuevo,
    required this.fila,
    this.refrescar,
  });

  final String titulo,
      subtitulo,
      buscador,
      etiquetaNuevo,
      tituloVacio,
      detalleVacio;
  final IconData icono;
  final ColeccionViewModel<T> vm;
  final String Function(T) buscar;
  final VoidCallback nuevo;
  final Widget Function(T) fila;
  final Future<void> Function()? refrescar;

  @override
  State<_Listado<T>> createState() => _ListadoState<T>();
}

class _ListadoState<T extends Registro> extends State<_Listado<T>> {
  String _busqueda = '';

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    final items = vm.items.where(
      (dato) => widget.buscar(dato).toLowerCase().contains(_busqueda),
    );
    final recargar = widget.refrescar ?? vm.cargar;

    return Contenido(
      recargar: recargar,
      children: [
        Encabezado(widget.titulo, widget.subtitulo),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: vm.guardando ? null : widget.nuevo,
            icon: const Icon(Icons.add_rounded),
            label: Text(widget.etiquetaNuevo),
          ),
        ),
        const SizedBox(height: 16),
        if (vm.items.isNotEmpty) ...[
          TextField(
            onChanged: (texto) =>
                setState(() => _busqueda = texto.trim().toLowerCase()),
            decoration: InputDecoration(
              labelText: widget.buscador,
              prefixIcon: const Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (vm.cargando) ...[
          const LinearProgressIndicator(),
          const SizedBox(height: 16),
        ],
        if (vm.errorCarga case final String error) ...[
          PanelEstado(
            icono: Icons.cloud_off_outlined,
            titulo: 'No pudimos actualizar la lista',
            mensaje: error,
            accion: recargar,
          ),
          const SizedBox(height: 12),
        ],
        if (items.isEmpty && !vm.cargando && vm.errorCarga == null)
          PanelEstado(
            icono: _busqueda.isEmpty ? widget.icono : Icons.search_off_rounded,
            titulo: _busqueda.isEmpty
                ? widget.tituloVacio
                : 'Sin coincidencias',
            mensaje: _busqueda.isEmpty
                ? widget.detalleVacio
                : 'Prueba con otra búsqueda.',
          ),
        for (final dato in items) widget.fila(dato),
      ],
    );
  }
}

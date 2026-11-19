import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entidades.dart';
import '../../routes/app_routes.dart';
import '../view_models/view_models.dart';
import '../widgets/comunes.dart';
import 'catalogos.dart';

class ResumenView extends StatelessWidget {
  const ResumenView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ResumenViewModel>();
    final catalogo = context.watch<EstudiantesViewModel>();
    final resumen = vm.resumen;
    final estudiante = resumen?.estudiante ?? catalogo.buscar(vm.estudianteId);
    final colores = Theme.of(context).colorScheme;
    final promedio = resumen?.promedio;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ficha del estudiante'),
        actions: [
          if (estudiante != null)
            PopupMenuButton<String>(
              enabled: !catalogo.guardando,
              tooltip: 'Opciones del estudiante',
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'editar',
                  child: Text('Editar estudiante'),
                ),
                PopupMenuItem(
                  value: 'eliminar',
                  child: Text('Eliminar estudiante'),
                ),
              ],
              onSelected: (accion) async {
                if (accion == 'editar') {
                  final ok = await Navigator.pushNamed<bool>(
                    context,
                    AppRoutes.estudianteFormulario,
                    arguments: estudiante,
                  );
                  if (ok == true && context.mounted) {
                    informar(context, 'Estudiante actualizado.');
                    await vm.cargar();
                  }
                  return;
                }

                if (!await confirmarBorrado(
                      context,
                      '¿Eliminar a ${estudiante.nombreCompleto}?',
                    ) ||
                    !context.mounted) {
                  return;
                }
                final ok = await catalogo.eliminar(estudiante.id);
                if (!context.mounted) return;
                if (ok) Navigator.pop(context);
                informar(
                  context,
                  ok
                      ? 'Estudiante eliminado.'
                      : catalogo.errorOperacion ?? 'Intenta de nuevo.',
                );
              },
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Contenido(
          recargar: vm.cargar,
          children: [
            if (estudiante != null)
              Encabezado(
                estudiante.nombreCompleto,
                '${estudiante.datos.codigo} · ${estudiante.datos.correo}',
              ),
            if (vm.cargando) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 16),
            ],
            if (vm.error case final String error) ...[
              PanelEstado(
                icono: Icons.cloud_off_outlined,
                titulo: 'No pudimos cargar la ficha',
                mensaje: error,
                accion: vm.cargar,
              ),
              const SizedBox(height: 16),
            ],
            if (resumen != null) ...[
              Container(
                key: const ValueKey('promedio_general'),
                decoration: BoxDecoration(
                  color: colores.primaryContainer,
                  borderRadius: BorderRadius.circular(22),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Promedio general',
                      style: TextStyle(
                        color: colores.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      promedio == null
                          ? 'Sin promedio'
                          : '${notaVisible(promedio)} / 20',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: colores.onPrimaryContainer,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${resumen.notas.length} notas registradas',
                      style: TextStyle(color: colores.onPrimaryContainer),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Registrar nota'),
                  onPressed: () async {
                    final ok = await Navigator.pushNamed<bool>(
                      context,
                      AppRoutes.notaFormulario,
                      arguments: ArgumentosNota(
                        estudianteId: resumen.estudiante.id,
                      ),
                    );
                    if (ok == true && context.mounted) {
                      informar(context, 'Nota registrada.');
                      await vm.cargar();
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
              if (resumen.notas.isEmpty)
                const PanelEstado(
                  icono: Icons.assignment_outlined,
                  titulo: 'Sin calificaciones',
                  mensaje: 'Las notas por asignatura aparecerán aquí.',
                )
              else ...[
                SegmentedButton<FiltroNotas>(
                  key: const ValueKey('filtro_notas'),
                  showSelectedIcon: false,
                  segments: [
                    for (final filtro in FiltroNotas.values)
                      ButtonSegment(
                        value: filtro,
                        label: Text(filtro.etiqueta),
                      ),
                  ],
                  selected: {vm.filtro},
                  onSelectionChanged: (seleccion) =>
                      vm.filtrar(seleccion.first),
                ),
                const SizedBox(height: 16),
                if (vm.notasVisibles.isEmpty)
                  PanelEstado(
                    icono: Icons.filter_list_off,
                    titulo:
                        'No hay calificaciones ${vm.filtro.etiqueta.toLowerCase()}',
                    mensaje:
                        'Las demás calificaciones siguen disponibles en Todas.',
                    accion: () => vm.filtrar(FiltroNotas.todas),
                    etiqueta: 'Ver todas',
                  ),
              ],
              for (final item in vm.notasVisibles)
                FilaNota(
                  nota: item.nota,
                  titulo: item.asignatura.datos.nombre,
                  alCambiar: vm.cargar,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

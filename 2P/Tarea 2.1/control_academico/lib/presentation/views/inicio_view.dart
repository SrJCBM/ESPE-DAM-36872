import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/view_models.dart';
import '../widgets/comunes.dart';
import 'catalogos.dart';

class InicioView extends StatefulWidget {
  const InicioView({super.key});

  @override
  State<InicioView> createState() => _InicioViewState();
}

class _InicioViewState extends State<InicioView> {
  int _seccion = 0;

  static const _destinos = [
    (
      icono: Icons.space_dashboard_outlined,
      activo: Icons.space_dashboard_rounded,
      nombre: 'Inicio',
    ),
    (
      icono: Icons.groups_2_outlined,
      activo: Icons.groups_2_rounded,
      nombre: 'Estudiantes',
    ),
    (
      icono: Icons.menu_book_outlined,
      activo: Icons.menu_book_rounded,
      nombre: 'Asignaturas',
    ),
    (
      icono: Icons.assignment_outlined,
      activo: Icons.assignment_rounded,
      nombre: 'Notas',
    ),
  ];

  void _ir(int indice) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _seccion = indice);
  }

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.sizeOf(context).width >= 850;
    final colores = Theme.of(context).colorScheme;
    final paginas = IndexedStack(
      index: _seccion,
      children: [
        _PanelInicio(alElegir: _ir),
        const EstudiantesView(),
        const AsignaturasView(),
        const NotasView(),
      ],
    );
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colores.primary,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                Icons.school_rounded,
                size: 21,
                color: colores.onPrimary,
              ),
            ),
            const SizedBox(width: 10),
            const Flexible(
              child: Text(
                'Control académico',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: ancho,
        child: ancho
            ? Row(
                children: [
                  NavigationRail(
                    selectedIndex: _seccion,
                    onDestinationSelected: _ir,
                    labelType: NavigationRailLabelType.all,
                    destinations: [
                      for (final destino in _destinos)
                        NavigationRailDestination(
                          icon: Icon(destino.icono),
                          selectedIcon: Icon(destino.activo),
                          label: Text(destino.nombre),
                        ),
                    ],
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: paginas),
                ],
              )
            : paginas,
      ),
      bottomNavigationBar: ancho
          ? null
          : NavigationBar(
              selectedIndex: _seccion,
              onDestinationSelected: _ir,
              destinations: [
                for (final destino in _destinos)
                  NavigationDestination(
                    icon: Icon(destino.icono),
                    selectedIcon: Icon(destino.activo),
                    label: destino.nombre,
                  ),
              ],
            ),
    );
  }
}

class _PanelInicio extends StatelessWidget {
  const _PanelInicio({required this.alElegir});
  final ValueChanged<int> alElegir;

  @override
  Widget build(BuildContext context) {
    final estudiantes = context.watch<EstudiantesViewModel>();
    final asignaturas = context.watch<AsignaturasViewModel>();
    final notas = context.watch<NotasViewModel>();
    final tema = Theme.of(context);
    final error =
        estudiantes.errorCarga ?? asignaturas.errorCarga ?? notas.errorCarga;
    final cargando =
        estudiantes.cargando || asignaturas.cargando || notas.cargando;

    Future<void> recargar() async {
      await Future.wait([
        estudiantes.cargar(),
        asignaturas.cargar(),
        notas.cargar(),
      ]);
    }

    return Contenido(
      recargar: recargar,
      children: [
        Semantics(
          header: true,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF272052),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.school_outlined,
                  color: Color(0xFFD7CCFF),
                  size: 29,
                ),
                const SizedBox(height: 16),
                Text(
                  'Registro académico',
                  style: tema.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gestiona calificaciones y consulta el promedio de cada estudiante.',
                  style: tema.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFE2DBFF),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (cargando) ...[
          const LinearProgressIndicator(),
          const SizedBox(height: 14),
        ],
        if (error != null) ...[
          PanelEstado(
            icono: Icons.cloud_off_outlined,
            titulo: 'No pudimos actualizar los datos',
            mensaje: error,
            accion: recargar,
          ),
          const SizedBox(height: 16),
        ],
        Text(
          'Resumen',
          style: tema.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        FilaRegistro(
          icono: Icons.groups_2_outlined,
          titulo: 'Estudiantes',
          subtitulo: _cantidad(estudiantes, 'registrados'),
          onTap: () => alElegir(1),
        ),
        FilaRegistro(
          icono: Icons.menu_book_outlined,
          titulo: 'Asignaturas',
          subtitulo: _cantidad(asignaturas, 'registradas'),
          onTap: () => alElegir(2),
        ),
        FilaRegistro(
          icono: Icons.assignment_outlined,
          titulo: 'Notas',
          subtitulo: _cantidad(notas, 'registradas'),
          onTap: () => alElegir(3),
        ),
      ],
    );
  }
}

String _cantidad(ColeccionViewModel vm, String sufijo) {
  if (vm.cargando && vm.items.isEmpty) return 'Cargando…';
  if (vm.errorCarga != null && vm.items.isEmpty) return 'Sin conexión';
  return '${vm.items.length} $sufijo';
}

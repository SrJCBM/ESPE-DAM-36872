import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entidades.dart';
import '../../routes/app_routes.dart';
import '../view_models/view_models.dart';
import '../widgets/comunes.dart';

class FormularioCatalogo extends StatefulWidget {
  const FormularioCatalogo.estudiante({super.key, this.estudiante})
    : esEstudiante = true,
      asignatura = null;

  const FormularioCatalogo.asignatura({super.key, this.asignatura})
    : esEstudiante = false,
      estudiante = null;

  final bool esEstudiante;
  final Estudiante? estudiante;
  final Asignatura? asignatura;

  @override
  State<FormularioCatalogo> createState() => _FormularioCatalogoState();
}

class _FormularioCatalogoState extends State<FormularioCatalogo> {
  final _form = GlobalKey<FormState>();
  late final _codigo = TextEditingController(
    text: widget.estudiante?.datos.codigo ?? widget.asignatura?.datos.codigo,
  );
  late final _nombre = TextEditingController(
    text: widget.estudiante?.datos.nombres ?? widget.asignatura?.datos.nombre,
  );
  late final _apellidos = TextEditingController(
    text: widget.estudiante?.datos.apellidos,
  );
  late final _correo = TextEditingController(
    text: widget.estudiante?.datos.correo,
  );
  String? _error;

  @override
  void dispose() {
    _codigo.dispose();
    _nombre.dispose();
    _apellidos.dispose();
    _correo.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _error = null);
    final codigo = _codigo.text.trim().toUpperCase();
    final nombre = _nombre.text.trim();
    if (widget.esEstudiante) {
      final vm = context.read<EstudiantesViewModel>();
      final guardado = await vm.guardar(
        DatosEstudiante(
          codigo,
          nombre,
          _apellidos.text.trim(),
          _correo.text.trim(),
        ),
        id: widget.estudiante?.id,
      );
      if (!mounted) return;
      if (guardado) {
        Navigator.pop(context, true);
      } else {
        setState(() => _error = vm.errorOperacion);
      }
    } else {
      final vm = context.read<AsignaturasViewModel>();
      final guardado = await vm.guardar(
        DatosAsignatura(codigo, nombre),
        id: widget.asignatura?.id,
      );
      if (!mounted) return;
      if (guardado) {
        Navigator.pop(context, true);
      } else {
        setState(() => _error = vm.errorOperacion);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEstudiante = widget.esEstudiante;
    final editando = widget.estudiante != null || widget.asignatura != null;
    final guardando = esEstudiante
        ? context.select<EstudiantesViewModel, bool>((vm) => vm.guardando)
        : context.select<AsignaturasViewModel, bool>((vm) => vm.guardando);
    final titulo = esEstudiante
        ? (editando ? 'Editar estudiante' : 'Nuevo estudiante')
        : (editando ? 'Editar asignatura' : 'Nueva asignatura');

    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: SafeArea(
        top: false,
        child: Form(
          key: _form,
          child: Contenido(
            children: [
              Encabezado(
                esEstudiante
                    ? 'Datos del estudiante'
                    : 'Datos de la asignatura',
                'Completa los campos obligatorios.',
              ),
              TextFormField(
                key: const ValueKey('campo_codigo'),
                controller: _codigo,
                enabled: !guardando,
                maxLength: 32,
                decoration: const InputDecoration(
                  labelText: 'Código',
                  hintText: 'Ej. 001',
                ),
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.next,
                validator: (texto) =>
                    RegExp(r'^[a-zA-Z0-9._-]{1,32}$')
                        .hasMatch(texto?.trim() ?? '')
                    ? null
                    : 'Usa letras sin tildes, números, punto, guion o guion bajo.',
              ),
              const SizedBox(height: 10),
              TextFormField(
                key: const ValueKey('campo_nombre'),
                controller: _nombre,
                enabled: !guardando,
                maxLength: esEstudiante ? 100 : 150,
                decoration: InputDecoration(
                  labelText: esEstudiante ? 'Nombres' : 'Nombre',
                ),
                textCapitalization: TextCapitalization.words,
                textInputAction: esEstudiante
                    ? TextInputAction.next
                    : TextInputAction.done,
                validator: _requerido,
              ),
              if (esEstudiante) ...[
                const SizedBox(height: 10),
                TextFormField(
                  key: const ValueKey('campo_apellidos'),
                  controller: _apellidos,
                  enabled: !guardando,
                  maxLength: 100,
                  decoration: const InputDecoration(labelText: 'Apellidos'),
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: _requerido,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  key: const ValueKey('campo_correo'),
                  controller: _correo,
                  enabled: !guardando,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                  ),
                  validator: (texto) {
                    final correo = texto?.trim() ?? '';
                    return correo.length <= 254 &&
                            RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                .hasMatch(correo)
                        ? null
                        : 'Ingresa un correo válido.';
                  },
                ),
              ],
              const SizedBox(height: 24),
              _PieFormulario(
                guardando: guardando,
                onGuardar: _guardar,
                error: _error,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String? _requerido(String? valor) =>
    (valor?.trim().isEmpty ?? true) ? 'Este campo es obligatorio.' : null;

class FormularioNota extends StatefulWidget {
  const FormularioNota({super.key, required this.argumentos});
  final ArgumentosNota argumentos;

  @override
  State<FormularioNota> createState() => _FormularioNotaState();
}

class _FormularioNotaState extends State<FormularioNota> {
  final _form = GlobalKey<FormState>();
  Nota? get _nota => widget.argumentos.nota;
  late int? _estudiante = widget.argumentos.estudianteId ?? _nota?.estudianteId;
  int? _asignatura;
  late final _valor = TextEditingController(
    text: _nota == null ? '' : notaVisible(_nota!.valor),
  );
  String? _error;

  @override
  void dispose() {
    _valor.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    final vm = context.read<NotasViewModel>();
    final calificacion = interpretarNota(_valor.text)!;
    setState(() => _error = null);
    final ok = _nota == null
        ? await vm.registrar(_estudiante!, _asignatura!, calificacion)
        : await vm.editar(_nota!.id, calificacion);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
    } else {
      setState(() => _error = vm.errorOperacion);
    }
  }

  @override
  Widget build(BuildContext context) {
    final estudiantes = context.watch<EstudiantesViewModel>();
    final asignaturas = context.watch<AsignaturasViewModel>();
    final guardando = context.select<NotasViewModel, bool>(
      (vm) => vm.guardando,
    );
    final editando = _nota != null;
    final disponible =
        editando ||
        (estudiantes.items.isNotEmpty && asignaturas.items.isNotEmpty);
    final carga = estudiantes.cargando || asignaturas.cargando;
    final errorCatalogos = estudiantes.errorCarga ?? asignaturas.errorCarga;
    final estudianteActual = estudiantes.buscar(_estudiante ?? 0)?.id;
    final asignaturaActual = asignaturas.buscar(_asignatura ?? 0)?.id;

    return Scaffold(
      appBar: AppBar(title: Text(editando ? 'Editar nota' : 'Registrar nota')),
      body: SafeArea(
        top: false,
        child: Form(
          key: _form,
          child: Contenido(
            children: [
              Encabezado(
                'Calificación final',
                editando
                    ? 'Actualiza el valor de esta calificación.'
                    : 'Selecciona el estudiante y la asignatura.',
              ),
              if (!editando && !disponible && carga)
                const LinearProgressIndicator()
              else if (!editando && !disponible && errorCatalogos != null)
                PanelEstado(
                  icono: Icons.cloud_off_outlined,
                  titulo: 'No pudimos cargar los catálogos',
                  mensaje: errorCatalogos,
                  accion: () {
                    estudiantes.cargar();
                    asignaturas.cargar();
                  },
                )
              else if (!editando && !disponible)
                PanelEstado(
                  icono: Icons.playlist_add_rounded,
                  titulo: 'Completa los catálogos',
                  mensaje: 'Para registrar una nota necesitas al menos un estudiante y una asignatura.',
                  etiqueta: estudiantes.items.isEmpty
                      ? 'Nuevo estudiante'
                      : 'Nueva asignatura',
                  accion: () => Navigator.pushNamed(
                    context,
                    estudiantes.items.isEmpty
                        ? AppRoutes.estudianteFormulario
                        : AppRoutes.asignaturaFormulario,
                  ),
                )
              else ...[
                if (editando)
                  FilaRegistro(
                    icono: Icons.assignment_outlined,
                    titulo:
                        asignaturas.buscar(_nota!.asignaturaId)?.datos.nombre ??
                        'Asignatura #${_nota!.asignaturaId}',
                    subtitulo:
                        estudiantes
                            .buscar(_nota!.estudianteId)
                            ?.nombreCompleto ??
                        'Estudiante #${_nota!.estudianteId}',
                  )
                else ...[
                  DropdownButtonFormField<int>(
                    key: const ValueKey('campo_estudiante'),
                    initialValue: estudianteActual,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Estudiante'),
                    items: [
                      for (final estudiante in estudiantes.items)
                        DropdownMenuItem(
                          value: estudiante.id,
                          child: Text(
                            estudiante.nombreCompleto,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: guardando ? null : (id) => _estudiante = id,
                    validator: (id) =>
                        id == null || estudiantes.buscar(id) == null
                        ? 'Selecciona un estudiante.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    key: const ValueKey('campo_asignatura'),
                    initialValue: asignaturaActual,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Asignatura'),
                    items: [
                      for (final asignatura in asignaturas.items)
                        DropdownMenuItem(
                          value: asignatura.id,
                          child: Text(
                            asignatura.datos.nombre,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: guardando ? null : (id) => _asignatura = id,
                    validator: (id) =>
                        id == null || asignaturas.buscar(id) == null
                        ? 'Selecciona una asignatura.'
                        : null,
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  key: const ValueKey('campo_nota'),
                  controller: _valor,
                  enabled: !guardando,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Nota sobre 20',
                    hintText: 'Ej. 14,50',
                    helperText: 'Acepta hasta dos decimales.',
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (texto) => interpretarNota(texto ?? '') == null
                      ? 'Ingresa una nota de 0 a 20 con hasta dos decimales.'
                      : null,
                ),
                if (interpretarNota(_valor.text) case final double valor) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: EstadoEtiqueta(EstadoNota.para(valor)),
                  ),
                ],
                const SizedBox(height: 24),
                _PieFormulario(
                  guardando: guardando,
                  onGuardar: _guardar,
                  error: _error,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PieFormulario extends StatelessWidget {
  const _PieFormulario({
    required this.guardando,
    required this.onGuardar,
    this.error,
  });
  final bool guardando;
  final VoidCallback onGuardar;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Semantics(
              liveRegion: true,
              child: Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        FilledButton.icon(
          onPressed: guardando ? null : onGuardar,
          icon: guardando
              ? const SizedBox.square(
                  dimension: 17,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check_rounded),
          label: Text(guardando ? 'Guardando…' : 'Guardar'),
        ),
      ],
    );
  }
}

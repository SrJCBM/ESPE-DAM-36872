import 'package:flutter/material.dart';

import '../../controlador/sesion_controlador.dart';
import '../atomos/boton_principal.dart';
import '../moleculas/entrada_campo.dart';

class FormularioAcceso extends StatefulWidget {
  const FormularioAcceso({
    super.key,
    required this.auth,
    required this.onSuccess,
  });
  final SesionControlador auth;
  final VoidCallback onSuccess;

  @override
  State<FormularioAcceso> createState() => _FormularioAccesoState();
}

class _FormularioAccesoState extends State<FormularioAcceso> {
  final _form = GlobalKey<FormState>();
  final _usuario = TextEditingController();
  final _clave = TextEditingController();
  bool _oculta = true;
  String? _error;

  @override
  void dispose() {
    _usuario.dispose();
    _clave.dispose();
    super.dispose();
  }

  void _enviar() {
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    if (!_form.currentState!.validate()) return;
    if (widget.auth.iniciarSesion(_usuario.text, _clave.text)) {
      widget.onSuccess();
    } else {
      setState(() => _error = 'Usuario o contraseña incorrectos.');
    }
  }

  @override
  Widget build(BuildContext context) => Form(
    key: _form,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EntradaCampo(
          controller: _usuario,
          etiqueta: 'Usuario',
          icono: Icons.person_outline,
          validator: widget.auth.validarUsuario,
        ),
        EntradaCampo(
          controller: _clave,
          etiqueta: 'Contraseña',
          icono: Icons.lock_outline,
          validator: widget.auth.validarClave,
          obscureText: _oculta,
          suffix: IconButton(
            tooltip: _oculta ? 'Mostrar contraseña' : 'Ocultar contraseña',
            onPressed: () => setState(() => _oculta = !_oculta),
            icon: Icon(
              _oculta
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        BotonPrincipal(texto: 'Iniciar sesión', onPressed: _enviar),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            _form.currentState!.reset();
            _usuario.clear();
            _clave.clear();
            setState(() {
              _error = null;
              _oculta = true;
            });
          },
          child: const Text('Limpiar'),
        ),
        const SizedBox(height: 24),
        const Text(
          'Acceso de práctica',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        const Text('Usuario: admin\nContraseña: Admin123*'),
      ],
    ),
  );
}

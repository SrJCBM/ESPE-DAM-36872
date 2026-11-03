import 'package:flutter/material.dart';

import '../../controlador/recarga_controlador.dart';
import '../../modelo/recarga.dart';
import '../atomos/boton_principal.dart';
import '../moleculas/entrada_campo.dart';
import '../moleculas/resumen_montos.dart';

class FormularioRecarga extends StatefulWidget {
  const FormularioRecarga({
    super.key,
    required this.controller,
    required this.usuario,
    required this.onConfirm,
  });
  final RecargaControlador controller;
  final String usuario;
  final VoidCallback onConfirm;

  @override
  State<FormularioRecarga> createState() => _FormularioRecargaState();
}

class _FormularioRecargaState extends State<FormularioRecarga> {
  final _form = GlobalKey<FormState>();
  final _telefono = TextEditingController();
  final _valor = TextEditingController();
  Operadora? _operadora;
  FormaPago? _pago;

  @override
  void dispose() {
    _telefono.dispose();
    _valor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Form(
    key: _form,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EntradaCampo(
          controller: _telefono,
          etiqueta: 'Número telefónico',
          icono: Icons.phone_android,
          keyboardType: TextInputType.phone,
          hint: '09XXXXXXXX',
          validator: widget.controller.validarTelefono,
        ),
        DropdownButtonFormField<Operadora>(
          key: const Key('operadora'),
          isExpanded: true,
          itemHeight: null,
          isDense: false,
          decoration: const InputDecoration(
            labelText: 'Operadora',
            prefixIcon: Icon(Icons.cell_tower),
          ),
          items: Operadora.values
              .map(
                (op) => DropdownMenuItem(
                  value: op,
                  child: Text('${op.nombre} · comisión ${op.porcentaje}'),
                ),
              )
              .toList(),
          onChanged: (valor) => setState(() => _operadora = valor),
          validator: (valor) =>
              valor == null ? 'Selecciona una operadora.' : null,
        ),
        const SizedBox(height: 18),
        EntradaCampo(
          controller: _valor,
          etiqueta: 'Valor de recarga (USD)',
          icono: Icons.attach_money,
          hint: 'De 1,00 a 100,00',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
          validator: widget.controller.validarValor,
        ),
        DropdownButtonFormField<FormaPago>(
          key: const Key('formaPago'),
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Forma de pago',
            prefixIcon: Icon(Icons.payments_outlined),
          ),
          items: FormaPago.values
              .map(
                (pago) =>
                    DropdownMenuItem(value: pago, child: Text(pago.nombre)),
              )
              .toList(),
          onChanged: (valor) => setState(() => _pago = valor),
          validator: (valor) =>
              valor == null ? 'Selecciona una forma de pago.' : null,
        ),
        const SizedBox(height: 24),
        ResumenMontos(
          cotizacion: widget.controller.cotizar(_valor.text, _operadora),
        ),
        const SizedBox(height: 10),
        const Text(
          'Comisiones de práctica: Claro 3 %, Movistar 2,5 % y CNT 2 %.',
          style: TextStyle(fontSize: 12, color: Color(0xFF53665C)),
        ),
        const SizedBox(height: 24),
        BotonPrincipal(
          texto: 'Confirmar simulación',
          icono: Icons.check,
          onPressed: () {
            FocusScope.of(context).unfocus();
            if (!_form.currentState!.validate()) return;
            widget.controller.confirmar(
              usuario: widget.usuario,
              telefono: _telefono.text,
              valor: _valor.text,
              operadora: _operadora,
              formaPago: _pago,
            );
            widget.onConfirm();
          },
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            _form.currentState!.reset();
            _telefono.clear();
            _valor.clear();
            widget.controller.limpiar();
            setState(() {
              _operadora = null;
              _pago = null;
            });
          },
          child: const Text('Limpiar recarga'),
        ),
      ],
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/producto.dart';
import '../viewmodels/producto_viewmodel.dart';

class FormularioProductoView extends StatefulWidget {
  const FormularioProductoView({super.key});

  @override
  State<FormularioProductoView> createState() =>
      _FormularioProductoViewState();
}

class _FormularioProductoViewState
    extends State<FormularioProductoView> {

  final nombre = TextEditingController();
  final descripcion = TextEditingController();
  final precio = TextEditingController();

  Producto? producto;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    producto =
    ModalRoute.of(context)?.settings.arguments
    as Producto?;

    if (producto != null) {
      nombre.text = producto!.nombre;
      descripcion.text = producto!.descripcion;
      precio.text = producto!.precio.toString();
    }
  }

  void guardar() {
    final vm =
    context.read<ProductoViewModel>();

    final datos = Producto(
      id: producto?.id,
      nombre: nombre.text,
      descripcion: descripcion.text,
      precio: double.parse(precio.text),
    );

    if (producto == null) {
      vm.agregar(datos);
    } else {
      vm.editar(datos);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          producto == null
              ? 'Nuevo producto'
              : 'Editar producto',
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: nombre,
              decoration: const InputDecoration(
                labelText: 'Nombre',
              ),
            ),

            TextField(
              controller: descripcion,
              decoration: const InputDecoration(
                labelText: 'Descripción',
              ),
            ),

            TextField(
              controller: precio,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Precio',
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: guardar,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
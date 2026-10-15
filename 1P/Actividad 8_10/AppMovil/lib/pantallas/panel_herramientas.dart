import 'package:flutter/material.dart';
import '../logica/servicio_calculos.dart';

class PanelHerramientas extends StatefulWidget {
  const PanelHerramientas({super.key});

  @override
  State<PanelHerramientas> createState() => _PanelHerramientasState();
}

class _PanelHerramientasState extends State<PanelHerramientas> {
  final claveFormulario = GlobalKey<FormState>();
  final primerDatoCtrl = TextEditingController();
  final segundoDatoCtrl = TextEditingController();
  final servicio = ServicioCalculos();
  bool modoTerreno = true;
  String? resultado;

  double? convertirEntrada(String texto) =>
      double.tryParse(texto.trim().replaceAll(',', '.'));

  String? validarEntrada(String? texto) {
    final numero = convertirEntrada(texto ?? '');
    if (numero == null || !numero.isFinite) return 'Ingresa un número válido.';
    if (modoTerreno && numero <= 0) return 'La medida debe ser mayor que cero.';
    return null;
  }

  void procesarDatos([String operacion = '+']) {
    if (!claveFormulario.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    try {
      final a = convertirEntrada(primerDatoCtrl.text)!;
      final b = convertirEntrada(segundoDatoCtrl.text)!;
      setState(() {
        if (modoTerreno) {
          final datos = servicio.evaluarTerreno(a, b);
          resultado =
              'Área: ${datos.area.toStringAsFixed(2)} m²\n'
              'Perímetro: ${datos.perimetro.toStringAsFixed(2)} m\n'
              'Valor total: \$${datos.valor.toStringAsFixed(2)}';
        } else {
          resultado =
              'Resultado: '
              '${servicio.resolverOperacion(a, b, operacion).toStringAsFixed(2)}';
        }
      });
    } on ArgumentError catch (error) {
      setState(() => resultado = null);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message.toString())));
    }
  }

  void reiniciarCampos() {
    claveFormulario.currentState?.reset();
    primerDatoCtrl.clear();
    segundoDatoCtrl.clear();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    setState(() => resultado = null);
  }

  @override
  void dispose() {
    primerDatoCtrl.dispose();
    segundoDatoCtrl.dispose();
    super.dispose();
  }

  Widget crearEntrada(TextEditingController controlador, String etiqueta) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: controlador,
          validator: validarEntrada,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          decoration: InputDecoration(labelText: etiqueta),
          onChanged: (_) => setState(() => resultado = null),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(modoTerreno ? 'Área de un terreno' : 'Calculadora básica'),
      centerTitle: true,
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: claveFormulario,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    modoTerreno ? Icons.crop_square : Icons.calculate_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    modoTerreno ? 'Medidas del terreno' : 'Operaciones básicas',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    modoTerreno
                        ? 'Terreno rectangular · Precio: \$500 por m²'
                        : 'Ingresa dos números y elige una operación.',
                  ),
                  const SizedBox(height: 24),
                  crearEntrada(
                    primerDatoCtrl,
                    modoTerreno ? 'Base (m)' : 'Número 1',
                  ),
                  crearEntrada(
                    segundoDatoCtrl,
                    modoTerreno ? 'Altura (m)' : 'Número 2',
                  ),
                  if (modoTerreno)
                    FilledButton.icon(
                      onPressed: procesarDatos,
                      icon: const Icon(Icons.calculate_outlined),
                      label: const Text('Calcular'),
                    )
                  else
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        for (final operacion in ['+', '−', '×', '÷'])
                          FilledButton(
                            onPressed: () => procesarDatos(operacion),
                            child: Text(operacion),
                          ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          resultado ?? 'Los resultados aparecerán aquí.',
                          style: const TextStyle(
                            fontSize: 18,
                            height: 1.7,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: reiniciarCampos,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Limpiar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: modoTerreno ? 0 : 1,
      onDestinationSelected: (indice) {
        reiniciarCampos();
        setState(() => modoTerreno = indice == 0);
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.crop_square), label: 'Terreno'),
        NavigationDestination(
          icon: Icon(Icons.calculate_outlined),
          label: 'Calculadora',
        ),
      ],
    ),
  );
}

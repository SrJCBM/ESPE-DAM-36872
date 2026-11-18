import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/datasources/item_api.dart';
import 'data/repositories/item_repository_impl.dart';

import 'domain/usecases/obtener_items.dart';

import 'presentation/viewmodels/item_viewmodel.dart';
import 'presentation/views/inicio_view.dart';
import 'presentation/views/lista_view.dart';
import 'presentation/views/detalle_view.dart';

import 'routes/app_routes.dart';

void main() {

  //creando la fuente de datos que consume la api
  final api = ItemApi();

  //el repositorio recibe la api
  final repository =
  ItemRepositoryImpl(api);

  //es el casp de isp de repository
  final useCase =
  ObtenerItems(repository);

  runApp(
    ChangeNotifierProvider(
      create: (_) =>
          ItemViewModel(useCase),

      child: const MiApp(),
    ),
  );
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      initialRoute:
      AppRoutes.inicio,

      routes: {
        AppRoutes.inicio:
            (_) => const InicioView(),

        AppRoutes.lista:
            (_) => const ListaView(),

        AppRoutes.detalle:
            (_) => const DetalleView(),
      },
    );
  }
}
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/entidades.dart';

const urlAcademica = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://control-academico-api.onrender.com/api/v1',
);

typedef Json = Map<String, dynamic>;

class AcademicoApi {
  AcademicoApi(this._client, {String baseUrl = urlAcademica})
    : _base = baseUrl.replaceFirst(RegExp(r'/+$'), '');

  final http.Client _client;
  final String _base;

  Future<Json> objeto(String metodo, String ruta, {Json? datos}) async {
    final respuesta = await _solicitar(metodo, ruta, datos: datos);
    return _objeto(respuesta);
  }

  Future<void> eliminar(String ruta) async {
    await _solicitar('DELETE', ruta);
  }

  Future<List<T>> listar<T>(String ruta, T Function(Json) leer) async {
    final registros = <T>[];
    var offset = 0;
    while (true) {
      final pagina = await objeto('GET', '$ruta?limit=100&offset=$offset');
      final items = pagina['items'];
      final total = pagina['total'];
      if (items is! List || total is! int) throw _respuestaInvalida;
      for (final item in items) {
        if (item is! Json) throw _respuestaInvalida;
        registros.add(leer(item));
      }
      offset += items.length;
      if (items.isEmpty || offset >= total) return registros;
    }
  }

  Future<http.Response> _solicitar(
    String metodo,
    String ruta, {
    Json? datos,
  }) async {
    final peticion = http.Request(metodo, Uri.parse('$_base$ruta'));
    peticion.headers['Accept'] = 'application/json';
    if (datos != null) {
      peticion.headers['Content-Type'] = 'application/json; charset=utf-8';
      peticion.body = jsonEncode(datos);
    }

    final http.Response respuesta;
    try {
      respuesta = await _client
          .send(peticion)
          .then(http.Response.fromStream)
          .timeout(const Duration(seconds: 85));
    } on TimeoutException {
      throw const ErrorAcademico(
        'La API tardó en responder. Intenta de nuevo.',
      );
    } on http.ClientException {
      throw const ErrorAcademico(
        'No pudimos conectar con la API. Revisa tu conexión.',
      );
    }

    if (respuesta.statusCode >= 200 && respuesta.statusCode < 300) {
      return respuesta;
    }

    try {
      final detalle = _objeto(respuesta)['detail'];
      if (detalle is Json && detalle['mensaje'] is String) {
        final errores = detalle['errores'];
        final primero = errores is List && errores.isNotEmpty
            ? errores.first
            : null;
        throw ErrorAcademico(
          primero is Json && primero['mensaje'] is String
              ? primero['mensaje'] as String
              : detalle['mensaje'] as String,
          codigo: detalle['codigo'] as String?,
        );
      }
    } on FormatException {
      // Render puede responder HTML durante un reinicio.
    }

    final status = respuesta.statusCode;
    throw ErrorAcademico(
      status == 403
          ? 'El servidor rechazó la conexión. Intenta de nuevo en unos momentos.'
          : 'La API no pudo completar la solicitud ($status). Intenta de nuevo.',
    );
  }

  Json _objeto(http.Response respuesta) {
    try {
      final json = jsonDecode(utf8.decode(respuesta.bodyBytes));
      if (json is Json) return json;
    } on FormatException {
      if (respuesta.statusCode >= 400) rethrow;
    }
    throw _respuestaInvalida;
  }
}

const _respuestaInvalida = ErrorAcademico(
  'La API devolvió datos en un formato inesperado.',
);

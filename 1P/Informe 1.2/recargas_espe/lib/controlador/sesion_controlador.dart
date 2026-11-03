class SesionControlador {
  String? _usuario;
  String? get usuario => _usuario;
  bool get autenticado => _usuario != null;

  String? validarUsuario(String? valor) =>
      valor == null || valor.trim().isEmpty ? 'Ingresa tu usuario.' : null;

  String? validarClave(String? valor) =>
      valor == null || valor.isEmpty ? 'Ingresa tu contraseña.' : null;

  bool iniciarSesion(String usuario, String clave) {
    _usuario = null;
    if (usuario.trim() == 'admin' && clave == 'Admin123*') {
      _usuario = 'admin';
      return true;
    }
    return false;
  }

  void cerrarSesion() => _usuario = null;
}

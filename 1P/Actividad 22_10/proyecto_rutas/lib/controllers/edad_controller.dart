import '../models/usuario_model.dart';

class EdadController {
  String calcularEdad(String d, String m, String a, {String nombre = ''}) {
    final actual = DateTime.now();
    final hoy = DateTime.utc(actual.year, actual.month, actual.day);
    final dia = int.tryParse(d.trim()) ?? 0;
    final mes = int.tryParse(m.trim()) ?? 0;
    final anio = int.tryParse(a.trim()) ?? 0;
    if (anio < 1 || anio > hoy.year || mes < 1 || mes > 12) {
      return 'Ingresa una fecha válida';
    }
    final u = UsuarioModel(nombre.trim(), DateTime.utc(anio, mes, dia));
    if (u.nacimiento.day != dia || u.nacimiento.isAfter(hoy)) {
      return 'Ingresa una fecha válida';
    }
    DateTime referencia(int n) {
      final f = DateTime.utc(anio, mes + n);
      final fin = DateTime.utc(f.year, f.month + 1, 0).day;
      return DateTime.utc(f.year, f.month, dia > fin ? fin : dia);
    }

    var meses = (hoy.year - anio) * 12 + hoy.month - mes;
    if (referencia(meses).isAfter(hoy)) {
      meses--;
    }
    final dias = hoy.difference(referencia(meses)).inDays;
    final persona = u.nombre.isEmpty ? 'La edad es:' : '${u.nombre} tiene';
    return '$persona ${meses ~/ 12} años, ${meses % 12} meses y $dias días';
  }
}

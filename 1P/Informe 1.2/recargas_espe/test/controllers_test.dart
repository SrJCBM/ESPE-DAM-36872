import 'package:flutter_test/flutter_test.dart';
import 'package:recargas_espe/controlador/sesion_controlador.dart';
import 'package:recargas_espe/controlador/recarga_controlador.dart';
import 'package:recargas_espe/modelo/recarga.dart';

void main() {
  group('Acceso local', () {
    test('usuario y contraseña vacíos generan errores', () {
      final auth = SesionControlador();
      expect(auth.validarUsuario('  '), isNotNull);
      expect(auth.validarClave(''), isNotNull);
      expect(auth.validarUsuario('admin'), isNull);
    });
    test('credenciales correctas abren sesión', () {
      final auth = SesionControlador();
      expect(auth.iniciarSesion(' admin ', 'Admin123*'), isTrue);
      expect(auth.usuario, 'admin');
    });
    test('credenciales incorrectas no abren sesión', () {
      final auth = SesionControlador();
      expect(auth.iniciarSesion('admin', 'incorrecta'), isFalse);
      expect(auth.autenticado, isFalse);
    });
    test('contraseña distingue mayúsculas y espacios', () {
      final auth = SesionControlador();
      expect(auth.iniciarSesion('admin', 'admin123*'), isFalse);
      expect(auth.iniciarSesion('admin', 'Admin123* '), isFalse);
    });
    test('cerrar sesión elimina usuario', () {
      final auth = SesionControlador()..iniciarSesion('admin', 'Admin123*');
      auth.cerrarSesion();
      expect(auth.usuario, isNull);
    });
  });
  group('Formato y límites', () {
    final controller = RecargaControlador();
    test('acepta teléfono móvil de diez dígitos', () {
      expect(controller.validarTelefono('0991234567'), isNull);
    });
    for (final telefono in [
      '',
      '099123456',
      '09912345678',
      '0291234567',
      '09abcdefgh',
    ]) {
      test('rechaza teléfono inválido $telefono', () {
        expect(controller.validarTelefono(telefono), isNotNull);
      });
    }
    test('coma y punto representan los mismos centavos', () {
      expect(Dinero.parsear('10,50'), 1050);
      expect(Dinero.parsear('10.50'), 1050);
      expect(Dinero.parsear('1.5'), 150);
      expect(Dinero.formato(1050), '\$10,50');
    });
    for (final valor in ['', 'abc', '-5', '1.001', 'NaN', '1,2.3', '1e2']) {
      test('rechaza formato monetario $valor', () {
        expect(controller.validarValor(valor), isNotNull);
      });
    }
    test('incluye los límites 1 y 100', () {
      expect(controller.validarValor('1'), isNull);
      expect(controller.validarValor('100'), isNull);
    });
    test('rechaza valores menores y mayores a los límites', () {
      expect(controller.validarValor('0.99'), isNotNull);
      expect(controller.validarValor('100.01'), isNotNull);
      expect(controller.validarValor('0'), isNotNull);
    });
  });
  group('Comisión y comprobante', () {
    for (final (operadora, comision) in [
      (Operadora.claro, 30),
      (Operadora.movistar, 25),
      (Operadora.cnt, 20),
    ]) {
      test('recarga de 10 con ${operadora.nombre}', () {
        final valor = RecargaControlador().cotizar('10', operadora)!;
        expect(valor.comisionCentavos, comision);
        expect(valor.totalCentavos, 1000 + comision);
      });
    }
    test('medio centavo se redondea hacia arriba', () {
      final valor = RecargaControlador().cotizar('1', Operadora.movistar)!;
      expect(valor.comisionCentavos, 3);
      expect(valor.totalCentavos, 103);
    });
    test('no cotiza sin operadora ni con monto inválido', () {
      expect(RecargaControlador().cotizar('10', null), isNull);
      expect(RecargaControlador().cotizar('-5', Operadora.claro), isNull);
    });
    test('confirmación conserva todos los detalles', () {
      final fecha = DateTime(2026, 11, 2, 10, 30);
      final controller = RecargaControlador(reloj: () => fecha);
      final recibo = controller.confirmar(
        usuario: 'admin',
        telefono: '0991234567',
        valor: '10',
        operadora: Operadora.claro,
        formaPago: FormaPago.efectivo,
      );
      expect(recibo.fecha, fecha);
      expect(recibo.telefono, '0991234567');
      expect(recibo.formaPago, FormaPago.efectivo);
      expect(recibo.cotizacion.totalCentavos, 1030);
      expect(controller.ultimo, same(recibo));
    });
    test('no confirma datos inválidos o selecciones vacías', () {
      final controller = RecargaControlador();
      for (final (usuario, telefono, valor, operadora, pago) in [
        ('', '0991234567', '10', Operadora.claro, FormaPago.efectivo),
        ('admin', '099', '10', Operadora.claro, FormaPago.efectivo),
        ('admin', '0991234567', '-1', Operadora.claro, FormaPago.efectivo),
        ('admin', '0991234567', '10', null, FormaPago.efectivo),
        ('admin', '0991234567', '10', Operadora.claro, null),
      ]) {
        expect(
          () => controller.confirmar(
            usuario: usuario,
            telefono: telefono,
            valor: valor,
            operadora: operadora,
            formaPago: pago,
          ),
          throwsArgumentError,
        );
      }
      expect(controller.ultimo, isNull);
    });
    test(
      'dos operaciones simultáneas de reloj conservan códigos distintos',
      () {
        final controller = RecargaControlador(
          reloj: () => DateTime(2026, 11, 2),
        );
        Comprobante confirmar() => controller.confirmar(
          usuario: 'admin',
          telefono: '0991234567',
          valor: '10',
          operadora: Operadora.cnt,
          formaPago: FormaPago.transferencia,
        );
        expect(confirmar().codigo, isNot(confirmar().codigo));
      },
    );
    test('limpiar elimina el comprobante anterior', () {
      final controller = RecargaControlador();
      controller.confirmar(
        usuario: 'admin',
        telefono: '0991234567',
        valor: '10',
        operadora: Operadora.claro,
        formaPago: FormaPago.efectivo,
      );
      controller.limpiar();
      expect(controller.ultimo, isNull);
    });
  });
}

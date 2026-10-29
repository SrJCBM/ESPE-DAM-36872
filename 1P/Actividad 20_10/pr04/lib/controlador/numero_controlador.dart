import '../modelo/numeros_modelos.dart';
class NumeroControlador{
  NumeroModelo calcular (int a, int b, int c){
    NumeroModelo datos = NumeroModelo(a, b, c);
  // contar cuantos valores difrentes hay
  datos.diferentes = {a, b, c}.length;
  datos.suma = a + b + c;
  datos.promedio = datos.suma / 3;
  //enctrar el numero mayor
  int mayor = a;
  int menor = a;
  if(b > mayor){
    mayor = b;
  }
  if(c > mayor){
    mayor = c;
  }
  if(b< menor){
    menor = b;
  }
  if(c < menor){
    menor = c;
  }
  datos.producto = mayor * menor;
  //verificar si es divisble para 3
  if(datos.diferentes % 3 == 0){
    int restante = datos.suma -mayor - menor;
    if(restante % 3 == 0){
      datos.divisible = 'El numero restante es divisible para 3';
    }else{
      datos.divisible = 'El numero restante no es divisible para 3';
    }
  }else{
    datos.divisible = 'NO hay numeros restantes para verificar si es divisible para 3';
  }
  return datos;
}
}

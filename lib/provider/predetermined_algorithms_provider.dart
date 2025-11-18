import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/predetermined_algorithm.dart';

final predeterminedAlgorithmsProvider = Provider<List<PredeterminedAlgorithm>>(
  (ref) => const [
    // ============================================================
    // NIVEL 1 - BÁSICO (10 ejercicios)
    // ============================================================
    PredeterminedAlgorithm(
      titulo: 'Suma de dos números',
      nivel: 1,
      codigo: '''INICIO
  VARIABLE num1 = 0
  VARIABLE num2 = 0
  VARIABLE suma = 0

  ESCRIBIR "Ingresa el primer número:"
  LEER num1
  ESCRIBIR "Ingresa el segundo número:"
  LEER num2

  suma = num1 + num2
  ESCRIBIR "La suma es:", suma
FIN''',
    ),
    PredeterminedAlgorithm(
      titulo: 'Número mayor',
      nivel: 1,
      codigo: '''INICIO
  VARIABLE a = 0
  VARIABLE b = 0

  ESCRIBIR "Ingresa el primer número:"
  LEER a
  ESCRIBIR "Ingresa el segundo número:"
  LEER b

  Si a > b Entonces
    ESCRIBIR "El mayor es:", a
  Sino
    ESCRIBIR "El mayor es:", b
  FinSi
FIN''',
    ),
    PredeterminedAlgorithm(
      titulo: 'Par o impar',
      nivel: 1,
      codigo: '''INICIO
  VARIABLE numero = 0
  VARIABLE residuo = 0

  ESCRIBIR "Ingresa un número:"
  LEER numero

  residuo = numero - (numero / 2) * 2

  Si residuo == 0 Entonces
    ESCRIBIR numero, " es par"
  Sino
    ESCRIBIR numero, " es impar"
  FinSi
FIN''',
    ),
    PredeterminedAlgorithm(
      titulo: 'Área de un círculo',
      nivel: 1,
      codigo: '''INICIO
  VARIABLE radio = 0
  VARIABLE area = 0

  ESCRIBIR "Ingresa el radio del círculo:"
  LEER radio

  area = 3 * radio * radio
  ESCRIBIR "El área es:", area
FIN''',
    ),
    PredeterminedAlgorithm(
      titulo: 'Conversión de temperatura',
      nivel: 1,
      codigo: '''INICIO
  VARIABLE celsius = 0
  VARIABLE fahrenheit = 0

  ESCRIBIR "Ingresa temperatura en Celsius:"
  LEER celsius

  fahrenheit = (celsius * 9) / 5 + 32
  ESCRIBIR celsius, "°C =", fahrenheit, "°F"
FIN''',
    ),
    PredeterminedAlgorithm(
      titulo: 'Calculadora simple',
      nivel: 1,
      codigo: '''INICIO
  VARIABLE a = 0
  VARIABLE b = 0

  ESCRIBIR "Ingresa el primer número:"
  LEER a
  ESCRIBIR "Ingresa el segundo número:"
  LEER b

  ESCRIBIR "Suma:", a + b
  ESCRIBIR "Resta:", a - b
  ESCRIBIR "Multiplicación:", a * b
  ESCRIBIR "División:", a / b
FIN''',
    ),
    PredeterminedAlgorithm(
      titulo: 'Descuento en compra',
      nivel: 1,
      codigo: '''INICIO
  VARIABLE precio = 0
  VARIABLE descuento = 0
  VARIABLE total = 0

  ESCRIBIR "Ingresa el precio:"
  LEER precio

  descuento = precio * 10 / 100
  total = precio - descuento

  ESCRIBIR "Descuento:", descuento
  ESCRIBIR "Total a pagar:", total
FIN''',
    ),
    PredeterminedAlgorithm(
      titulo: 'Promedio de tres números',
      nivel: 1,
      codigo: '''INICIO
  VARIABLE n1 = 0
  VARIABLE n2 = 0
  VARIABLE n3 = 0
  VARIABLE promedio = 0

  ESCRIBIR "Ingresa el primer número:"
  LEER n1
  ESCRIBIR "Ingresa el segundo número:"
  LEER n2
  ESCRIBIR "Ingresa el tercer número:"
  LEER n3

  promedio = (n1 + n2 + n3) / 3
  ESCRIBIR "El promedio es:", promedio
FIN''',
    ),
    PredeterminedAlgorithm(
      titulo: 'Edad en días',
      nivel: 1,
      codigo: '''INICIO
  VARIABLE años = 0
  VARIABLE dias = 0

  ESCRIBIR "Ingresa tu edad en años:"
  LEER años

  dias = años * 365
  ESCRIBIR "Tu edad en días es:", dias
FIN''',
    ),
    PredeterminedAlgorithm(
      titulo: 'Calificación aprobatoria',
      nivel: 1,
      codigo: '''INICIO
  VARIABLE calificacion = 0

  ESCRIBIR "Ingresa tu calificación:"
  LEER calificacion

  Si calificacion >= 60 Entonces
    ESCRIBIR "¡Aprobado!"
  Sino
    ESCRIBIR "Reprobado"
  FinSi
FIN''',
    ),

    // ============================================================
    // NIVEL 2 - INTERMEDIO (10 ejercicios)
    // ============================================================
    PredeterminedAlgorithm(
      titulo: 'Tabla de multiplicar',
      nivel: 2,
      codigo: '''INICIO
  VARIABLE numero = 0
  VARIABLE contador = 1

  ESCRIBIR "¿De qué número deseas la tabla?"
  LEER numero

  Repite
    ESCRIBIR numero, " x ", contador, " = ", numero * contador
    contador = contador + 1
  FinRepite
FIN''',
    ),
    PredeterminedAlgorithm(
      titulo: 'Factorial',
      nivel: 2,
      codigo: '''INICIO
  VARIABLE n = 0
  VARIABLE resultado = 1
  VARIABLE temp = 0

  ESCRIBIR "Ingresa un número:"
  LEER n
  temp = n

  Repite
    Si temp <= 0 Entonces
      FinRepite
    FinSi

    resultado = resultado * temp
    temp = temp - 1
  FinRepite

  ESCRIBIR "Factorial de", n, "es:", resultado
FIN''',
    ),
    PredeterminedAlgorithm(
      titulo: 'Números pares hasta N',
      nivel: 2,
      codigo: '''INICIO
  VARIABLE limite = 0
  VARIABLE contador = 2

  ESCRIBIR "Ingresa el límite:"
  LEER limite

  ESCRIBIR "Números pares:"
  Repite
    Si contador > limite Entonces
      FinRepite
    FinSi

    ESCRIBIR contador
    contador = contador + 2
  FinRepite
FIN''',
    ),
    PredeterminedAlgorithm(
      titulo: 'Promedio de calificaciones',
      nivel: 2,
      codigo: '''INICIO
  VARIABLE total = 0
  VARIABLE contador = 0
  VARIABLE calificacion = 0

  Repite
    ESCRIBIR "Ingresa calificación (0 para terminar):"
    LEER calificacion

    Si calificacion == 0 Entonces
      FinRepite
    FinSi

    total = total + calificacion
    contador = contador + 1
  FinRepite

  Si contador > 0 Entonces
    ESCRIBIR "Promedio:", total / contador
  Sino
    ESCRIBIR "No se ingresaron calificaciones"
  FinSi
FIN''',
    ),
    PredeterminedAlgorithm(
      titulo: 'Suma de números del 1 al N',
      nivel: 2,
      codigo: '''INICIO
  VARIABLE n = 0
  VARIABLE suma = 0
  VARIABLE i = 1

  ESCRIBIR "Ingresa N:"
  LEER n

  Repite
    Si i > n Entonces
      FinRepite
    FinSi

    suma = suma + i
    i = i + 1
  FinRepite

  ESCRIBIR "La suma es:", suma
FIN''',
    ),
    PredeterminedAlgorithm(
      titulo: 'Número mayor de tres',
      nivel: 2,
      codigo: '''INICIO
  VARIABLE a = 0
  VARIABLE b = 0
  VARIABLE c = 0
  VARIABLE mayor = 0

  ESCRIBIR "Ingresa el primer número:"
  LEER a
  ESCRIBIR "Ingresa el segundo número:"
  LEER b
  ESCRIBIR "Ingresa el tercer número:"
  LEER c

  mayor = a

  Si b > mayor Entonces
    mayor = b
  FinSi

  Si c > mayor Entonces
    mayor = c
  FinSi

  ESCRIBIR "El mayor es:", mayor
FIN''',
    ),
    PredeterminedAlgorithm(
      titulo: 'Contador de dígitos',
      nivel: 2,
      codigo: '''INICIO
  VARIABLE numero = 0
  VARIABLE contador = 0
  VARIABLE temp = 0

  ESCRIBIR "Ingresa un número:"
  LEER numero
  temp = numero

  Si temp == 0 Entonces
    contador = 1
  Sino
    Repite
      Si temp <= 0 Entonces
        FinRepite
      FinSi

      temp = temp / 10
      contador = contador + 1
    FinRepite
  FinSi

  ESCRIBIR "El número tiene", contador, "dígitos"
FIN''',
    ),
    PredeterminedAlgorithm(
      titulo: 'Potencia de un número',
      nivel: 2,
      codigo: '''INICIO
  VARIABLE base = 0
  VARIABLE exponente = 0
  VARIABLE resultado = 1
  VARIABLE i = 0

  ESCRIBIR "Ingresa la base:"
  LEER base
  ESCRIBIR "Ingresa el exponente:"
  LEER exponente

  Repite
    Si i >= exponente Entonces
      FinRepite
    FinSi

    resultado = resultado * base
    i = i + 1
  FinRepite

  ESCRIBIR base, "^", exponente, "=", resultado
FIN''',
    ),
    PredeterminedAlgorithm(
      titulo: 'Números primos hasta N',
      nivel: 2,
      codigo: '''INICIO
  VARIABLE n = 0
  VARIABLE num = 2
  VARIABLE divisor = 2
  VARIABLE esPrimo = 1

  ESCRIBIR "Ingresa el límite:"
  LEER n

  ESCRIBIR "Números primos:"

  Repite
    Si num > n Entonces
      FinRepite
    FinSi

    esPrimo = 1
    divisor = 2

    Repite
      Si divisor >= num Entonces
        FinRepite
      FinSi

      Si num - (num / divisor) * divisor == 0 Entonces
        esPrimo = 0
        FinRepite
      FinSi

      divisor = divisor + 1
    FinRepite

    Si esPrimo == 1 Entonces
      ESCRIBIR num
    FinSi

    num = num + 1
  FinRepite
FIN''',
    ),
    PredeterminedAlgorithm(
      titulo: 'Invertir un número',
      nivel: 2,
      codigo: '''INICIO
  VARIABLE numero = 0
  VARIABLE invertido = 0
  VARIABLE digito = 0

  ESCRIBIR "Ingresa un número:"
  LEER numero

  Repite
    Si numero <= 0 Entonces
      FinRepite
    FinSi

    digito = numero - (numero / 10) * 10
    invertido = invertido * 10 + digito
    numero = numero / 10
  FinRepite

  ESCRIBIR "Número invertido:", invertido
FIN''',
    ),

    // ============================================================
    // NIVEL 3 - AVANZADO CON FUNCIONES (10 ejercicios)
    // ============================================================
    PredeterminedAlgorithm(
      titulo: 'Calculadora con funciones',
      nivel: 3,
      codigo: '''INICIO
  VARIABLE a = 0
  VARIABLE b = 0
  VARIABLE resultado = 0

  Funcion sumar
    resultado = a + b
  FinFuncion

  Funcion restar
    resultado = a - b
  FinFuncion

  ESCRIBIR "Ingresa el primer número:"
  LEER a
  ESCRIBIR "Ingresa el segundo número:"
  LEER b

  Llamar sumar
  ESCRIBIR "Suma:", resultado

  Llamar restar
  ESCRIBIR "Resta:", resultado
FIN''',
    ),
    PredeterminedAlgorithm(
      titulo: 'Área de figuras',
      nivel: 3,
      codigo: '''INICIO
  VARIABLE base = 0
  VARIABLE altura = 0
  VARIABLE radio = 0
  VARIABLE area = 0

  Funcion areaTriangulo
    area = (base * altura) / 2
  FinFuncion

  Funcion areaCirculo
    area = 3 * radio * radio
  FinFuncion

  ESCRIBIR "Base del triángulo:"
  LEER base
  ESCRIBIR "Altura del triángulo:"
  LEER altura

  Llamar areaTriangulo
  ESCRIBIR "Área del triángulo:", area

  ESCRIBIR "Radio del círculo:"
  LEER radio

  Llamar areaCirculo
  ESCRIBIR "Área del círculo:", area
FIN''',
    ),
    PredeterminedAlgorithm(
      titulo: 'Número par con función',
      nivel: 3,
      codigo: '''INICIO
  VARIABLE numero = 0
  VARIABLE esPar = 0
  VARIABLE residuo = 0

  Funcion verificarPar
    residuo = numero - (numero / 2) * 2
    Si residuo == 0 Entonces
      esPar = 1
    Sino
      esPar = 0
    FinSi
  FinFuncion

  ESCRIBIR "Ingresa un número:"
  LEER numero

  Llamar verificarPar

  Si esPar == 1 Entonces
    ESCRIBIR numero, "es par"
  Sino
    ESCRIBIR numero, "es impar"
  FinSi
FIN''',
    ),
    PredeterminedAlgorithm(
      titulo: 'Factorial con función',
      nivel: 3,
      codigo: '''INICIO
  VARIABLE n = 0
  VARIABLE resultado = 1
  VARIABLE temp = 0

  Funcion calcularFactorial
    resultado = 1
    temp = n

    Repite
      Si temp <= 0 Entonces
        FinRepite
      FinSi

      resultado = resultado * temp
      temp = temp - 1
    FinRepite
  FinFuncion

  ESCRIBIR "Ingresa un número:"
  LEER n

  Llamar calcularFactorial

  ESCRIBIR "Factorial de", n, "=", resultado
FIN''',
    ),
    PredeterminedAlgorithm(
      titulo: 'Número mayor con función',
      nivel: 3,
      codigo: '''INICIO
  VARIABLE a = 0
  VARIABLE b = 0
  VARIABLE c = 0
  VARIABLE mayor = 0

  Funcion encontrarMayor
    mayor = a

    Si b > mayor Entonces
      mayor = b
    FinSi

    Si c > mayor Entonces
      mayor = c
    FinSi
  FinFuncion

  ESCRIBIR "Primer número:"
  LEER a
  ESCRIBIR "Segundo número:"
  LEER b
  ESCRIBIR "Tercer número:"
  LEER c

  Llamar encontrarMayor

  ESCRIBIR "El mayor es:", mayor
FIN''',
    ),
    PredeterminedAlgorithm(
      titulo: 'Conversión de unidades',
      nivel: 3,
      codigo: '''INICIO
  VARIABLE metros = 0
  VARIABLE centimetros = 0
  VARIABLE pulgadas = 0

  Funcion metrosACentimetros
    centimetros = metros * 100
  FinFuncion

  Funcion metrosAPulgadas
    pulgadas = metros * 39
  FinFuncion

  ESCRIBIR "Ingresa metros:"
  LEER metros

  Llamar metrosACentimetros
  ESCRIBIR metros, "m =", centimetros, "cm"

  Llamar metrosAPulgadas
  ESCRIBIR metros, "m =", pulgadas, "in"
FIN''',
    ),
    PredeterminedAlgorithm(
      titulo: 'Potencia con función',
      nivel: 3,
      codigo: '''INICIO
  VARIABLE base = 0
  VARIABLE exponente = 0
  VARIABLE resultado = 1
  VARIABLE i = 0

  Funcion calcularPotencia
    resultado = 1
    i = 0

    Repite
      Si i >= exponente Entonces
        FinRepite
      FinSi

      resultado = resultado * base
      i = i + 1
    FinRepite
  FinFuncion

  ESCRIBIR "Ingresa la base:"
  LEER base
  ESCRIBIR "Ingresa el exponente:"
  LEER exponente

  Llamar calcularPotencia

  ESCRIBIR base, "^", exponente, "=", resultado
FIN''',
    ),
    PredeterminedAlgorithm(
      titulo: 'Promedio con función',
      nivel: 3,
      codigo: '''INICIO
  VARIABLE n1 = 0
  VARIABLE n2 = 0
  VARIABLE n3 = 0
  VARIABLE promedio = 0
  VARIABLE suma = 0

  Funcion calcularSuma
    suma = n1 + n2 + n3
  FinFuncion

  Funcion calcularPromedio
    Llamar calcularSuma
    promedio = suma / 3
  FinFuncion

  ESCRIBIR "Primer número:"
  LEER n1
  ESCRIBIR "Segundo número:"
  LEER n2
  ESCRIBIR "Tercer número:"
  LEER n3

  Llamar calcularPromedio

  ESCRIBIR "Suma:", suma
  ESCRIBIR "Promedio:", promedio
FIN''',
    ),
    PredeterminedAlgorithm(
      titulo: 'Temperaturas con funciones',
      nivel: 3,
      codigo: '''INICIO
  VARIABLE celsius = 0
  VARIABLE fahrenheit = 0
  VARIABLE kelvin = 0

  Funcion celsiusAFahrenheit
    fahrenheit = (celsius * 9) / 5 + 32
  FinFuncion

  Funcion celsiusAKelvin
    kelvin = celsius + 273
  FinFuncion

  ESCRIBIR "Temperatura en Celsius:"
  LEER celsius

  Llamar celsiusAFahrenheit
  ESCRIBIR celsius, "°C =", fahrenheit, "°F"

  Llamar celsiusAKelvin
  ESCRIBIR celsius, "°C =", kelvin, "K"
FIN''',
    ),
    PredeterminedAlgorithm(
      titulo: 'Sistema de calificaciones',
      nivel: 3,
      codigo: '''INICIO
  VARIABLE cal1 = 0
  VARIABLE cal2 = 0
  VARIABLE cal3 = 0
  VARIABLE promedio = 0
  VARIABLE estado = 0

  Funcion calcularPromedio
    promedio = (cal1 + cal2 + cal3) / 3
  FinFuncion

  Funcion evaluarEstado
    Si promedio >= 90 Entonces
      estado = 4
    Sino
      Si promedio >= 70 Entonces
        estado = 3
      Sino
        Si promedio >= 60 Entonces
          estado = 2
        Sino
          estado = 1
        FinSi
      FinSi
    FinSi
  FinFuncion

  ESCRIBIR "Calificación 1:"
  LEER cal1
  ESCRIBIR "Calificación 2:"
  LEER cal2
  ESCRIBIR "Calificación 3:"
  LEER cal3

  Llamar calcularPromedio
  ESCRIBIR "Promedio:", promedio

  Llamar evaluarEstado

  Si estado == 4 Entonces
    ESCRIBIR "Excelente"
  Sino
    Si estado == 3 Entonces
      ESCRIBIR "Bueno"
    Sino
      Si estado == 2 Entonces
        ESCRIBIR "Aprobado"
      Sino
        ESCRIBIR "Reprobado"
      FinSi
    FinSi
  FinSi
FIN''',
    ),
  ],
);

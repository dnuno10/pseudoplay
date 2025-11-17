import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/predetermined_algorithm.dart';

final predeterminedAlgorithmsProvider = Provider<List<PredeterminedAlgorithm>>(
  (ref) => const [
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
      titulo: 'Tabla de multiplicar',
      nivel: 1,
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

  ESCRIBIR "Ingresa un número"
  LEER n

  Repite
    resultado = resultado * n
    n = n - 1
  FinRepite

  ESCRIBIR "Factorial:", resultado
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
    ESCRIBIR "Ingresa una calificación (0 para terminar):"
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
    ESCRIBIR "No se capturaron calificaciones"
  FinSi
FIN''',
    ),
    PredeterminedAlgorithm(
      titulo: 'Número mayor',
      nivel: 1,
      codigo: '''INICIO
  VARIABLE a = 0
  VARIABLE b = 0

  ESCRIBIR "Ingresa el primer número"
  LEER a
  ESCRIBIR "Ingresa el segundo número"
  LEER b

  Si a > b Entonces
    ESCRIBIR "El mayor es:", a
  Sino
    ESCRIBIR "El mayor es:", b
  FinSi
FIN''',
    ),
  ],
);

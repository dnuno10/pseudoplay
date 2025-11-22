class PseudocodeFlashcard {
  final String title;
  final String description;
  final String codeExample;

  const PseudocodeFlashcard({
    required this.title,
    required this.description,
    required this.codeExample,
  });
}

const List<PseudocodeFlashcard> pseudocodeFlashcards = [
  PseudocodeFlashcard(
    title: 'Declarar una variable',
    description: 'Usa VARIABLE para crear memoria y darle un valor inicial.',
    codeExample: 'INICIO\n  VARIABLE edad = 0\nFIN',
  ),
  PseudocodeFlashcard(
    title: 'Leer un dato',
    description:
        'LEER obtiene información del usuario y la guarda en una variable.',
    codeExample: 'INICIO\n  LEER edad\nFIN',
  ),
  PseudocodeFlashcard(
    title: 'Escribir en pantalla',
    description: 'ESCRIBIR muestra mensajes o valores en la consola retro.',
    codeExample:
        'INICIO\n  ESCRIBIR "Hola, mundo"\n  ESCRIBIR "Edad:", edad\nFIN',
  ),
  PseudocodeFlashcard(
    title: 'Asignar valores',
    description:
        'Puedes actualizar variables utilizando operadores aritméticos.',
    codeExample:
        'INICIO\n  VARIABLE contador = 0\n  contador = contador + 1\nFIN',
  ),
  PseudocodeFlashcard(
    title: 'Condición simple',
    description:
        'Evalúa una expresión y ejecuta el bloque solo si es verdadera.',
    codeExample:
        'INICIO\n  SI edad >= 18 ENTONCES\n    ESCRIBIR "Eres mayor de edad"\n  FinSi\nFIN',
  ),
  PseudocodeFlashcard(
    title: 'Condición con SINO',
    description: 'Agrega un bloque alterno cuando la condición no se cumple.',
    codeExample:
        'INICIO\n  SI edad >= 18 ENTONCES\n    ESCRIBIR "Bienvenido"\n  Sino\n    ESCRIBIR "Debes esperar"\n  FinSi\nFIN',
  ),
  PseudocodeFlashcard(
    title: 'Repetir un número de veces',
    description:
        'Controla cuántas repeticiones haces usando un contador con MIENTRAS.',
    codeExample:
        'INICIO\n  VARIABLE conteo = 3\n  MIENTRAS conteo > 0 HACER\n    ESCRIBIR "Cuenta regresiva", conteo\n    conteo = conteo - 1\n  FinMientras\nFIN',
  ),
  PseudocodeFlashcard(
    title: 'Mientras una condición se cumpla',
    description:
        'MIENTRAS mantiene el ciclo mientras la expresión sea verdadera.',
    codeExample:
        'INICIO\n  MIENTRAS intento < 3 HACER\n    ESCRIBIR "Intento", intento\n    intento = intento + 1\n  FinMientras\nFIN',
  ),
  PseudocodeFlashcard(
    title: 'Crear una función',
    description:
        'FUNCION encapsula lógica reutilizable y puede recibir parámetros.',
    codeExample:
        'INICIO\n  FUNCION saludar(nombre)\n    ESCRIBIR "Hola", nombre\n  FinFuncion\nFIN',
  ),
  PseudocodeFlashcard(
    title: 'Llamar una función',
    description: 'LLAMAR ejecuta la función previamente declarada.',
    codeExample: 'INICIO\n  LLAMAR saludar("Axel")\nFIN',
  ),
];

import 'dart:math';

class SyntaxCoach {
  static final Set<String> _keywords = {
    'INICIO',
    'FIN',
    'LEER',
    'ESCRIBIR',
    'VARIABLE',
    'SI',
    'ENTONCES',
    'SINO',
    'FINSI',
    'REPITE',
    'FINREPITE',
    'MIENTRAS',
    'FINMIENTRAS',
    'FUNCION',
    'FINFUNCION',
    'LLAMAR',
    'FINPROGRAMA',
  };
  static final Set<String> _blockOpeners = {
    'INICIO',
    'SI',
    'REPITE',
    'MIENTRAS',
    'FUNCION',
  };

  static final Set<String> _blockClosers = {
    'FIN',
    'FINPROGRAMA',
    'FINSI',
    'FINREPITE',
    'FINMIENTRAS',
    'FINFUNCION',
  };

  static List<String> buildSuggestions(String code) {
    final lines = _meaningfulLines(code);
    if (lines.isEmpty) {
      return [
        'Empieza con INICIO para abrir tu algoritmo.',
        'Declara variables con VARIABLE nombre = valor.',
        'Finaliza con FIN para cerrar el bloque principal.',
      ];
    }

    final hints = <String>[];
    final skeletonHints = _suggestBeyondSkeleton(lines);
    if (skeletonHints != null) {
      return skeletonHints;
    }
    final typoHint = _detectKeywordTypo(lines);
    if (typoHint != null) {
      hints.add(typoHint);
    }

    final parenthesisHint = _detectParenthesisMismatch(lines);
    if (parenthesisHint != null) {
      hints.add(parenthesisHint);
    }
    final hasInicio = lines.any((line) => line.toUpperCase() == 'INICIO');
    if (!hasInicio) {
      hints.add('Agrega la palabra clave INICIO como primera línea.');
    }

    final hasFin = lines.any((line) => line.toUpperCase() == 'FIN');
    if (hasInicio && !hasFin) {
      hints.add('Cierra el bloque principal con FIN.');
    }

    final openBlocks = _countOpenBlocks(lines);
    if (openBlocks > 0) {
      hints.add(
        'Tienes ${openBlocks.toString()} bloque(s) sin cerrar (usa FinSi / FinMientras / FinFuncion).',
      );
    }

    final nextStep = _nextStepHint(lines);
    if (nextStep != null) {
      hints.add(nextStep);
    }

    return hints;
  }

  static String friendlyError(String code, String rawMessage) {
    final buffer = StringBuffer(
      'No pude ejecutar el algoritmo porque encontré un error de sintaxis.',
    );
    if (rawMessage.trim().isNotEmpty) {
      buffer
        ..writeln()
        ..writeln(rawMessage.trim());
    }

    final hints = buildSuggestions(code);
    if (hints.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Sugerencias para corregirlo:');
      for (final hint in hints.take(3)) {
        buffer.writeln('- $hint');
      }
    }

    return buffer.toString();
  }

  static bool opensBlock(String line) {
    final upper = line.trim().toUpperCase();
    if (upper.isEmpty) return false;

    if (_blockOpeners.contains(upper)) {
      return true;
    }

    if (upper.startsWith('SI ')) return true;
    if (upper.startsWith('MIENTRAS ')) return true;
    if (upper.startsWith('REPITE')) return true;
    if (upper.startsWith('FUNCION ')) return true;

    return false;
  }

  static bool closesBlock(String line) {
    final upper = line.trim().toUpperCase();
    if (upper.isEmpty) return false;
    return _blockClosers.any((closer) => upper.startsWith(closer));
  }

  static List<String> _meaningfulLines(String code) {
    return code
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && !line.startsWith('//'))
        .toList();
  }

  static List<String>? _suggestBeyondSkeleton(List<String> lines) {
    if (lines.length < 2) return null;
    final hasOnlyStructure =
        lines.length == 2 &&
        lines.first.toUpperCase() == 'INICIO' &&
        lines.last.toUpperCase() == 'FIN';

    if (!hasOnlyStructure) {
      return null;
    }

    return [
      'Tu programa solo tiene INICIO y FIN. Declara variables con VARIABLE nombre = valor.',
      'Solicita datos del usuario usando LEER nombreVariable.',
      'Muestra resultados con ESCRIBIR "mensaje", variable.',
      'Toma decisiones con SI condicion ENTONCES ... FinSi.',
      'Repite acciones con REPITE ... FinRepite o MIENTRAS ... FinMientras.',
      'Divide lógica en FUNCION nombre() ... FinFuncion y ejecútala con LLAMAR nombre.',
    ];
  }

  static String? _detectKeywordTypo(List<String> lines) {
    for (int i = 0; i < lines.length; i++) {
      final raw = lines[i];
      if (raw.isEmpty) continue;

      final firstToken = raw.split(RegExp(r'\s+')).first;
      final cleaned = firstToken.replaceAll(RegExp(r'[^A-ZÁÉÍÓÚÑ]'), '');
      if (cleaned.isEmpty) continue;

      final upper = cleaned.toUpperCase();
      if (_keywords.contains(upper)) continue;

      final candidate = _closestKeyword(upper);
      if (candidate != null) {
        return 'Línea ${i + 1}: verifica "$firstToken"; ¿quisiste escribir $candidate?';
      }
    }
    return null;
  }

  static String? _detectParenthesisMismatch(List<String> lines) {
    for (int i = 0; i < lines.length; i++) {
      final raw = lines[i];
      final upper = raw.toUpperCase();
      if (!(upper.contains('ESCRIBIR') || upper.contains('LEER'))) {
        continue;
      }

      final opens = _countChar(raw, '(');
      final closes = _countChar(raw, ')');
      if (opens == closes) continue;

      final keyword = upper.contains('ESCRIBIR') ? 'ESCRIBIR' : 'LEER';
      if (opens > closes) {
        return 'Línea ${i + 1}: te falta cerrar un paréntesis en $keyword.';
      }
      return 'Línea ${i + 1}: tienes un paréntesis de más en $keyword.';
    }
    return null;
  }

  static String? _closestKeyword(String token) {
    if (token.length < 3) return null;

    String? best;
    var bestDistance = 3;
    for (final keyword in _keywords) {
      final distance = _levenshtein(token, keyword);
      if (distance < bestDistance) {
        best = keyword;
        bestDistance = distance;
      }
    }

    if (bestDistance <= 2) {
      return best;
    }
    return null;
  }

  static int _levenshtein(String a, String b) {
    final m = a.length;
    final n = b.length;
    final dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));

    for (var i = 0; i <= m; i++) {
      dp[i][0] = i;
    }
    for (var j = 0; j <= n; j++) {
      dp[0][j] = j;
    }

    for (var i = 1; i <= m; i++) {
      for (var j = 1; j <= n; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        dp[i][j] = min(
          dp[i - 1][j] + 1,
          min(dp[i][j - 1] + 1, dp[i - 1][j - 1] + cost),
        );
      }
    }

    return dp[m][n];
  }

  static int _countChar(String input, String char) {
    var total = 0;
    for (final rune in input.runes) {
      if (String.fromCharCode(rune) == char) {
        total++;
      }
    }
    return total;
  }

  static int _countOpenBlocks(List<String> lines) {
    final stack = <String>[];
    for (final raw in lines) {
      final upper = raw.trim().toUpperCase();
      if (upper.isEmpty) continue;

      if (opensBlock(upper)) {
        stack.add(upper);
        continue;
      }

      if (closesBlock(upper) && stack.isNotEmpty) {
        stack.removeLast();
      }
    }
    return max(0, stack.length);
  }

  static String? _nextStepHint(List<String> lines) {
    if (lines.isEmpty) return null;
    final last = lines.last.trim().toUpperCase();

    if (last == 'INICIO') {
      return 'Puedes declarar variables con VARIABLE nombre = valor.';
    }
    if (last.startsWith('VARIABLE')) {
      return 'Solicita datos con LEER variable o muestra resultados con ESCRIBIR.';
    }
    if (last.startsWith('SI ')) {
      return 'No olvides cerrar la condición con FinSi.';
    }
    if (last.startsWith('REPITE')) {
      return 'Recuerda terminar el ciclo con FinRepite.';
    }
    if (last.startsWith('MIENTRAS')) {
      return 'Cierra el ciclo con FinMientras.';
    }
    if (last.startsWith('FUNCION')) {
      return 'Cierra la función con FinFuncion.';
    }
    if (last == 'FIN') {
      return 'Todo listo, puedes ejecutar el algoritmo cuando quieras.';
    }

    return 'Puedes usar LEER, ESCRIBIR, SI, REPITE o FUNCION para continuar.';
  }
}

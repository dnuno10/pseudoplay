// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'PseudoPlay';

  @override
  String get splashLoadingMessage => 'Cargando núcleo retro…';

  @override
  String get splashInitPreferences => 'Inicializando tus preferencias';

  @override
  String get splashTapToStart => 'PRESIONA START';

  @override
  String get splashProgressLabel => 'Cargando';

  @override
  String get nameDialogTitle => 'Elige tu nombre de juego';

  @override
  String get nameDialogMessage =>
      'Ingresa el nombre que aparecerá en las consolas retro.';

  @override
  String get nameDialogPlaceholder => 'Nombre del jugador';

  @override
  String get nameDialogConfirm => 'Guardar';

  @override
  String get nameDialogCancel => 'Cancelar';

  @override
  String get nameRequiredError => 'Necesitas un nombre para continuar.';

  @override
  String get menuFlashcardsTitle => 'Flashcards de pseudocódigo';

  @override
  String get menuFlashcardsDescription =>
      'Voltea tarjetas retro y memoriza cada palabra reservada entre INICIO y FIN.';

  @override
  String get menuFlashcardsCTA => 'Jugar';

  @override
  String get menuPlayButton => 'Jugar';

  @override
  String get menuUserPrefix => 'USR>';

  @override
  String get menuEditButton => 'Editar';

  @override
  String get menuExecuteTitle => 'Ejecutar pseudocódigo';

  @override
  String get menuExecuteSubtitle =>
      'Escribe y ejecuta algoritmos paso a paso sin fricción.';

  @override
  String get menuBlocksTitle => 'Modo por bloques';

  @override
  String get menuBlocksSubtitle =>
      'Arrastra bloques retro para construir algoritmos visualmente.';

  @override
  String get menuPlaytimeLabel => 'Tiempo jugado';

  @override
  String get menuAlgorithmsLabel => 'Algoritmos ejecutados';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsLanguageLabel => 'Idioma';

  @override
  String get settingsLanguageEnglish => 'Inglés';

  @override
  String get settingsLanguageSpanish => 'Español';

  @override
  String get settingsLanguageDescription =>
      'Cambia todo el sistema retro al idioma que prefieras.';

  @override
  String get settingsRenameButton => 'Cambiar nombre del jugador';

  @override
  String get settingsClearCacheButton => 'Borrar caché y reiniciar';

  @override
  String get settingsClearCacheConfirm =>
      '¿Seguro? Se borrarán progreso, nombre y preferencias locales.';

  @override
  String get settingsPrivacyTitle => 'Privacidad';

  @override
  String get settingsPrivacyBody =>
      'Solo guardamos tus estadísticas locales en este dispositivo. Nada se envía a internet.';

  @override
  String get settingsTermsTitle => 'Términos y condiciones';

  @override
  String get settingsTermsBody =>
      'Usa PseudoPlay con responsabilidad. Las vibras retro se ofrecen tal cual, sin garantías.';

  @override
  String get privacyDialogClose => 'Cerrar';

  @override
  String get termsViewTitle => 'Términos y condiciones';

  @override
  String get termsViewIntroTitle => 'Uso de PseudoPlay';

  @override
  String get termsViewIntroBody =>
      'PseudoPlay es una herramienta de aprendizaje para experimentar con algoritmos. Al continuar aceptas usarla con respeto y solo con fines educativos.';

  @override
  String get termsViewContentTitle => 'Propiedad del contenido';

  @override
  String get termsViewContentBody =>
      'Todos los assets retro, textos y estilo visual pertenecen al equipo de PseudoPlay. No los redistribuyas sin permiso.';

  @override
  String get termsViewWarrantyTitle => 'Garantía y responsabilidad';

  @override
  String get termsViewWarrantyBody =>
      'PseudoPlay se ofrece tal cual, sin garantías. No somos responsables por pérdida de datos, interrupciones o daños causados por un mal uso.';

  @override
  String get termsViewUpdatesTitle => 'Actualizaciones';

  @override
  String get termsViewUpdatesBody =>
      'Estos términos pueden cambiar cuando lancemos nuevas versiones. Avisaremos dentro de la app cuando haya cambios importantes.';

  @override
  String get privacyViewTitle => 'Política de privacidad';

  @override
  String get privacyViewIntroTitle => 'Qué guardamos';

  @override
  String get privacyViewIntroBody =>
      'PseudoPlay guarda tu nombre de jugador, estadísticas de ejecución y preferencias únicamente en tu dispositivo para que puedas seguir jugando sin conexión.';

  @override
  String get privacyViewDataTitle => 'Sin sincronización en la nube';

  @override
  String get privacyViewDataBody =>
      'Nunca enviamos tu información a servidores externos. Al limpiar la caché se elimina todo de forma permanente.';

  @override
  String get privacyViewControlTitle => 'Tu control';

  @override
  String get privacyViewControlBody =>
      'Puedes borrar los datos cuando quieras desde la zona de peligro en ajustes.';

  @override
  String get privacyViewContactTitle => '¿Dudas?';

  @override
  String get privacyViewContactBody =>
      'Escríbenos si necesitas más detalles sobre esta política o ayuda para gestionar tus datos.';

  @override
  String get statsHoursSuffix => 'h';

  @override
  String get statsMinutesSuffix => 'm';

  @override
  String get statsSecondsSuffix => 's';

  @override
  String statsAlgorithmsValue(int count) {
    return '$count algoritmos';
  }

  @override
  String get languageDialogTitle => 'Selecciona idioma';

  @override
  String get playtimeEmpty => '0 h 0 m 0 s';

  @override
  String get snackbarNameUpdated => '¡Nombre actualizado!';

  @override
  String get snackbarCacheCleared => 'Caché borrada. Reiniciando…';

  @override
  String get snackbarLanguageUpdated => 'Idioma actualizado';

  @override
  String get splashMissingNameTitle =>
      'Necesitamos tu nombre de jugador para continuar.';

  @override
  String get modeTimeUnavailable => 'Aún no hay tiempo registrado';

  @override
  String get settingsOpenPrivacy => 'Leer privacidad';

  @override
  String get settingsOpenTerms => 'Leer términos';

  @override
  String get flashcardsIntroDescription =>
      'Explora cada tarjeta para saber cómo escribir las operaciones más comunes entre INICIO y FIN. Toca para voltear y ver el ejemplo completo.';

  @override
  String get genericBack => 'Regresar';
}

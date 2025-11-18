enum GameMode {
  code("code"),
  blocks("blocks"),
  execution("execution"),
  flashcards("flashcards");

  final String storageKey;
  const GameMode(this.storageKey);
}

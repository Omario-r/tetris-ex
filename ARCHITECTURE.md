# ARCHITECTURE.md — Explosive Template Tetris

## Принципы

1. **Чистое ядро** — game_engine/ не содержит ни одного импорта flutter/*. Вся логика тестируется без эмулятора.
2. **Однонаправленные зависимости** — presentation → application → game_engine. Обратные импорты запрещены.
3. **Детерминизм** — при фиксированном seed или FixedSequenceGenerator результат воспроизводим. Это основа тестируемости.
4. **No Flame** — рендеринг через CustomPainter, тайминг через Ticker. Минимум внешних зависимостей.

---

## Слои

```text
┌──────────────────────────────────────────────────┐
│  presentation/                                   │  Flutter UI, CustomPainter, жесты
│  board_painter · hud · game_screen               │  import: flutter/*, application/
├──────────────────────────────────────────────────┤
│  application/                                    │  Ticker → controller.tick(dt)
│  game_loop.dart                                  │  import: flutter/scheduler, game_engine/
├──────────────────────────────────────────────────┤
│  game_engine/                                    │  Чистый Dart. Без flutter/*
│  models/ · rules/ · game/                        │  import: dart:core, dart:math
└──────────────────────────────────────────────────┘
```

---

## Структура модулей

```text
lib/
  game_engine/                                    # ЗАПРЕТ: import 'package:flutter/...'
    models/
      board.dart                                  # Board, Cell — массив row-major, 10×20
      piece.dart                                  # PieceType, Piece — 7 тетромино, матрица 4×4
      falling_piece.dart                          # FallingPiece: piece + (x,y) + mode + armedUsed
      level_template.dart                         # LevelTemplate: S, H, moveLimit, objectId, fragmentIndex
      target_mask.dart                            # TargetMask: MSB-first битмаска, до 8×8 (64 бит)
    rules/
      collision.dart                              # canMove(), canRotate() — Normal и Explosive
      rotation.dart                               # rotateCW(): transpose + reverse rows
      explosion.dart                              # explodeFootprint(): удаление по отпечатку
      halo.dart                                   # computeHalo8(), checkWin(): 8-соседство
      randomizer.dart                             # SevenBagGenerator, FixedSequenceGenerator
    game/
      game_state.dart                             # GameState (иммутабельный снапшот), GamePhase
      game_controller.dart                        # Публичный API: все команды + tick(dt)
  application/                                    # ЗАПРЕТ: import '...presentation/...'
    game_loop.dart                                # Ticker → controller.tick(dt) → notifier
  presentation/                                   # Может импортировать application/ и game_engine/
    widgets/
      board_painter.dart                          # CustomPainter: Board, Target S, Halo H, falling piece
      hud.dart                                    # Кнопки: ←, →, ↻, Arm, Detonate
    screens/
      game_screen.dart                            # CustomPaint + HUD + жесты
      level_complete_screen.dart
      object_complete_screen.dart
```

---

## Публичный API GameController

Все команды возвращают void. При невозможности выполнить — no-op, state не меняется.

| Команда | No-op при |
|---------|-----------|
| moveLeft/Right | у стены или нет активной фигуры |
| rotateCW | коллизия после поворота |
| softDrop | нет активной фигуры |
| armExplosive | фигура уже Explosive, armedUsed == true, нет фигуры |
| detonate | фигура в Normal, нет фигуры, уже взорвана |
| tick(dt) | phase == won или phase == lost |

---

## Ключевые инварианты модели данных

**Board** — List<Cell> длиной width × height, индекс i = y * width + x.

**FallingPiece.mode** — normal | explosive. Переход только normal → explosive, ровно один раз на фигуру (armedUsed = true).

**GamePhase** — spawning | falling | won | lost. Переходы управляются только внутри tick(dt) и detonate().

**GameState** — иммутабельный снапшот для UI. GameController хранит мутабельное состояние внутри, снаружи не видно.

**TargetMask** — MSB-first, бит b = (w*h − 1) − (y * w + x). MVP поддерживает окна до 8×8 (Dart int, 64 бита).

---

## Слой application/

GameLoop держит Ticker Flutter и вызывает controller.tick(elapsed) каждый кадр. Уведомляет ValueNotifier<GameState> для перерисовки CustomPainter. GameLoop знает о Flutter, но не знает о деталях game_engine.

---

## Слой presentation/

**BoardPainter extends CustomPainter** — рисует поле, зону S (Target), зону H (Halo, красным если в ней есть мусор), falling piece. Перерисовка через repaint: Listenable — без лишних build/layout.

**GameScreen** — CustomPaint + HUD (кнопки ←, →, ↻, Arm, Detonate).

**Жесты:** свайп ←/→ → moveLeft/Right(), tap вверх → rotateCW().

Кнопка Arm видима и активна только при state.canArm == true.

Кнопка Detonate видима и активна только при state.canDetonate == true.

---

## Правила импортов (lint / ревью по AGENTS.md)

**Запрещено в game_engine/**:

```text
import 'package:flutter/...';
```

**Запрещено в application/**:

```text
import '...presentation/...';
```

**Запрещено в game_engine/**:

```text
import '...presentation/...';
import '...application/...';
```

---

## Тестируемость

| Слой | Инструмент | Окружение |
|------|------------|-----------|
| game_engine/ | dart test | Без эмулятора |
| presentation/ | flutter test (WidgetTester) | Flutter test env |
| Интеграция | flutter test + FixedSequenceGenerator | Flutter test env |

Детерминизм гарантирован FixedSequenceGenerator(List<PieceType>) — без RNG, полный контроль последовательности.

---

## Мета-прогрессия (слой post-MVP)

```text
LevelMap (static)
  └── ObjectTemplate × 4
        └── FragmentDef × 4
              └── LevelTemplate
```

**ProgressService** — shared_preferences, ключ 'current_level': int (0..15)

**Навигация:**
GameScreen → LevelCompleteScreen → (ObjectCompleteScreen?) → GameScreen

**LevelCompleteScreen** — Canvas с сеткой фрагментов объекта, текущий фрагмент анимированно встаёт на место.
**ObjectCompleteScreen** — Canvas с собранным объектом целиком.

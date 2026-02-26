Вот полная обновлённая спецификация со всеми зафиксированными решениями. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_00a62dc2-9771-4bb3-a246-755869e88bac/a3940dd6-8605-4a7c-bf13-09fe539c7485/Tetris-ex-doc.md)

***

# Tetris-ex-spec.md
## Расширенная спецификация прототипа «Explosive Template Tetris» (MVP)

***

## 1. Термины и соглашения

### 1.1 Система координат
- `(0, 0)` — левый верхний угол поля.
- `x` растёт вправо, `y` растёт **вниз** (как в Flutter Canvas).
- "Дно" поля: `y = height - 1`. Стены: `x = 0` и `x = width - 1`.
- Индексация клеток: `i = y * width + x` (row-major).

### 1.2 Термины
- **S** — множество клеток Target, которые должны быть заполнены для победы.
- **H (Halo)** — клетки поля, прилегающие к S по 8‑соседству, но не входящие в S. Вычисляется один раз при создании `LevelTemplate` и хранится в нём.
- **"Мусор"** — любая занятая клетка, не входящая в S.
- **"Отпечаток"** — множество клеток поля, занятых падающей фигурой в конкретный момент.
- **"Фиксация"** — переход падающей фигуры в установленные блоки поля.
- **"Ход"** — цикл от спавна фигуры до её фиксации или взрыва.
- **no-op** — команда принята, но ничего не происходит; state не меняется.

***

## 2. Дефолты MVP

| Параметр | Значение |
|----------|----------|
| Board size | 10×20 |
| Target window | 6×6 |
| Target xStart | 2 (0-based, колонки 2..7) |
| Target yStart | 14 (= 20 − 6, anchored bottom) |
| Target mask S | Крест толщиной 2 (см. 2.1) |
| Randomizer | 7-bag, опциональный seed |
| Halo rule | 8-соседство; клетки H вне поля игнорируются |
| Piece rotation | Упрощённый CW (без SRS, без wall kicks) |
| Coordinate origin | y=0 сверху, y растёт вниз |

### 2.1 Target mask S — крест толщиной 2 в окне 6×6

Клетка `(x, y)` локального окна входит в S, если `x ∈ {2,3}` или `y ∈ {2,3}`.

**ASCII** (`.` = пусто, `#` = S):
```
..##..    y=0
..##..    y=1
######    y=2
######    y=3
..##..    y=4
..##..    y=5
```

**Битмаска MSB-first (36 бит):**
- Клетка `(x, y)` → бит `b = 35 − (y * 6 + x)`.
- `(0,0)` — MSB (бит 35); `(5,5)` — LSB (бит 0).
- Hex: `0x30CFFF30C`
- Bin: `0b001100001100111111111111001100001100`

**Проверка принадлежности (Dart):**
```dart
bool contains(int localX, int localY) {
  final bitIndex = 35 - (localY * 6 + localX);
  return (mask & (1 << bitIndex)) != 0;
}
```

**Координаты S в поле:**  
`S_field = { (x + 2, y + 14) | (x,y) ∈ S_local }`

***

## 3. Игровые правила

### 3.0 Фигуры, спавн и повороты

**7 тетромино — формы спавна** (4×4 бокс, `.` = пусто, `X` = занято):

```
I:          O:          T:
....        .XX.        XXX.
XXXX        .XX.        .X..
....        ....        ....
....        ....        ....

S:          Z:          J:          L:
.XX.        XX..        X...        ..X.
XX..        .XX.        XXX.        XXX.
....        ....        ....        ....
....        ....        ....        ....
```

**Спавн:** Бокс 4×4 размещается в верхней части поля с `xStart = (boardWidth − 4) / 2 = 3`, `yStart = 0`.

**Поворот CW (упрощённый, без SRS и без wall kicks):**
- Алгоритм: транспонировать матрицу 4×4, затем отразить каждую строку по горизонтали.
- Если после поворота отпечаток выходит за границу или пересекается с установленными блоками → **no-op** (команда игнорируется, поворот не применяется).
- В MVP реализуется **только CW**. CCW — backlog post-MVP.
- **Wall kicks отсутствуют**: если поворот невозможен — no-op.

**Edge cases:**
- O-piece не изменяется при повороте (4 состояния идентичны).
- I-piece имеет 2 уникальных состояния (горизонталь/вертикаль).

### 3.1 Спавн и коллизии (Normal)

- Новая фигура спавнится в режиме **Normal**.
- **Коллизия Normal**: фигура не может занять клетку, занятую границей поля или установленным блоком.
- **Фиксация**: если фигура не может сдвинуться на `y+1` из-за коллизии — она фиксируется; блоки переходят в поле; запускается проверка победы.
- `moveLeft()` / `moveRight()` у стены → **no-op**.
- `softDrop()` ускоряет падение (увеличивает скорость тика гравитации); при коллизии внизу — фиксация.

**Edge cases:**
- Клетки спавна уже заняты → **поражение** (переполнение).

### 3.2 Перевод в Explosive

- Команда `armExplosive()` переводит текущую падающую фигуру из `Normal` в `Explosive`.
- Разрешён **ровно один раз** на каждую новую фигуру. Флаг `armedUsed = true`.
- **Обратный переход запрещён.**
- `armExplosive()` валиден только при наличии активной падающей фигуры в режиме `Normal`. В любом другом состоянии — **no-op**.
- Повторный вызов `armExplosive()` — **no-op**.

### 3.3 Explosive падение и взрыв

**Коллизии в Explosive:**
- Фигура проверяет коллизии **только с границами поля** (стены и дно).
- Установленные блоки игнорируются: фигура проходит сквозь них.
- `softDrop()` работает в Explosive так же, как в Normal: ускоряет падение, не меняет правила коллизий.

**Авто-детонация:**
- Происходит, когда **ни одна занятая клетка** фигуры не может сдвинуться на `y+1` из-за нижней границы поля (т.е. хотя бы одна клетка фигуры находится на `y = boardHeight − 1`).

**Ручная детонация:**
- Команда `detonate()` доступна в любой момент, пока фигура в режиме `Explosive`.
- `detonate()` при режиме `Normal` → **no-op**.

**Что удаляет взрыв:**
- Только клетки поля, которые совпадают с **отпечатком** фигуры в момент взрыва (пересечение клеток фигуры с занятыми клетками поля).
- Пустые клетки под фигурой не затрагиваются.
- Блоки вне отпечатка не затрагиваются.
- После взрыва фигура исчезает; запускается колоночная гравитация, затем проверка победы.

**Edge cases:**
- Взрыв над полностью пустой зоной → удалений нет, гравитация не применяется.
- Авто-взрыв и ручной взрыв в одном тике: флаг `exploded = true` предотвращает двойную обработку.
- `detonate()` на уже взорванной фигуре → **no-op**.

### 3.4 Ограниченная колоночная гравитация после взрыва

Применяется только в колонках, где были удалённые клетки.

**Определение:**  
`removedBelow[x][y]` = количество удалённых клеток в колонке `x` с `y2 > y` (ниже по полю, т.е. с бо́льшим `y`).

**Алгоритм (псевдокод):**
```
for x in 0..width-1:
    if column x had no deletions: continue

    // Считаем removedBelow для каждой строки
    count = 0
    for y from (height-1) downto 0:
        removedBelow[y] = count
        if cell(x,y) was removed: count += 1

    // Сдвигаем вниз
    for y from (height-1) downto 0:
        if cell(x,y) occupied and not removed:
            shift = removedBelow[y]
            if shift > 0:
                cell(x, y + shift) = cell(x, y)
                cell(x, y) = empty
```

**Свойства:**
- Заполняются только новые пустоты от взрыва.
- Старые пустоты (существовавшие до взрыва) **остаются** на месте.
- Блоки в других колонках не затрагиваются.

**Edge cases:**
- Нет удалений в колонке → пропуск.
- Все клетки колонки удалены → колонка полностью пуста.
- Блок в самом низу колонки с удалениями ниже → невозможно (удаление и блок не могут быть в одной клетке).


### 3.5 Порядок шагов tick(dt)

`tick(dt)` вызывается игровым циклом каждый кадр. Ручные команды (`moveLeft`, `rotateCW`, `armExplosive`, `detonate` и др.) выполняются **вне** tick — немедленно по действию игрока.

```
tick(dt):

  1. if phase == won OR phase == lost
       → return (no-op, игра остановлена)

  2. if phase == spawning:
       - взять следующую фигуру из генератора
       - разместить: x=3, y=0
       - if коллизия Normal в точке спавна
           → phase = lost; return
       - phase = falling; return
         // гравитация к новой фигуре применяется только со следующего тика

  3. // phase == falling
     gravityAccum += dt
     if gravityAccum < gravityInterval → return
     gravityAccum -= gravityInterval

  4. if mode == Normal:
       - if canMoveDown() → piece.y += 1
       - else:                          // коллизия снизу
           → зафиксировать отпечаток в Board
           → checkWin:
               if win  → phase = won; return
               if !win → phase = spawning

  5. if mode == Explosive:
       - if canMoveDownExplosive() → piece.y += 1
         // canMoveDownExplosive: проверяет только нижнюю границу поля,
         //   т.е. ни одна занятая клетка фигуры не может сдвинуться на y+1
       - else:                          // касание дна → авто-детонация
           → explodeFootprint()
           → applyLimitedGravity()
           → checkWin:
               if win  → phase = won; return
               if !win → phase = spawning
```

**Ручная `detonate()` — отдельная команда (вне tick):**
```
detonate():
  if mode != Explosive → no-op; return
  → explodeFootprint()
  → applyLimitedGravity()
  → checkWin:
      if win  → phase = won
      if !win → phase = spawning
```

**`softDrop()` — отдельная команда (вне tick):**
```
softDrop():
  → gravityAccum = gravityInterval
  // Принудительно запускает шаг гравитации в следующем tick.
  // Не вызывает tick() напрямую — эффект применится через цикл.
```

**Инварианты:**
- Авто-детонация происходит только внутри tick (шаг 5).
- Ручная детонация происходит только через команду `detonate()`.
- Двойное срабатывание исключено: после взрыва `phase = spawning`, поэтому tick на следующем кадре перейдёт к шагу 2, а не к шагам 4/5.
- `gravityAccum` сбрасывается при спавне новой фигуры.

***

## 4. Проверка победы и поражения

### 4.1 Победа
Проверяется **сразу** после каждой фиксации или взрыва (после применения гравитации).

**Условие:**
- Все клетки S заняты.
- Все клетки H **внутри поля** пусты. (H вне границ поля — игнорируются.)

**H вычисляется один раз при создании уровня:**
```dart
Set<(int, int)> computeHalo(Set<(int, int)> S, int boardW, int boardH) {
  final H = <(int, int)>{};
  for (final (sx, sy) in S) {
    for (final dx in [-1, 0, 1]) {
      for (final dy in [-1, 0, 1]) {
        if (dx == 0 && dy == 0) continue;
        final nx = sx + dx; final ny = sy + dy;
        if (nx < 0 || nx >= boardW || ny < 0 || ny >= boardH) continue;
        if (!S.contains((nx, ny))) H.add((nx, ny));
      }
    }
  }
  return H;
}
```

**Edge cases:**
- S касается стены/дна → часть H выходит за границу → игнорируется (победа не блокируется).
- S заполнено, H имеет хотя бы 1 мусорный блок → **не победа**.

### 4.2 Поражение
- **Overflow**: клетки спавна заняты при попытке создать новую фигуру.
- (Post-MVP) Лимит ходов исчерпан.

***

## 5. Данные уровня

### 5.1 LevelTemplate
```dart
class LevelTemplate {
  final int boardWidth;       // 10
  final int boardHeight;      // 20
  final TargetMask targetMask;
  final int targetX;          // xStart = 2
  final int targetY;          // yStart = 14
  final int? moveLimit;       // null = без лимита
  late final Set<(int,int)> S;
  late final Set<(int,int)> H;

  LevelTemplate(...) {
    S = _buildS();
    H = computeHalo(S, boardWidth, boardHeight);
  }
}
```

### 5.2 TargetMask (MSB-first)
```dart
class TargetMask {
  final int width;   // 6
  final int height;  // 6
  final int mask;    // MSB-first, макс. 8×8 = 64 бит (Dart int)

  // Примечание: для MVP поддерживаются окна до 8×8 (64 бита).
  // Для бо́льших окон потребуется другой тип хранения.

  bool contains(int localX, int localY) {
    final totalBits = width * height;
    final bitIndex = (totalBits - 1) - (localY * width + localX);
    return (mask & (1 << bitIndex)) != 0;
  }
}
```

**Дефолтный уровень (MVP):**
```dart
final defaultLevel = LevelTemplate(
  boardWidth: 10,
  boardHeight: 20,
  targetMask: TargetMask(width: 6, height: 6, mask: 0x30CFFF30C),
  targetX: 2,
  targetY: 14,
  moveLimit: null,
);
```

### 5.3 Детерминизм и тесты
- `SevenBagGenerator` принимает опциональный `seed: int?`. При `seed != null` — детерминированный запуск.
- Для integration-тестов используется `FixedSequenceGenerator(List<PieceType>)` — без RNG, полный контроль над последовательностью.
- Рекомендуемый seed для тестов: `seed = 42`.

***

## 6. Архитектура и API движка

### 6.1 Структура модулей
```
lib/
  game_engine/              // чистый Dart, без import flutter
    models/
      board.dart            // Board, Cell
      piece.dart            // PieceType, Piece (4x4 матрица + повороты CW)
      falling_piece.dart    // FallingPiece (piece, x, y, mode, armedUsed)
      level_template.dart   // LevelTemplate, S, H
      target_mask.dart      // TargetMask (MSB-first)
    rules/
      collision.dart        // canMove(), canRotate()
      rotation.dart         // rotateCW() — transpose + reverse rows
      explosion.dart        // explodeFootprint(), applyLimitedGravity()
      halo.dart             // computeHalo8(), checkWin()
      randomizer.dart       // SevenBagGenerator, FixedSequenceGenerator
    game/
      game_state.dart       // GameState, GamePhase
      game_controller.dart  // публичные команды
  presentation/
    widgets/
      board_painter.dart    // CustomPainter
      hud.dart
    screens/
      game_screen.dart
  application/
    game_loop.dart          // Ticker/AnimationController → controller.tick(dt)
```

**Инварианты:**
- `game_engine/` не импортирует `flutter/*`.
- Зависимости только вниз: `presentation → application → game_engine`.
- Все операции engine детерминированы при фиксированном seed / `FixedSequenceGenerator`.

### 6.2 Публичный API GameController
```dart
class GameController {
  // Все команды: void, при невозможности выполнить — no-op, state не меняется.
  void moveLeft();       // сдвиг фигуры влево; у стены — no-op
  void moveRight();      // сдвиг вправо; у стены — no-op
  void rotateCW();       // поворот CW; при коллизии — no-op (нет wall kicks)
  void softDrop();       // ускорить падение; работает в Normal и Explosive
  void armExplosive();   // Normal → Explosive, один раз; иначе — no-op
  void detonate();       // взрыв, только в Explosive; иначе — no-op
  void tick(double dt);  // гравитация + авто-взрыв на дне

  GameState get state;
}
```

### 6.3 GameState (минимум для UI)
```dart
class GameState {
  final Board board;
  final FallingPiece? fallingPiece;  // null если нет активной фигуры
  final GamePhase phase;             // spawning / falling / exploding / won / lost
  final LevelTemplate level;
  // Флаги для UI:
  final bool canArm;     // fallingPiece?.mode == Normal && !armedUsed
  final bool canDetonate;// fallingPiece?.mode == Explosive
  final bool isWin;
  final bool isLost;
  // Для подсветки H:
  Set<(int,int)> get dirtyHalo =>
    level.H.where((cell) => board.isOccupied(cell)).toSet();
}
```

***

## 7. Тестирование

### 7.1 Unit-тесты (engine, чистый Dart)

**Halo (8-соседство):**
- Все 8 направлений учитываются (включая диагонали).
- Клетки H вне поля игнорируются.
- S у стены: часть H выходит за границу → победа не блокируется.

**Проверка победы:**
- S заполнено, H пусто → `isWin = true`.
- S заполнено, 1 мусорный блок в H → `isWin = false`.
- S частично заполнено → `isWin = false`.

**Explosive:**
- Фигура проходит сквозь установленные блоки без фиксации.
- `armExplosive()` второй раз → no-op, mode не меняется.
- Авто-детонация: хотя бы одна клетка фигуры на `y = boardHeight − 1`.

**Взрыв (отпечаток):**
- Удаляются только клетки под занятыми клетками фигуры.
- Пустые клетки под фигурой не затрагиваются.

**Гравитация после взрыва:**
- Блок над 2 удалёнными клетками сдвигается вниз на 2.
- Старые пустоты не заполняются.
- Без удалений → гравитация не применяется.

**Поворот CW:**
- Поворот при коллизии → no-op, форма не меняется.
- O-piece: 4 поворота CW → та же форма.
- I-piece: 2 уникальных состояния.

### 7.2 Widget-тесты (UI)
- Подсветка S (выделение целевых клеток).
- Подсветка H: красным, если в H есть мусор.
- Кнопка Arm: видима и активна только при `canArm == true`.
- Кнопка Detonate: видима и активна только при `canDetonate == true`.
- Жесты/кнопки движения вызывают нужные команды.

### 7.3 Integration-тест (1 золотой сценарий)

**Seed / последовательность:**  
Использовать `FixedSequenceGenerator([I, I, I, I, I, I])` — 6 I-образных фигур, достаточно для заполнения 6×2 зон креста.

**Сценарий:**
1. Запустить игру с `defaultLevel`.
2. Разместить фигуры, заполняющие S (крест 6×6 с xStart=2, yStart=14).
3. Если H содержит мусор: заарм текущую фигуру (`armExplosive()`), детонировать (`detonate()`) над нужной зоной.
4. Проверить: `state.isWin == true`.
5. Воспроизводимость: один и тот же `FixedSequenceGenerator` даёт одинаковый результат.

**Критерий "готово":**
- Все unit/widget тесты зелёные.
- `flutter analyze` без ошибок.
- Integration-тест проходит воспроизводимо.
- Ручной сценарий уровня проходится на эмуляторе.

***

## 8. Backlog (post-MVP)

- Поворот CCW.
- Wall kicks (SRS или упрощённый вариант).
- Soft drop vs. hard drop (мгновенный сброс вниз).
- Анимации взрыва и гравитации (плавные).
- Лимит ходов на уровень.
- Звуковые эффекты.
- Несколько уровней с разными Target-масками.
- TargetMask для окон > 8×8 (смена типа хранения).

***

Спецификация закрывает все 13 замечаний.  Следующий шаг — backlog задач и готовые промпты для Junie, начиная с первых 3 тикетов? [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_00a62dc2-9771-4bb3-a246-755869e88bac/a3940dd6-8605-4a7c-bf13-09fe539c7485/Tetris-ex-doc.md)
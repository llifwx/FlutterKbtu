# Notes — Put It High, Subscribe Low

Rebuild counts are the `debugPrint` lines captured in widget tests (6 books, Windows-sized window).

## Level 1: lifted state

**Total in the badge, by hand:** 2 constructors (`BooksScreen`, `CartBadge`) in 3 files (`main.dart`, `books_screen.dart`, `cart_badge.dart`). `BooksScreen` never shows the total; it only carries it down.

**One tap on Add printed 7 lines:** `BooksScreen build` plus 6 `row ...`. Removing a book on the Cart screen also printed 7: the Books route rebuilt while it was covered.

## Level 2: the model alone

Before `runApp`, the model printed `1 items, 3100 ₸`.

- `cart.items.add(books[0])` throws `Unsupported operation: Cannot add to an unmodifiable list`.
- With a `BuildContext` field in `Cart`, `Cart()` stops compiling: `1 positional argument expected by 'Cart.new', but 0 found`. There is no context before `runApp`.

## Level 3: both provider errors

**The loud one:** `context.watch<Cart>().add(b)` in `onPressed`.

```text
Tried to listen to a value exposed with provider, from outside of the widget tree.

This is likely caused by an event handler (like a button's onPressed) that called
Provider.of without passing `listen: false`.

To fix, write:
Provider.of<Cart>(context, listen: false);
```

**The silent one:** `context.read<Cart>().count` in the badge's `build`. There is no error text. It compiles and runs, and after one Add the cart holds 1 book while the badge still says 0.

## Level 4: rebuild counts

Press + three times on a cart row, then remove the book:

| Variant (one line changed) | + × 3: badge | + × 3: rows | + × 3: BooksScreen | Remove: badge |
|---|---|---|---|---|
| Badge with `watch` | **3** | 0 | 0 | 1 |
| Badge with `select` (final) | **0** | 0 | 0 | 1 |
| Row with `watch` | 0 | 18 | 0 | 1 |
| `watch` moved up into `BooksScreen.build` | 0 | 18 | 3 | 1 |

One tap on Add now prints 2 lines instead of 7: `badge build` and the row that changed.

The rows use `select` rather than the `watch` from Level 3. With `watch` in each row, every + rebuilds all 6 rows even though nothing on them changed.

The `const` Total label in the cart builds once and 0 times on later notifies.

## Where does it live?

- **The cart: provided.** Two routes read and change it, so it lives above `MaterialApp`.
- **The search text: ephemeral.** Only `BooksScreen` uses it, so it lives in that screen's `State`.
- **Total expanded or collapsed: ephemeral.** Only the Cart screen cares, and nothing is lost if it resets.
- **The theme mode: provided.** `MaterialApp` itself needs it and a settings switch would change it, so it must sit above `MaterialApp`.

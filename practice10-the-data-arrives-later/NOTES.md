# Notes — The Data Arrives Later

All console lines below are copied from real runs: `flutter run -d windows` for Level 1, widget tests for the rest. Each "break it" change was applied for one run and then reverted.

## Level 1: the order of events

`main()` before `runApp`: `print('A')`, a 2-second `Future.delayed` printing `B`, `print('C')`, and three `fetchStudents()` calls with `.then(print)`.

| Predicted | Actual |
|---|---|
| `A` | `A` |
| `C` | `C` |
| — | `fetchStudents #1`, `#2`, `#3` (the code before the first `await` runs synchronously) |
| first frame | `first frame` |
| `B` (after 2 s) | `B` |
| `6 students` | `6 students` |
| `6 students` | `6 students` |
| third call fails | `[ERROR:flutter/runtime/dart_vm_initializer.cc(40)] Unhandled Exception: Instance of 'NoConnectionException'` |

`main()` ran to the end and the first frame was drawn before any timer fired. The failed third call did not stop the app; the window stayed open.

**Surprise on the first try:** all three calls failed. `fetchStudents` checked `calls % 3` after the `await`, and by then all three calls had already set `calls` to 3. The fix is to save the number before the delay (`final call = ++calls;`). Here the code that runs after `await` broke the fake API itself.

**`sleep` instead of `await`:** `A`, then `C at 2031 ms`, and `first frame at 3621 ms`. `sleep` blocked the whole thread, so even `print('C')` waited.

## Level 2: `mounted`

With both `if (!mounted) return;` removed, I opened the screen and pressed Back during the 2-second load:

```
setState() called after dispose(): _StudentsScreenState#161b7(lifecycle state: defunct, not mounted)
```

With the guards in place, the console shows only `fetchStudents #1`.

Empty state: with `FakeApi(empty: true)` the screen shows "No students yet", not a spinner.

## Level 3: FutureBuilder

The Future is stored in a field. Ten Switch flips print one `fetchStudents #1`, and no spinner appears.
With `future: _api.fetchStudents()` inline in `build`, four flips printed `fetchStudents #1` … `#6`. That is a new request on every rebuild, and `#3` failed with `NoConnectionException`.

Also caught: the handout's `setState(() => _future = _api.fetchStudents())` is an arrow function, so it returns the Future to `setState`. Flutter asserts on that: `setState() callback argument returned a Future.` `_retry` uses a block body instead.

## Level 4: countdown

- **B with `cancel()`:** Back at 7 → the last line is `tick 7`. Nothing after it.
- **B without `cancel()`:** Back at 7 → `setState() called after dispose(): _VersionBState#4f22b(lifecycle state: defunct, not mounted)` once per second, while the console keeps printing `tick 6`, `tick 5` … `tick 0` with no screen open. That is the leak.
- **A (StreamBuilder, no cancel in my code):** Back at 7 → the console stops at `tick 7`. `StreamBuilder` cancelled the subscription itself.

## Level 5: Save

The AI version, `onPressed: () { _api.save(n); Navigator.pop(context); }`:

- `flutter analyze` did **not** flag it with `unawaited_futures`. That rule only checks `async` bodies, and this closure is not `async`; the rule that catches it is `discarded_futures`. The only issue reported was `unused_element` for the now-unused `_save`.
- On the second save, the screen popped as if the save worked, and the console printed `Bad state: server rejected 6`.

**The user saw a success while the server said no.**

The honest version awaits inside `try`/`on StateError`, checks `context.mounted` after the `await`, pops only on success, and shows the message in a SnackBar. `_saving` disables the button and shows a spinner, so a quick double tap sends only one request. The save counter is `static` so the second save fails even after the first one popped the screen.

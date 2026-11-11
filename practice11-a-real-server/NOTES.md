# Notes: A Real Server

All responses below were copied from real `curl` calls to `jsonplaceholder.typicode.com` on 2026-11-11. The console lines come from `flutter run -d windows --dart-define=CHECKS=true` and `flutter test`.

## Level 1: the wire

`GET /users` → **200**, `Content-Type: application/json; charset=utf-8`, a JSON **list of 10** users.
`GET /users/1` → **200**, one object.

Keys: `id`, `name`, `username`, `email`, `address`, `phone`, `website`, `company`.
Nested once: `address`, `company`. Nested twice: `address.geo`.
None of the 10 users has a missing or null field. `website` is the one we treat as optional anyway (a profile without a site is normal). `company.bs` exists but we do not read it.

### User

| Field | JSON type | Dart type | Nullable? |
|---|---|---|---|
| `id` | number | `int` | no |
| `name` | string | `String` | no |
| `username` | string | `String` | no |
| `email` | string | `String` | no |
| `address` | object | `Address` | no |
| `phone` | string (`"1-770-736-8031 x56442"`) | `String` (+ `phoneDigits`) | no |
| `website` | string | `String?` | **yes** (our choice) |
| `company` | object | `({String name, String catchPhrase})` | no |

### address

| Field | JSON type | Dart type | Nullable? |
|---|---|---|---|
| `street` | string | `String` | no |
| `suite` | string | `String` | no |
| `city` | string | `String` | no |
| `zipcode` | string (`"92998-3874"`, not a number) | `String` | no |
| `geo.lat` | **string** (`"-37.3159"`) | `double` via `double.parse` | no |
| `geo.lng` | **string** (`"81.1496"`) | `double` via `double.parse` | no |

### company

| Field | JSON type | Dart type | Nullable? |
|---|---|---|---|
| `name` | string | `String` | no |
| `catchPhrase` | string | `String` | no |
| `bs` | string | not read | n/a |

### Statuses

- `GET /users/999` → **404 Not Found**, body `{}`. It is still valid JSON, so the status has to be checked before the body is read.
- `POST /users` with `Content-Type: application/json` and `{"name":"Amina","username":"amina","email":"a@kbtu.kz"}` → **201 Created**, `Location: …/users/11`. The body is what we sent plus `"id": 11`. A client-sent `"id": 0` is overwritten with 11. Nothing is actually stored.
- `GET /users?id=3` → **200**, a **list of one** `[ { "id": 3, … } ]`, not an object.

## Level 2: the model

```
User(1, Leanne Graham, Gwenborough) lat=-37.3159 digits=1770736803156442
```

I broke it on purpose (one run each, then reverted):

| Change | Throws |
|---|---|
| `json['lat'] as double` | `type 'String' is not a subtype of type 'double' in type cast` |
| `"id": "1"` in the pasted JSON | `type 'String' is not a subtype of type 'int' in type cast` |

The repository turns both into `BadResponseException('users/1: …')` (`test/api_test.dart`, "bad casts").

## Level 3: the repository

```
10 users: Leanne Graham, Ervin Howell, Clementine Bauch, Patricia Lebsack, Chelsey Dietrich, Mrs. Dennis Schulist, Kurtis Weissnat, Nicholas Runolfsdottir V, Glenna Reichert, Clementina DuBuque
not found
created id 11
```

```
$ grep -rn "package:http" lib/
lib/core/api/api_client.dart:6:import 'package:http/http.dart' as http;
lib/core/api/api_client.dart:11:export 'package:http/http.dart' show Client;
lib/features/users/user_repository.dart:3:import 'package:http/http.dart' as http;
```

`main.dart` builds the client as `ApiClient(Client())`. `Client` is re-exported from `api_client.dart`, so `main.dart` never imports `package:http` itself.

**Break it: `_check` forgets 404.** `getById(999)` decodes `{}` and `fromJson` fails on `id`: `type 'Null' is not a subtype of type 'int' in type cast`. The error is still ours (`BadResponseException`), but it says "bad JSON" when the real cause is "no such user". That is why the status is checked first.

## Level 4: the chain

- Deleting the `BadResponseException()` arm stops the build with "The type 'ApiException?' is not exhaustively matched…". The arm was put back.
- Host `jsonplaceholder.typicode.co` (typo): `SocketException` → `NoConnectionException` after **25–137 ms**. Fixing the host and pressing Retry loads the list without a restart.

## Level 5: two kinds of "no network"

| Case | Where | Time to the Offline view |
|---|---|---|
| No route (typo host, the same failure as airplane mode) | Windows, `test/live_test.dart` | **25–137 ms** |
| Packets leave, nothing returns (a socket that accepts and stays silent) | Windows, `test/live_test.dart` | **10 002 ms** |
| Airplane mode | phone | _TODO: measure_ |
| Hotspot with no internet | phone | _TODO: measure_ |

A `10.255.255.1` black hole is not a good test on this PC: Windows reports it unreachable after about 2 s. The local silent socket shows the real timeout.

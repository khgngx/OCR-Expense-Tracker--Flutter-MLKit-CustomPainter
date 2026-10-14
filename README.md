# OCR Expense Tracker

Flutter app that scans receipts on-device (Google ML Kit), parses them with a regex heuristic engine, lets you review/edit, stores them in SQLite, and visualizes spending with pure `CustomPainter` charts and a "daily bill stack".

## Architecture

Feature-first, 3 layers (Presentation / Domain / Data):

- `lib/core` – theme, colors, formatters, shared widgets
- `lib/domain` – `Receipt` model, use cases (parse, save, daily summary, weekly spending)
- `lib/data` – sqflite database + DAO, `ReceiptRepository`, thumbnail storage
- `lib/features/*` – `camera_scan`, `receipt_review`, `transaction_list`, `charts`, `bill_stack`

Features read data only through `ReceiptRepository`. Dependencies are wired by hand in `lib/main.dart` and exposed via `AppScope`.

## Run

```bash
flutter pub get
flutter run        # needs a physical device or emulator with a camera
flutter test
```

Requirements: Android minSdk 24, iOS 15.5+ (ML Kit).

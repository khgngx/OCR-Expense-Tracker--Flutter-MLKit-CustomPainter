import 'package:sqflite/sqflite.dart';

typedef Migration = Future<void> Function(Database db);

/// Index i holds the migration upgrading schema version i + 1 to i + 2.
/// Version 1 is created in AppDatabase._onCreate. Append only; never edit a
/// shipped migration.
const List<Migration> migrations = [];

int get latestSchemaVersion => migrations.length + 1;

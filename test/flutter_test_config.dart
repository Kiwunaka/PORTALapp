import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:sqlite3/open.dart' as sqlite_open;

const _sqliteDllCandidates = <String>[
  'build/windows/x64/runner/Release/sqlite3.dll',
  'build/windows/x64/plugins/sqlite3_flutter_libs/Release/sqlite3.dll',
  'dist/tmp/pokrov/sqlite3.dll',
];

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  _configureWindowsSqliteOverride();
  await testMain();
}

void _configureWindowsSqliteOverride() {
  if (!Platform.isWindows) {
    return;
  }

  final sqliteDll = _findSqliteDll();
  if (sqliteDll == null) {
    return;
  }

  sqlite_open.open.overrideFor(
    sqlite_open.OperatingSystem.windows,
    () => DynamicLibrary.open(sqliteDll.path),
  );
}

File? _findSqliteDll() {
  final projectRoot = Directory.current;
  for (final relativePath in _sqliteDllCandidates) {
    final candidate = File('${projectRoot.path}${Platform.pathSeparator}$relativePath');
    if (candidate.existsSync()) {
      return candidate;
    }
  }

  for (final entity
      in projectRoot.listSync(recursive: true, followLinks: false)) {
    if (entity is! File) {
      continue;
    }
    if (entity.path.toLowerCase().endsWith(
      '${Platform.pathSeparator}sqlite3.dll',
    )) {
      return entity;
    }
  }

  return null;
}

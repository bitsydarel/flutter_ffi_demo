import 'dart:ffi' as ffi;
import 'dart:typed_data';
import 'package:ffi/ffi.dart' as ffi_ext;
import 'package:flutter_ffi_demo/src/lmdb/lmdb_bindings.dart';
import 'dart:io';

import 'package:flutter_ffi_demo/src/lmdb/types.dart';

String _getLibraryPath(final String name) {
  if (Platform.isWindows) return 'lib$name.dll';
  // since on ios/mac we are building the library as a static library.
  // it's will be loaded at app's load time.
  if (Platform.isMacOS || Platform.isIOS) return '';
  return 'lib$name.so';
}

ffi.DynamicLibrary loadLMDB(final String libraryName) {
  try {
    return ffi.DynamicLibrary.open(_getLibraryPath(libraryName));
  } catch (e) {
    return ffi.DynamicLibrary.process();
  }
}

int createLMDBEnvironment(
  final LMDBBindings bindings,
  final ffi.Pointer<ffi.Pointer<MDB_env>> pointerToMdbEnv,
  final String environmentPath,
  final int maxDatabases,
  final int flags,
) {
  var result = bindings.mdb_env_create(pointerToMdbEnv);

  if (result != 0) return result;

  final ffi.Pointer<MDB_env> mdbEnv = pointerToMdbEnv.value;

  result = bindings.mdb_env_set_maxdbs(mdbEnv, maxDatabases);

  if (result != 0) return result;

  result = bindings.mdb_env_open(
    mdbEnv,
    ffi_ext.Utf8.toUtf8(environmentPath),
    flags,
    0664,
  );

  return result;
}

void fillPointer(Uint8List from, ffi.Pointer<ffi.Uint8> to) {
  for (var index = 0; index < from.length; index++) {
    to[index] = from[index];
  }
}

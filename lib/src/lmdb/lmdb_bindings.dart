import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart' as ffi_ext;
import 'package:flutter/foundation.dart';
import 'package:flutter_ffi_demo/src/lmdb/types.dart';
import 'package:flutter_ffi_demo/src/utils.dart';

typedef _native_mdb_env_create = ffi.IntPtr Function(
    ffi.Pointer<ffi.Pointer<MDB_env>>);

typedef _native_mdb_env_set_maxdbs = ffi.IntPtr Function(
    ffi.Pointer<MDB_env>, ffi.IntPtr);

typedef _native_mdb_env_open = ffi.IntPtr Function(
    ffi.Pointer<MDB_env>, ffi.Pointer<ffi_ext.Utf8>, ffi.IntPtr, ffi.IntPtr);

typedef _native_mdb_strerror = ffi.Pointer<ffi_ext.Utf8> Function(ffi.IntPtr);

typedef _native_mdb_txn_begin = ffi.IntPtr Function(ffi.Pointer<MDB_env>,
    ffi.Pointer<MDB_txn>, ffi.IntPtr, ffi.Pointer<ffi.Pointer<MDB_txn>>);

typedef _native_mdb_dbi_open = ffi.IntPtr Function(ffi.Pointer<MDB_txn>,
    ffi.Pointer<ffi_ext.Utf8>, ffi.IntPtr, ffi.Pointer<ffi.IntPtr>);

typedef _native_mdb_env_close = ffi.Void Function(ffi.Pointer<MDB_env>);

typedef _native_mdb_env_sync = ffi.IntPtr Function(
    ffi.Pointer<MDB_env>, ffi.IntPtr);

typedef _native_mdb_put = ffi.IntPtr Function(ffi.Pointer<MDB_txn>, ffi.IntPtr,
    ffi.Pointer<MDB_val>, ffi.Pointer<MDB_val>, ffi.IntPtr);

typedef _native_mdb_get = ffi.IntPtr Function(ffi.Pointer<MDB_txn>, ffi.IntPtr,
    ffi.Pointer<MDB_val>, ffi.Pointer<MDB_val>);

typedef _native_mdb_cursor_open = ffi.IntPtr Function(
    ffi.Pointer<MDB_txn>, ffi.IntPtr, ffi.Pointer<ffi.Pointer<MDB_cursor>>);

typedef _native_mdb_cursor_get = ffi.IntPtr Function(ffi.Pointer<MDB_cursor>,
    ffi.Pointer<MDB_val>, ffi.Pointer<MDB_val>, ffi.IntPtr);

typedef _native_mdb_cursor_close = ffi.Void Function(ffi.Pointer<MDB_cursor>);

typedef _native_mdb_txn_commit = ffi.IntPtr Function(ffi.Pointer<MDB_txn>);

class LMDBBindings {
  static LMDBBindings _binding;

  final int Function(ffi.Pointer<ffi.Pointer<MDB_env>>) mdb_env_create;

  final int Function(ffi.Pointer<MDB_env>, int) mdb_env_set_maxdbs;

  final ffi.Pointer<ffi_ext.Utf8> Function(int) mdb_strerror;

  final int Function(
    ffi.Pointer<MDB_env>,
    ffi.Pointer<ffi_ext.Utf8>,
    int,
    int,
  ) mdb_env_open;

  final int Function(
    ffi.Pointer<MDB_env>,
    ffi.Pointer<MDB_txn>,
    int,
    ffi.Pointer<ffi.Pointer<MDB_txn>>,
  ) mdb_txn_begin;

  final int Function(
    ffi.Pointer<MDB_txn>,
    ffi.Pointer<ffi_ext.Utf8>,
    int,
    ffi.Pointer<ffi.IntPtr>,
  ) mdb_dbi_open;

  final int Function(
    ffi.Pointer<MDB_txn>,
    int,
    ffi.Pointer<MDB_val>,
    ffi.Pointer<MDB_val>,
    int,
  ) mdb_put;

  final int Function(
    ffi.Pointer<MDB_txn>,
    int,
    ffi.Pointer<MDB_val>,
    ffi.Pointer<MDB_val>,
  ) mdb_get;

  final int Function(
    ffi.Pointer<MDB_txn>,
    int,
    ffi.Pointer<ffi.Pointer<MDB_cursor>>,
  ) mdb_cursor_open;

  final int Function(
    ffi.Pointer<MDB_cursor>,
    ffi.Pointer<MDB_val>,
    ffi.Pointer<MDB_val>,
    int,
  ) mdb_cursor_get;

  final void Function(ffi.Pointer<MDB_cursor>) mdb_cursor_close;

  final int Function(ffi.Pointer<MDB_txn>) mdb_txn_commit;

  final int Function(ffi.Pointer<MDB_env>, int) mdb_env_sync;

  final void Function(ffi.Pointer<MDB_env>) mdb_env_close;

  factory LMDBBindings() {
    if (_binding == null) {
      final ffi.DynamicLibrary lmdb = loadLMDB("lmdb");

      _binding = LMDBBindings._(
        mdb_env_create: lmdb
            .lookup<ffi.NativeFunction<_native_mdb_env_create>>(
              "mdb_env_create",
            )
            .asFunction(),
        mdb_env_set_maxdbs: lmdb
            .lookup<ffi.NativeFunction<_native_mdb_env_set_maxdbs>>(
              "mdb_env_set_maxdbs",
            )
            .asFunction(),
        mdb_env_open: lmdb
            .lookup<ffi.NativeFunction<_native_mdb_env_open>>("mdb_env_open")
            .asFunction(),
        mdb_strerror: lmdb
            .lookup<ffi.NativeFunction<_native_mdb_strerror>>("mdb_strerror")
            .asFunction(),
        mdb_txn_begin: lmdb
            .lookup<ffi.NativeFunction<_native_mdb_txn_begin>>("mdb_txn_begin")
            .asFunction(),
        mdb_dbi_open: lmdb
            .lookup<ffi.NativeFunction<_native_mdb_dbi_open>>("mdb_dbi_open")
            .asFunction(),
        mdb_put: lmdb
            .lookup<ffi.NativeFunction<_native_mdb_put>>("mdb_put")
            .asFunction(),
        mdb_get: lmdb
            .lookup<ffi.NativeFunction<_native_mdb_get>>("mdb_get")
            .asFunction(),
        mdb_cursor_open: lmdb
            .lookup<ffi.NativeFunction<_native_mdb_cursor_open>>(
                "mdb_cursor_open")
            .asFunction(),
        mdb_cursor_get: lmdb
            .lookup<ffi.NativeFunction<_native_mdb_cursor_get>>(
                "mdb_cursor_get")
            .asFunction(),
        mdb_cursor_close: lmdb
            .lookup<ffi.NativeFunction<_native_mdb_cursor_close>>(
                "mdb_cursor_close")
            .asFunction(),
        mdb_txn_commit: lmdb
            .lookup<ffi.NativeFunction<_native_mdb_txn_commit>>(
                "mdb_txn_commit")
            .asFunction(),
        mdb_env_sync: lmdb
            .lookup<ffi.NativeFunction<_native_mdb_env_sync>>("mdb_env_sync")
            .asFunction(),
        mdb_env_close: lmdb
            .lookup<ffi.NativeFunction<_native_mdb_env_close>>("mdb_env_close")
            .asFunction(),
      );
    }

    return _binding;
  }

  LMDBBindings._({
    @required this.mdb_env_create,
    @required this.mdb_env_set_maxdbs,
    @required this.mdb_env_open,
    @required this.mdb_strerror,
    @required this.mdb_txn_begin,
    @required this.mdb_dbi_open,
    @required this.mdb_put,
    @required this.mdb_get,
    @required this.mdb_cursor_open,
    @required this.mdb_cursor_get,
    @required this.mdb_cursor_close,
    @required this.mdb_txn_commit,
    @required this.mdb_env_sync,
    @required this.mdb_env_close,
  })  : assert(mdb_env_create != null),
        assert(mdb_env_set_maxdbs != null),
        assert(mdb_env_open != null),
        assert(mdb_strerror != null),
        assert(mdb_txn_begin != null),
        assert(mdb_dbi_open != null),
        assert(mdb_put != null),
        assert(mdb_get != null),
        assert(mdb_cursor_open != null),
        assert(mdb_txn_commit != null),
        assert(mdb_env_sync != null),
        assert(mdb_env_close != null);
}

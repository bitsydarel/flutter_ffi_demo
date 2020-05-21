import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart' as ffi_ext;
import 'package:flutter_ffi_demo/src/lmdb/transformers.dart';
import 'package:flutter_ffi_demo/src/lmdb/lmdb_bindings.dart';
import 'package:flutter_ffi_demo/src/lmdb/types.dart';
import 'package:flutter_ffi_demo/src/task.dart';
import 'package:msgpack_dart/msgpack_dart.dart';
import '../utils.dart';

final ffi.DynamicLibrary lmdb = loadLMDB("lmdb");

/// Error code: INVALID_DATA
///
/// The user didn't have permission to access the environment files.
const int EACCES = 13;

///
const int MDB_CREATE = 0x40000;
const int MDB_RDONLY = 0x20000;
const int MDB_NOSUBDIR = 0x4000;
const int MDB_NOLOCK = 0x400000;

void throwIfError(final int errorCode) {
  if (errorCode != 0) {
    print("error code number $errorCode");
    final errorCodeMessage =
        ffi_ext.Utf8.fromUtf8(LMDBBindings().mdb_strerror(errorCode));
    print("error message: $errorCodeMessage");
    throw LMDBException(errorCodeMessage);
  }
}

class LMDBEnvironment {
  static final _environments = Map<String, LMDBEnvironment>();

  factory LMDBEnvironment.open(
    final String environmentPath,
    final int maxDbInEnvironment,
  ) {
    print("dir path: $environmentPath");

    LMDBEnvironment environment = _environments[environmentPath];

    if (environment == null) {
      final bindings = LMDBBindings();

      ffi.Pointer<ffi.Pointer<MDB_env>> pointerToMdbEnv = ffi_ext.allocate();

      final errorCode = createLMDBEnvironment(
        bindings,
        pointerToMdbEnv,
        environmentPath,
        maxDbInEnvironment,
        MDB_CREATE | MDB_NOSUBDIR,
      );

      /// If environment file cannot be accessed by the current user.
      ///
      /// Meaning lock file cannot be accessed.
      if (errorCode == EACCES) {
        bindings.mdb_env_close(pointerToMdbEnv.value);

        /// try to open the environment with NO_LOCK flag.
        throwIfError(createLMDBEnvironment(
          bindings,
          pointerToMdbEnv,
          environmentPath,
          maxDbInEnvironment,
          MDB_CREATE | MDB_NOLOCK | MDB_NOSUBDIR,
        ));
      }

      environment = LMDBEnvironment._(environmentPath, pointerToMdbEnv.value);

      _environments[environmentPath] = environment;
    }

    return environment;
  }

  final String _path;
  final ffi.Pointer<MDB_env> _mdbEnv;
  ffi.Pointer<ffi.IntPtr> _mdbDbi;
  bool _isClosed = false;

  LMDBEnvironment._(this._path, this._mdbEnv);

  Task getTask(final String key) {
    _checkIfUsable();

    Task result;

    _runInTransaction((bindings, transaction, database) {
      final binaryKey = serialize(key, extEncoder: lmdbEncoder);
      final ffi.Pointer<MDB_val> valuePointer = ffi_ext.allocate<MDB_val>();

      throwIfError(
        bindings.mdb_get(
          transaction,
          database.value,
          MDB_val.fromBinary(binaryKey).addressOf,
          valuePointer,
        ),
      );

      result = _pointerToTask(valuePointer);
    }, isReadOnly: true);

    return result;
  }

  void putTask(final String key, final Task task) {
    _checkIfUsable();

    _runInTransaction(
      (bindings, transaction, database) {
        final binaryKey = serialize(key, extEncoder: lmdbEncoder);
        final binaryValue = serialize(task, extEncoder: lmdbEncoder);

        throwIfError(
          bindings.mdb_put(
            transaction,
            database.value,
            MDB_val.fromBinary(binaryKey).addressOf,
            MDB_val.fromBinary(binaryValue).addressOf,
            0,
          ),
        );
      },
    );
  }

  List<Task> getAllTasks() {
    _checkIfUsable();

    final tasks = <Task>[];

    _runInTransaction(
      (bindings, transaction, database) {
        final ffi.Pointer<ffi.Pointer<MDB_cursor>> cursor = ffi_ext.allocate();

        throwIfError(
          bindings.mdb_cursor_open(transaction, database.value, cursor),
        );

        final ffi.Pointer<MDB_val> key = ffi_ext.allocate();
        final ffi.Pointer<MDB_val> value = ffi_ext.allocate();

        if (bindings.mdb_cursor_get(
              cursor.value,
              key,
              value,
              MDB_cursor_op.MDB_FIRST.index,
            ) ==
            0) {
          tasks.add(_pointerToTask(value));

          while (bindings.mdb_cursor_get(
                cursor.value,
                key,
                value,
                MDB_cursor_op.MDB_NEXT.index,
              ) ==
              0) {
            tasks.add(_pointerToTask(value));
          }
        }

        bindings.mdb_cursor_close(cursor.value);
      },
      isReadOnly: true,
    );

    return tasks;
  }

  void close() {
    if (_isClosed) return;
    final bindings = LMDBBindings();

    throwIfError(bindings.mdb_env_sync(_mdbEnv, 1));

    LMDBBindings().mdb_env_close(_mdbEnv);

    _environments.remove(_path);

    _isClosed = true;

    print("environment at $_path is closed.");
  }

  bool isOpen() => !_isClosed;

  void _checkIfUsable() {
    if (_isClosed) throw LMDBException("Environment is already closed");
  }

  void _runInTransaction(
    void Function(LMDBBindings, ffi.Pointer<MDB_txn>, ffi.Pointer<ffi.IntPtr>)
        block, {
    bool isReadOnly = false,
  }) {
    final bindings = LMDBBindings();

    final ffi.Pointer<ffi.Pointer<MDB_txn>> pointerToTransaction =
        ffi_ext.allocate();

    throwIfError(
      bindings.mdb_txn_begin(
        _mdbEnv,
        ffi.nullptr,
        isReadOnly ? MDB_RDONLY : 0,
        pointerToTransaction,
      ),
    );

    final transaction = pointerToTransaction.value;

    if (_mdbDbi?.value == null) {
      _mdbDbi = ffi_ext.allocate();

      throwIfError(
        bindings.mdb_dbi_open(
          transaction,
          ffi_ext.Utf8.toUtf8("tasks"),
          MDB_CREATE,
          _mdbDbi,
        ),
      );
    }

    block(bindings, transaction, _mdbDbi);

    throwIfError(bindings.mdb_txn_commit(transaction));
  }

  Task _pointerToTask(ffi.Pointer<MDB_val> pointer) {
    final dataInBytes =
        pointer.ref.mv_data.cast<ffi.Uint8>().asTypedList(pointer.ref.mv_size);

    return deserialize(
      dataInBytes,
      extDecoder: lmdbDecoder,
    );
  }
}

class LMDBException implements Exception {
  final String message;

  const LMDBException(this.message);

  @override
  String toString() => 'LMDBException $message';
}

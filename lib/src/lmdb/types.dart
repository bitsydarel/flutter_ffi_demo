import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter_ffi_demo/src/utils.dart';

class MDB_env extends Struct {}

class MDB_txn extends Struct {}

class MDB_val extends Struct {
  @IntPtr()
  int mv_size;

  Pointer<Void> mv_data;

  factory MDB_val.allocate(int mv_size, Pointer<Void> mv_data) =>
      allocate<MDB_val>().ref
        ..mv_size = mv_size
        ..mv_data = mv_data;

  factory MDB_val.fromBinary(Uint8List binary) {
    final Pointer<Uint8> keyData = allocate<Uint8>(
      count: binary.length,
    );

    fillPointer(binary, keyData);

    return MDB_val.allocate(
      binary.length * sizeOf<Uint8>(),
      keyData.cast(),
    );
  }
}

class MDB_cursor extends Struct {}

enum MDB_cursor_op {
  /// Position at first key/data item
  MDB_FIRST,

  /// Position at first data item of current key. Only for #MDB_DUPSORT
  MDB_FIRST_DUP,

  /// Position at key/data pair. Only for #MDB_DUPSORT
  MDB_GET_BOTH,

  /// position at key, nearest data. Only for #MDB_DUPSORT
  MDB_GET_BOTH_RANGE,

  /// Return key/data at current cursor position.
  MDB_GET_CURRENT,

  /// Return up to a page of duplicate data items
  /// from current cursor position. Move cursor to prepare
  /// for #MDB_NEXT_MULTIPLE. Only for #MDB_DUPFIXED
  MDB_GET_MULTIPLE,

  /// Position at last key/data item.
  MDB_LAST,

  /// Position at last data item of current key. Only for #MDB_DUPSORT
  MDB_LAST_DUP,

  /// Position at next data item.
  MDB_NEXT,

  /// Position at next data item of current key. Only for #MDB_DUPSORT
  MDB_NEXT_DUP,

  /// Return up to a page of duplicate data items
  /// from next cursor position. Move cursor to prepare
  /// for #MDB_NEXT_MULTIPLE. Only for #MDB_DUPFIXED
  MDB_NEXT_MULTIPLE,

  /// Position at first data item of next key.
  MDB_NEXT_NODUP,

  /// Position at previous data item.
  MDB_PREV,

  /// Position at previous data item of current key.
  /// Only for #MDB_DUPSORT
  MDB_PREV_DUP,

  /// Position at last data item of previous key.
  MDB_PREV_NODUP,

  /// Position at specified key.
  MDB_SET,

  /// Position at specified key, return key + data.
  MDB_SET_KEY,

  /// Position at first key greater than or equal to specified key.
  MDB_SET_RANGE,

  /// Position at previous page and return up to
  /// a page of duplicate data items. Only for #MDB_DUPFIXED
  MDB_PREV_MULTIPLE
}

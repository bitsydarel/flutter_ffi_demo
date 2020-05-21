import 'dart:typed_data';

import 'package:flutter_ffi_demo/src/task.dart';
import 'package:msgpack_dart/msgpack_dart.dart';

final lmdbEncoder = LMDBEncoder();
final lmdbDecoder = LMBDDecoder();

const int _TASK_TYPE = 0;

class LMDBEncoder extends ExtEncoder {
  @override
  Uint8List encodeObject(object) {
    if (object is Task) {
      final map = Map<String, dynamic>();
      map["id"] = object.id;
      map["name"] = object.name;
      map["deadline"] = object.deadline.millisecondsSinceEpoch;
      return serialize(map);
    }
    return null;
  }

  @override
  int extTypeForObject(object) {
    if (object is Task) {
      return _TASK_TYPE;
    }
    return null;
  }
}

class LMBDDecoder extends ExtDecoder {
  @override
  dynamic decodeObject(int extType, Uint8List data) {
    if (extType == _TASK_TYPE) {
      final Map converted = deserialize(data);

      return Task(
        converted["id"],
        converted["name"],
        DateTime.fromMillisecondsSinceEpoch(converted["deadline"]),
      );
    }
    return deserialize(data);
  }
}

import 'dart:typed_data';

/// Binary Protobuf payload for model coefficients.
///
/// Field mapping:
/// 1 -> b0 (double, fixed64)
/// 2 -> b1 (double, fixed64)
/// 3 -> b2 (double, fixed64)
/// 4 -> updated_at_epoch_ms (int64, varint)
class BiomechanicsCoefficientsProtobuf {
  const BiomechanicsCoefficientsProtobuf({
    required this.b0,
    required this.b1,
    required this.b2,
    required this.updatedAtEpochMs,
  });

  final double b0;
  final double b1;
  final double b2;
  final int updatedAtEpochMs;

  Uint8List encode() {
    final bytes = BytesBuilder(copy: false);

    _writeFixed64Field(bytes, 1, b0);
    _writeFixed64Field(bytes, 2, b1);
    _writeFixed64Field(bytes, 3, b2);
    _writeVarintField(bytes, 4, updatedAtEpochMs);

    return bytes.toBytes();
  }

  static BiomechanicsCoefficientsProtobuf? decode(Uint8List data) {
    var offset = 0;
    double? b0;
    double? b1;
    double? b2;
    int? updatedAtEpochMs;

    while (offset < data.length) {
      final tagResult = _readVarint(data, offset);
      if (tagResult == null) return null;
      final tag = tagResult.$1;
      offset = tagResult.$2;

      final fieldNumber = tag >> 3;
      final wireType = tag & 0x07;

      if (fieldNumber == 1) {
        if (wireType != 1 || offset + 8 > data.length) return null;
        b0 = ByteData.sublistView(
          data,
          offset,
          offset + 8,
        ).getFloat64(0, Endian.little);
        offset += 8;
        continue;
      }
      if (fieldNumber == 2) {
        if (wireType != 1 || offset + 8 > data.length) return null;
        b1 = ByteData.sublistView(
          data,
          offset,
          offset + 8,
        ).getFloat64(0, Endian.little);
        offset += 8;
        continue;
      }
      if (fieldNumber == 3) {
        if (wireType != 1 || offset + 8 > data.length) return null;
        b2 = ByteData.sublistView(
          data,
          offset,
          offset + 8,
        ).getFloat64(0, Endian.little);
        offset += 8;
        continue;
      }
      if (fieldNumber == 4) {
        if (wireType != 0) return null;
        final value = _readVarint(data, offset);
        if (value == null) return null;
        updatedAtEpochMs = value.$1;
        offset = value.$2;
        continue;
      }

      final skipped = _skipUnknown(wireType, data, offset);
      if (skipped == null) return null;
      offset = skipped;
    }

    if (b0 == null || b1 == null || b2 == null || updatedAtEpochMs == null) {
      return null;
    }

    return BiomechanicsCoefficientsProtobuf(
      b0: b0,
      b1: b1,
      b2: b2,
      updatedAtEpochMs: updatedAtEpochMs,
    );
  }

  static void _writeFixed64Field(
    BytesBuilder bytes,
    int fieldNumber,
    double value,
  ) {
    _writeVarint(bytes, (fieldNumber << 3) | 1);
    final b = ByteData(8)..setFloat64(0, value, Endian.little);
    bytes.add(b.buffer.asUint8List());
  }

  static void _writeVarintField(
    BytesBuilder bytes,
    int fieldNumber,
    int value,
  ) {
    _writeVarint(bytes, fieldNumber << 3);
    _writeVarint(bytes, value);
  }

  static void _writeVarint(BytesBuilder bytes, int value) {
    var current = value;
    while ((current & ~0x7F) != 0) {
      bytes.add(<int>[(current & 0x7F) | 0x80]);
      current = current >> 7;
    }
    bytes.add(<int>[current & 0x7F]);
  }

  static (int, int)? _readVarint(Uint8List data, int start) {
    var result = 0;
    var shift = 0;
    var offset = start;

    while (offset < data.length && shift < 64) {
      final byte = data[offset++];
      result |= (byte & 0x7F) << shift;
      if ((byte & 0x80) == 0) {
        return (result, offset);
      }
      shift += 7;
    }
    return null;
  }

  static int? _skipUnknown(int wireType, Uint8List data, int offset) {
    switch (wireType) {
      case 0:
        final parsed = _readVarint(data, offset);
        return parsed?.$2;
      case 1:
        return offset + 8 <= data.length ? offset + 8 : null;
      case 2:
        final lenResult = _readVarint(data, offset);
        if (lenResult == null) return null;
        final length = lenResult.$1;
        final next = lenResult.$2 + length;
        return next <= data.length ? next : null;
      case 5:
        return offset + 4 <= data.length ? offset + 4 : null;
      default:
        return null;
    }
  }
}

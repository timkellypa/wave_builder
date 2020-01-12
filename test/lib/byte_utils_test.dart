import 'package:test/test.dart';
import 'package:wave_builder/src/lib/byte_utils.dart';

void main() {
  group('ByteUtils', () {
    group('#numberAsByteList', () {
      test('it returns 2 byte number properly', () {
        var testVal = 258;
        expect(ByteUtils.numberAsByteList(testVal, 2), [1, 2]);
      });

      test('it returns padded 4 byte number properly', () {
        var testVal = 65538;
        expect(ByteUtils.numberAsByteList(testVal, 4), [0, 1, 0, 2]);
      });

      test('it works for little endian', () {
        var testVal = 65538;
        expect(ByteUtils.numberAsByteList(testVal, 4, bigEndian: false),
            [2, 0, 1, 0]);
      });
    });

    group('#findByteSequenceInList', () {
      test('it finds a sequence in a list and returns the index', () {
        var list = <int>[5, 4, 3, 8, 8, 6, 7, 5, 3, 0, 9, 8];
        var sequence = <int>[8, 6, 7, 5, 3, 0, 9];
        expect(ByteUtils.findByteSequenceInList(sequence, list), 4);
      });

      test(
          'it returns -1 if sequence not found (does not err on index overflow)',
          () {
        var list = <int>[5, 4, 3, 8, 8, 6, 7, 5, 3, 0, 9, 8];
        var sequence = <int>[8, 6, 7, 5, 3, 0, 8];
        expect(ByteUtils.findByteSequenceInList(sequence, list), -1);
      });
    });
  });
}

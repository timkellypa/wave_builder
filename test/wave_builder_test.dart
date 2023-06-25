import 'package:wave_builder/src/lib/byte_utils.dart';
import 'package:wave_builder/wave_builder.dart';
import 'package:test/test.dart';

const int SAMPLE_SIZE = 4;
const int BIT_RATE = 16;
const int FREQUENCY = 44100;

const int RIFF_CHUNK_SIZE_INDEX = 4;
const int SUB_CHUNK_SIZE = 16;
const int AUDIO_FORMAT = 1;
const int BYTE_SIZE = 8;

// 2 for stereo
const int NUM_CHANNELS = 2;

void main() {
  group('WaveBuilder', () {
    var waveBuilder = WaveBuilder();
    setUp(() {
      waveBuilder = WaveBuilder();
    });

    group('#constructor', () {
      test('it initializes outputBytes and initializes chunks', () {
        expect(waveBuilder.fileBytes.length, 44);
      });

      test('it adds RIFF chunk', () {
        var riff = 'RIFF'.codeUnits;
        expect(waveBuilder.fileBytes.getRange(0, 4), riff);
        var wave = 'WAVE'.codeUnits;

        // do not test length here, because it is already calculated as non-zero
        // (file length minus this section)

        expect(waveBuilder.fileBytes.getRange(8, 12), wave);
      });

      test('it adds format chunk', () {
        var byteRate = FREQUENCY * NUM_CHANNELS * BIT_RATE ~/ BYTE_SIZE,
            blockAlign = NUM_CHANNELS * BIT_RATE ~/ 8,
            bitsPerSample = BIT_RATE;

        var fmt = 'fmt '.codeUnits;
        expect(waveBuilder.fileBytes.getRange(12, 16), fmt);
        expect(waveBuilder.fileBytes.getRange(16, 20),
            ByteUtils.numberAsByteList(SUB_CHUNK_SIZE, 4, bigEndian: false));

        expect(waveBuilder.fileBytes.getRange(20, 22),
            ByteUtils.numberAsByteList(AUDIO_FORMAT, 2, bigEndian: false));

        expect(waveBuilder.fileBytes.getRange(22, 24),
            ByteUtils.numberAsByteList(NUM_CHANNELS, 2, bigEndian: false));

        expect(waveBuilder.fileBytes.getRange(24, 28),
            ByteUtils.numberAsByteList(FREQUENCY, 4, bigEndian: false));

        expect(waveBuilder.fileBytes.getRange(28, 32),
            ByteUtils.numberAsByteList(byteRate, 4, bigEndian: false));

        expect(waveBuilder.fileBytes.getRange(32, 34),
            ByteUtils.numberAsByteList(blockAlign, 2, bigEndian: false));

        expect(waveBuilder.fileBytes.getRange(34, 36),
            ByteUtils.numberAsByteList(bitsPerSample, 2, bigEndian: false));
      });

      test('it adds data chunk', () {
        var data = 'data'.codeUnits;
        expect(waveBuilder.fileBytes.getRange(36, 40), data);
        expect(waveBuilder.fileBytes.getRange(40, 44), [0, 0, 0, 0]);
      });
    });

    group('#appendFileContents', () {
      test('it appends file contents after "data" string', () {
        var testNewFile = [1, 1, 1];
        testNewFile.addAll('data'.codeUnits);

        // size chunk
        testNewFile.addAll([0, 0, 0, 4]);

        testNewFile.addAll([1, 2, 3, 4]);
        waveBuilder.appendFileContents(testNewFile);
        expect(waveBuilder.fileBytes.getRange(44, 48), [1, 2, 3, 4]);
      });

      test('it appends all file contents if data string does not exist', () {
        var testNewFile = [1, 1, 1, 2];
        waveBuilder.appendFileContents(testNewFile);
        expect(waveBuilder.fileBytes.getRange(44, 48), [1, 1, 1, 2]);
      });
    });

    group('#appendSilence', () {
      group('End of last sample', () {
        test('it adds 0s for appropriate length (when appended to end)', () {
          var testNewFile = [1, 1, 1, 2];
          var byteRate = FREQUENCY * BIT_RATE ~/ 8;
          var silenceLength = byteRate * NUM_CHANNELS;
          waveBuilder.appendFileContents(testNewFile);
          waveBuilder.appendSilence(
              1000, WaveBuilderSilenceType.EndOfLastSample);
          expect(waveBuilder.fileBytes.getRange(44, 48), [1, 1, 1, 2]);
          expect(waveBuilder.fileBytes[49], 0);
          expect(waveBuilder.fileBytes[48 + silenceLength - 1], 0);
          expect(waveBuilder.fileBytes.length, 48 + silenceLength);
        });
      });

      group('Beginning of last sample', () {
        test('it adds 0s for length minus last sample size', () {
          var testNewFile = [1, 1, 1, 2];
          var byteRate = FREQUENCY * BIT_RATE ~/ 8;
          var silenceLength = byteRate * NUM_CHANNELS;
          waveBuilder.appendFileContents(testNewFile);
          waveBuilder.appendSilence(
              1000, WaveBuilderSilenceType.BeginningOfLastSample);
          expect(waveBuilder.fileBytes.getRange(44, 48), [1, 1, 1, 2]);
          expect(waveBuilder.fileBytes[49], 0);
          expect(waveBuilder.fileBytes[48 + silenceLength - 4 - 1], 0);
          expect(waveBuilder.fileBytes.length, 48 + silenceLength - 4);
        });
        test(
            'it truncates last sample appropriately if silence is less than last sample size',
            () {
          var byteRate = FREQUENCY * BIT_RATE ~/ 8;
          var silenceLength = byteRate * NUM_CHANNELS;
          var testNewFile = List<int>.filled(silenceLength + 4, 1);
          waveBuilder.appendFileContents(testNewFile);
          waveBuilder.appendSilence(
              1000, WaveBuilderSilenceType.BeginningOfLastSample);
          expect(waveBuilder.fileBytes.length, 44 + silenceLength);
          expect(waveBuilder.fileBytes[48 + 1], 1);
          expect(waveBuilder.fileBytes[testNewFile.length - 1], 1);
        });
      });
    });

    group('#finalize', () {
      test('it updates riff chunk size', () {
        // finalize is called for every fileBytes getter
        waveBuilder.appendFileContents(<int>[1, 2, 3, 4]);
        expect(waveBuilder.fileBytes[RIFF_CHUNK_SIZE_INDEX], 40);
      });

      test('it updates data chunk size', () {
        waveBuilder.appendFileContents(<int>[1, 2, 3, 4]);
        expect(waveBuilder.fileBytes[40], 4);
      });
    });

    group('#findDataChunk', () {
      test('it finds the data chunk (list contents after "data" + size)', () {
        var testNewFile = [1, 1, 1];
        testNewFile.addAll('data'.codeUnits);

        // size chunk
        testNewFile.addAll([0, 0, 0, 4]);

        testNewFile.addAll([1, 2, 3, 4]);

        expect(waveBuilder.getDataChunk(testNewFile), [1, 2, 3, 4]);
      });
    });
  });
}

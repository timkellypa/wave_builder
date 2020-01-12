A builder for Wave files.  This utility can create the byte list to write a wave file,
concatenating other wave files and periods of silence.

This utility is designed specifically to make metronome files (click tracks), but can be used for other applications as well.

Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).

## Usage

A simple usage example:

```dart
import 'package:wave_builder/wave_builder.dart';

/// Create 1 bar of a 4/4 metronome at 60 BPM
main() {
  var fileOut = File('./example/assets/out/test.wav');
  var primary = File('./example/assets/wav/primary.wav');
  var secondary = File('./example/assets/wav/secondary.wav');
  var silenceType = WaveBuilderSilenceType.BeginningOfLastSample;

  var primaryBytes = await primary.readAsBytes();
  var secondaryBytes = await secondary.readAsBytes();

  await fileOut.create();

  var waveBuilder = WaveBuilder();

  waveBuilder.appendFileContents(primaryBytes);
  waveBuilder.appendSilence(1000, silenceType);
  waveBuilder.appendFileContents(secondaryBytes);
  waveBuilder.appendSilence(1000, silenceType);
  waveBuilder.appendFileContents(secondaryBytes);
  waveBuilder.appendSilence(1000, silenceType);
  waveBuilder.appendFileContents(secondaryBytes);
  waveBuilder.appendSilence(1000, silenceType);
  await fileOut.writeAsBytes(waveBuilder.fileBytes);
}
```

import 'dart:io';

import 'package:wave_builder/wave_builder.dart';

Future<void> main() async {
  var fileOut = File('./example/assets/out/test.wav');
  var primary = File('./example/assets/wav/primary.wav');
  var secondary = File('./example/assets/wav/secondary.wav');
  var silenceType = WaveBuilderSilenceType.BeginningOfLastSample;

  var primaryBytes = await primary.readAsBytes();
  var secondaryBytes = await secondary.readAsBytes();

  if (await fileOut.exists()) {
    await fileOut.delete();
  }

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

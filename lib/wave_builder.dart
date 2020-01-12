/// Utility for constructing a wave file by passing in files (read as bytes) and periods of silence.
/// This is designed to build metronome audio files but can be used for other applications where simple
/// wave files need to be concatenated with areas of silence.
library wave_builder;

export 'src/wave_builder_base.dart';

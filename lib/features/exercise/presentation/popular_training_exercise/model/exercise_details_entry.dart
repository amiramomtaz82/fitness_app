import 'package:equatable/equatable.dart';

sealed class ExerciseDetailsEntry extends Equatable {
  final String labelKey;

  const ExerciseDetailsEntry({required this.labelKey});

  @override
  List<Object?> get props => [labelKey];
}

final class ExerciseDetailsTextEntry extends ExerciseDetailsEntry {
  final String? value;

  const ExerciseDetailsTextEntry({required super.labelKey, this.value});

  @override
  List<Object?> get props => [labelKey, value];
}

final class ExerciseDetailsVideoEntry extends ExerciseDetailsEntry {
  final String? videoUrl;

  const ExerciseDetailsVideoEntry({required super.labelKey, this.videoUrl});

  @override
  List<Object?> get props => [labelKey, videoUrl];
}

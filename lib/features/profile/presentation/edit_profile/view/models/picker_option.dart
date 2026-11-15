import 'package:equatable/equatable.dart';

class PickerOption extends Equatable {
  final String label;
  final String value;

  const PickerOption({required this.label, required this.value});

  @override
  List<Object> get props => [label, value];
}

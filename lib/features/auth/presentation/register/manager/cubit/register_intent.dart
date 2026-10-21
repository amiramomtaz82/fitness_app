import '../../registration_options.dart';

sealed class RegisterIntent {
  const RegisterIntent();
}

final class TogglePasswordVisibilityIntent extends RegisterIntent {
  const TogglePasswordVisibilityIntent();
}

final class SelectGenderIntent extends RegisterIntent {
  final String gender;

  const SelectGenderIntent(this.gender);
}

final class SelectAgeIntent extends RegisterIntent {
  final int age;

  const SelectAgeIntent(this.age);
}

final class SelectWeightIntent extends RegisterIntent {
  final num weight;

  const SelectWeightIntent(this.weight);
}

final class SelectHeightIntent extends RegisterIntent {
  final num height;

  const SelectHeightIntent(this.height);
}

final class SelectGoalIntent extends RegisterIntent {
  final RegistrationGoal goal;
  final String label;

  const SelectGoalIntent(this.goal, this.label);
}

final class SelectActivityIntent extends RegisterIntent {
  final RegistrationActivity activity;
  final String label;

  const SelectActivityIntent(this.activity, this.label);
}

final class NextStepIntent extends RegisterIntent {
  const NextStepIntent();
}

final class GoBackIntent extends RegisterIntent {
  const GoBackIntent();
}

final class SubmitRegistrationIntent extends RegisterIntent {
  const SubmitRegistrationIntent();
}

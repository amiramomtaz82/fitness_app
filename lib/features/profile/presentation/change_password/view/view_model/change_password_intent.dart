import 'change_password_field.dart';

sealed class ChangePasswordIntent {
  const ChangePasswordIntent();
}

final class UpdatePasswordFieldIntent extends ChangePasswordIntent {
  final ChangePasswordField field;
  final String value;

  const UpdatePasswordFieldIntent(this.field, this.value);
}

final class SubmitChangePasswordIntent extends ChangePasswordIntent {
  const SubmitChangePasswordIntent();
}

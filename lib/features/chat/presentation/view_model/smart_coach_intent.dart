import '../../domain/entites/chat_entities/chat_session_entity.dart';

sealed class SmartCoachIntent {
  const SmartCoachIntent();
}

class LoadCoachIntent extends SmartCoachIntent {
  const LoadCoachIntent();
}

class GetStartedIntent extends SmartCoachIntent {
  const GetStartedIntent();
}

class SendMessageIntent extends SmartCoachIntent {
  final String text;

  const SendMessageIntent(this.text);
}

class LoadPreviousSessionsIntent extends SmartCoachIntent {
  const LoadPreviousSessionsIntent();
}

class SelectSessionIntent extends SmartCoachIntent {
  final ChatSessionEntity session;

  const SelectSessionIntent(this.session);
}

class StartNewChatIntent extends SmartCoachIntent {
  const StartNewChatIntent();
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import '../models/chat_message_dto.dart';
import '../models/chat_session_dto.dart';

@lazySingleton
class ChatFirestoreDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  const ChatFirestoreDataSource(this._firestore, this._auth);

  String get _userId => _auth.currentUser?.uid ?? 'guest_user';

  CollectionReference<ChatSessionDto> _sessionsRef() {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('chat_sessions')
        .withConverter<ChatSessionDto>(
      fromFirestore: (s, _) => ChatSessionDto.fromJson(s.data()!),
      toFirestore: (m, _) => m.toJson(),
    );
  }

  CollectionReference<ChatMessageDto> _messagesRef(String sessionId) {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('chat_sessions')
        .doc(sessionId)
        .collection('messages')
        .withConverter<ChatMessageDto>(
      fromFirestore: (s, _) => ChatMessageDto.fromJson(s.data()!),
      toFirestore: (m, _) => m.toJson(),
    );
  }
//---------------------save session--------------------------------
  Future<void> saveSession(ChatSessionDto session) async {
    await _sessionsRef().doc(session.id).set(session);
  }
//-------------------save message--------------------------------
  Future<void> saveMessage(String sessionId, ChatMessageDto message) async {
    await _messagesRef(sessionId).doc(message.id).set(message);
    await _sessionsRef().doc(sessionId).update({
      'updatedAtMillis': message.createdAtMillis,
      'totalTokens': FieldValue.increment(message.tokens),
    });
  }
// ---------------------- get sessions---------------------------
  Future<List<ChatSessionDto>> getSessions() async {
    final snap = await _sessionsRef()
        .orderBy('updatedAtMillis', descending: true)
        .limit(20)
        .get();
    return snap.docs.map((d) => d.data()).toList();
  }
//-----------------------get messages--------------------------------
  Future<List<ChatMessageDto>> getMessages(String sessionId) async {
    final snap = await _messagesRef(sessionId)
        .orderBy('createdAtMillis', descending: false)
        .get();
    return snap.docs.map((d) => d.data()).toList();
  }
}
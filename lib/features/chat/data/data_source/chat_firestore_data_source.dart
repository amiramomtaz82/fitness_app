import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/secure_storage/secure_storage.dart';
import '../models/chat_message_dto.dart';
import '../models/chat_session_dto.dart';

@lazySingleton
class ChatFirestoreDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final SecureStorage _secureStorage;

  const ChatFirestoreDataSource(
    this._firestore,
    this._auth,
    this._secureStorage,
  );

  /// Resolves the Elevate backend user ID first, falling back to Firebase Auth UID if needed.
  Future<String> _resolveUserId() async {
    final cachedUserJson = await _secureStorage.read(key: 'cached_user');
    if (cachedUserJson != null && cachedUserJson.isNotEmpty) {
      try {
        final Map<String, dynamic> data = jsonDecode(cachedUserJson);
        final backendId = data['_id'] ?? data['id'];
        if (backendId != null && backendId.toString().isNotEmpty) {
          return backendId.toString();
        }
      } catch (_) {}
    }
    return _auth.currentUser?.uid ?? 'guest_user';
  }

  Future<CollectionReference<ChatSessionDto>> _sessionsRef() async {
    final userId = await _resolveUserId();
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('chat_sessions')
        .withConverter<ChatSessionDto>(
          fromFirestore: (s, _) => ChatSessionDto.fromJson(s.data()!),
          toFirestore: (m, _) => m.toJson(),
        );
  }

  Future<CollectionReference<ChatMessageDto>> _messagesRef(
    String sessionId,
  ) async {
    final userId = await _resolveUserId();
    return _firestore
        .collection('users')
        .doc(userId)
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
    final ref = await _sessionsRef();
    await ref.doc(session.id).set(session);
  }

  //-------------------save message (Atomic Batch)--------------------------------
  Future<void> saveMessage(String sessionId, ChatMessageDto message) async {
    final msgRef = await _messagesRef(sessionId);
    final sessionRef = await _sessionsRef();

    final batch = _firestore.batch();

    final messageDoc = msgRef.doc(message.id);
    final sessionDoc = sessionRef.doc(sessionId);

    // 1. Stage message creation in batch
    batch.set(messageDoc, message);

    // 2. Stage parent session update in batch
    batch.update(sessionDoc, {
      'updatedAtMillis': message.createdAtMillis,
      'totalTokens': FieldValue.increment(message.tokens),
    });

    // 3. Atomically commit both operations together
    await batch.commit();
  }

  // ---------------------- get sessions (Cursor Pagination) ---------------------------
  Future<List<ChatSessionDto>> getSessions({
    int limit = 20,
    int? lastUpdatedAtMillis,
  }) async {
    final ref = await _sessionsRef();
    var query = ref.orderBy('updatedAtMillis', descending: true).limit(limit);

    // ✅ If a cursor is provided, start immediately after the last item
    if (lastUpdatedAtMillis != null) {
      query = query.startAfter([lastUpdatedAtMillis]);
    }

    final snap = await query.get();
    return snap.docs.map((d) => d.data()).toList();
  }

  //-----------------------get messages--------------------------------
  Future<List<ChatMessageDto>> getMessages(String sessionId) async {
    final ref = await _messagesRef(sessionId);
    final snap = await ref.orderBy('createdAtMillis', descending: false).get();
    return snap.docs.map((d) => d.data()).toList();
  }
}

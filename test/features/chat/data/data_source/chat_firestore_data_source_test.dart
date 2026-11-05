// ignore_for_file: subtype_of_sealed_class
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/features/chat/data/data_source/chat_firestore_data_source.dart';
import 'package:fitness_app/features/chat/data/models/chat_message_dto.dart';
import 'package:fitness_app/features/chat/data/models/chat_session_dto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockCollectionReference<T extends Object?> extends Mock
    implements CollectionReference<T> {}

class MockDocumentReference<T extends Object?> extends Mock
    implements DocumentReference<T> {}

class MockQuerySnapshot<T extends Object?> extends Mock
    implements QuerySnapshot<T> {}

class MockQueryDocumentSnapshot<T extends Object?> extends Mock
    implements QueryDocumentSnapshot<T> {}

class MockQuery<T extends Object?> extends Mock implements Query<T> {}

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late ChatFirestoreDataSource dataSource;

  // Unconverted refs
  late MockCollectionReference<Map<String, dynamic>> mockUsersCol;
  late MockDocumentReference<Map<String, dynamic>> mockUserDoc;
  late MockCollectionReference<Map<String, dynamic>> mockChatSessionsCol;
  late MockDocumentReference<Map<String, dynamic>> mockSessionDoc;
  late MockCollectionReference<Map<String, dynamic>> mockMessagesCol;

  // Converted refs
  late MockCollectionReference<ChatSessionDto> mockConvertedSessionsCol;
  late MockDocumentReference<ChatSessionDto> mockConvertedSessionDoc;
  late MockCollectionReference<ChatMessageDto> mockConvertedMessagesCol;
  late MockDocumentReference<ChatMessageDto> mockConvertedMessageDoc;

  setUpAll(() {
    registerFallbackValue(
      const ChatSessionDto(
        id: 'fallback_id',
        title: 'fallback_title',
        updatedAtMillis: 0,
        totalTokens: 0,
      ),
    );
    registerFallbackValue(
      const ChatMessageDto(
        id: 'fallback_msg_id',
        sender: 'user',
        text: 'fallback',
        createdAtMillis: 0,
      ),
    );
  });

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();

    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn('test_uid');

    mockUsersCol = MockCollectionReference<Map<String, dynamic>>();
    mockUserDoc = MockDocumentReference<Map<String, dynamic>>();
    mockChatSessionsCol = MockCollectionReference<Map<String, dynamic>>();
    mockSessionDoc = MockDocumentReference<Map<String, dynamic>>();
    mockMessagesCol = MockCollectionReference<Map<String, dynamic>>();

    mockConvertedSessionsCol = MockCollectionReference<ChatSessionDto>();
    mockConvertedSessionDoc = MockDocumentReference<ChatSessionDto>();
    mockConvertedMessagesCol = MockCollectionReference<ChatMessageDto>();
    mockConvertedMessageDoc = MockDocumentReference<ChatMessageDto>();

    when(() => mockFirestore.collection('users')).thenReturn(mockUsersCol);
    when(() => mockUsersCol.doc('test_uid')).thenReturn(mockUserDoc);
    when(
      () => mockUserDoc.collection('chat_sessions'),
    ).thenReturn(mockChatSessionsCol);

    when(
      () => mockChatSessionsCol.withConverter<ChatSessionDto>(
        fromFirestore: any(named: 'fromFirestore'),
        toFirestore: any(named: 'toFirestore'),
      ),
    ).thenReturn(mockConvertedSessionsCol);

    when(() => mockChatSessionsCol.doc(any())).thenReturn(mockSessionDoc);
    when(
      () => mockSessionDoc.collection('messages'),
    ).thenReturn(mockMessagesCol);

    when(
      () => mockMessagesCol.withConverter<ChatMessageDto>(
        fromFirestore: any(named: 'fromFirestore'),
        toFirestore: any(named: 'toFirestore'),
      ),
    ).thenReturn(mockConvertedMessagesCol);

    dataSource = ChatFirestoreDataSource(mockFirestore, mockAuth);
  });

  group('ChatFirestoreDataSource —', () {
    test('saveSession sets session dto with id', () async {
      const session = ChatSessionDto(
        id: 'session_1',
        title: 'Workout Chat',
        updatedAtMillis: 1000,
        totalTokens: 50,
      );

      when(
        () => mockConvertedSessionsCol.doc('session_1'),
      ).thenReturn(mockConvertedSessionDoc);
      when(() => mockConvertedSessionDoc.set(session)).thenAnswer((_) async {});

      await dataSource.saveSession(session);

      verify(() => mockConvertedSessionDoc.set(session)).called(1);
    });

    test('saveMessage saves message and updates parent session', () async {
      const message = ChatMessageDto(
        id: 'msg_1',
        sender: 'user',
        text: 'hello coach',
        createdAtMillis: 2000,
        tokens: 15,
      );

      when(
        () => mockConvertedMessagesCol.doc('msg_1'),
      ).thenReturn(mockConvertedMessageDoc);
      when(() => mockConvertedMessageDoc.set(message)).thenAnswer((_) async {});
      when(
        () => mockConvertedSessionsCol.doc('session_1'),
      ).thenReturn(mockConvertedSessionDoc);
      when(
        () => mockConvertedSessionDoc.update(any()),
      ).thenAnswer((_) async {});

      await dataSource.saveMessage('session_1', message);

      verify(() => mockConvertedMessageDoc.set(message)).called(1);
      verify(() => mockConvertedSessionDoc.update(any())).called(1);
    });

    test('getSessions returns mapped list from firestore snapshot', () async {
      final mockSnapshot = MockQuerySnapshot<ChatSessionDto>();
      final mockDocSnapshot = MockQueryDocumentSnapshot<ChatSessionDto>();
      final mockQuery = MockQuery<ChatSessionDto>();

      const session = ChatSessionDto(
        id: 'session_1',
        title: 'Workout Chat',
        updatedAtMillis: 1000,
        totalTokens: 100,
      );

      when(
        () => mockConvertedSessionsCol.orderBy(
          'updatedAtMillis',
          descending: true,
        ),
      ).thenReturn(mockQuery);
      when(() => mockQuery.limit(20)).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.docs).thenReturn([mockDocSnapshot]);
      when(() => mockDocSnapshot.data()).thenReturn(session);

      final result = await dataSource.getSessions();

      expect(result, equals([session]));
    });

    test(
      'getMessages returns mapped list ordered by createdAtMillis',
      () async {
        final mockSnapshot = MockQuerySnapshot<ChatMessageDto>();
        final mockDocSnapshot = MockQueryDocumentSnapshot<ChatMessageDto>();
        final mockQuery = MockQuery<ChatMessageDto>();

        const message = ChatMessageDto(
          id: 'msg_1',
          sender: 'user',
          text: 'hello',
          createdAtMillis: 1000,
        );

        when(
          () => mockConvertedMessagesCol.orderBy(
            'createdAtMillis',
            descending: false,
          ),
        ).thenReturn(mockQuery);
        when(() => mockQuery.get()).thenAnswer((_) async => mockSnapshot);
        when(() => mockSnapshot.docs).thenReturn([mockDocSnapshot]);
        when(() => mockDocSnapshot.data()).thenReturn(message);

        final result = await dataSource.getMessages('session_1');

        expect(result, equals([message]));
      },
    );

    test('falls back to guest_user when auth currentUser is null', () async {
      when(() => mockAuth.currentUser).thenReturn(null);
      when(() => mockUsersCol.doc('guest_user')).thenReturn(mockUserDoc);

      const session = ChatSessionDto(
        id: 's_guest',
        title: 'Guest',
        updatedAtMillis: 1,
        totalTokens: 0,
      );

      when(
        () => mockConvertedSessionsCol.doc('s_guest'),
      ).thenReturn(mockConvertedSessionDoc);
      when(() => mockConvertedSessionDoc.set(session)).thenAnswer((_) async {});

      await dataSource.saveSession(session);

      verify(() => mockUsersCol.doc('guest_user')).called(1);
    });
  });
}

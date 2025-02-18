import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:leanware_assessment/pages/home_page.dart';
import 'package:leanware_assessment/pages/signup_page.dart';
import 'package:leanware_assessment/pages/login_page.dart';
import 'package:firebase_auth_mocks/src/mock_user_credential.dart';

@GenerateMocks([FirebaseAuth, UserCredential])
void main() {
  late MockFirebaseAuth mockAuth;

  setUp(() {
    mockAuth = MockFirebaseAuth();
  });

  Widget createTestableWidget(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  testWidgets('LoginPage renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createTestableWidget(const LoginPage()));

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Enter your credential to login'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.byType(TextButton), findsNWidgets(2));
  });

  testWidgets('Displays error when fields are empty',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestableWidget(const LoginPage()));

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('All fields are required'), findsOneWidget);
  });

  testWidgets('Shows error when authentication fails',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestableWidget(const LoginPage()));

    await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password123');

    when(mockAuth.signInWithEmailAndPassword(
      email: anyNamed('email'),
      password: anyNamed('password'),
    )).thenThrow(FirebaseAuthException(code: 'user-not-found'));

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('No user found for this email'), findsOneWidget);
  });

  testWidgets('Navigates to HomePage on successful login',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestableWidget(const LoginPage()));

    await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password123');

    when(mockAuth.signInWithEmailAndPassword(
      email: anyNamed('email'),
      password: anyNamed('password'),
    )).thenAnswer((_) async => MockUserCredential());

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('Navigates to SignupPage when Sign Up is tapped',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestableWidget(const LoginPage()));
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    expect(find.byType(SignupPage), findsOneWidget);
  });
}

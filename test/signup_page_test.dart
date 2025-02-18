import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leanware_assessment/pages/signup_page.dart';
import 'package:leanware_assessment/pages/home_page.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth_mocks/src/mock_user_credential.dart';

void main() {
  testWidgets('Empty fields show error message', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignupPage()));

    // Tap the "Sign up" button without entering any text
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Check if the error message for empty fields appears
    expect(find.text('All fields are required'), findsOneWidget);
  });

  testWidgets('Invalid email format shows error message',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignupPage()));

    // Enter an invalid email format
    await tester.enterText(find.byType(TextField).first, 'invalidemail.com');

    // Tap the "Sign up" button
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Check if the error message for invalid email format appears
    expect(find.text('Enter a valid email address'), findsOneWidget);
  });

  testWidgets('Password too short shows error message',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignupPage()));

    // Enter a valid email
    await tester.enterText(find.byType(TextField).first, 'test@example.com');

    // Enter a short password
    await tester.enterText(find.byType(TextField).at(1), '12345');

    // Enter a matching confirm password
    await tester.enterText(find.byType(TextField).at(2), '12345');

    // Tap the "Sign up" button
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Check if the error message for short password appears
    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
  });

  testWidgets('Password and confirm password mismatch shows error message',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignupPage()));

    // Enter a valid email
    await tester.enterText(find.byType(TextField).first, 'test@example.com');

    // Enter a valid password
    await tester.enterText(find.byType(TextField).at(1), 'password123');

    // Enter a different password in confirm password field
    await tester.enterText(
        find.byType(TextField).at(2), 'differentpassword123');

    // Tap the "Sign up" button
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Check if the error message for password mismatch appears
    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('Successful signup navigates to HomePage',
      (WidgetTester tester) async {
    // Mock the FirebaseAuth instance for successful signup
    final mockFirebaseAuth = MockFirebaseAuth();
    final mockUserCredential = MockUserCredential();

    when(mockFirebaseAuth.createUserWithEmailAndPassword(
      email: anyNamed('email'),
      password: anyNamed('password'),
    )).thenAnswer((_) async => mockUserCredential);

    await tester.pumpWidget(
      MaterialApp(
        home: SignupPage(),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    await tester.enterText(find.byType(TextField).at(2), 'password123');

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:leanware_assessment/main.dart';
import 'package:leanware_assessment/pages/home_page.dart';
import 'package:leanware_assessment/pages/login_page.dart';

void main() {
  testWidgets('should navigate to HomePage when user is logged in',
      (WidgetTester tester) async {
    // Simulate an authenticated user
    final mockAuth = MockFirebaseAuth(signedIn: true);

    await tester.pumpWidget(MyApp());

    // Wait for the StreamBuilder to finish building
    await tester.pumpAndSettle();

    // Verify that HomePage is displayed
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);
  });

  testWidgets('should navigate to LoginPage when user is not logged in',
      (WidgetTester tester) async {
    // Simulate no authenticated user
    final mockAuth = MockFirebaseAuth(signedIn: false);

    await tester.pumpWidget(MyApp());

    // Wait for the StreamBuilder to finish building
    await tester.pumpAndSettle();

    // Verify that LoginPage is displayed
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);
  });

  testWidgets(
      'should show CircularProgressIndicator while checking authentication',
      (WidgetTester tester) async {
    // Create FirebaseAuth without a signed-in user
    final mockAuth = MockFirebaseAuth();

    await tester.pumpWidget(MyApp());

    // Verify that CircularProgressIndicator is displayed while checking authentication
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}

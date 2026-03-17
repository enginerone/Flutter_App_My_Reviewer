import 'package:flutter_test/flutter_test.dart';
import 'package:reviewer/main.dart';

void main() {
  testWidgets('App smoke test - ReviewerApp launches', (WidgetTester tester) async {
    await tester.pumpWidget(const ReviewerApp());
    expect(find.byType(ReviewerApp), findsOneWidget);
  });
}

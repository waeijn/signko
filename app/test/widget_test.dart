import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signko_app/main.dart';

void main() {
  testWidgets('App loads successfully smoke test', (WidgetTester tester) async {
    // Build our app wrapped in ProviderScope and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: SignKoApp()));

    // Verify that our app bar title is present
    expect(find.text('SignKo Translation'), findsOneWidget);
  });
}

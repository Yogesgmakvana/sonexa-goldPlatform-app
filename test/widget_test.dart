import 'package:flutter_test/flutter_test.dart';
import 'package:sonexa/main.dart';

void main() {
  testWidgets('Sonexa dashboard opens with market navigation', (tester) async {
    await tester.pumpWidget(const SonexaApp());
    await tester.pumpAndSettle();
    expect(find.text('SONEXA'), findsOneWidget);
    expect(find.text('Market snapshot'), findsOneWidget);
    expect(find.text('Markets'), findsOneWidget);
  });
}

import 'package:app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Muestra la pantalla inicial Hola, PATO DONALD', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: PatoDonaldApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hola, PATO DONALD'), findsOneWidget);
    expect(find.textContaining('\$85.000'), findsOneWidget);
  });
}

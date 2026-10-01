import 'package:flutter_test/flutter_test.dart';
import 'package:divisor_cuenta/main.dart';

void main() {
  testWidgets('DiviCuenta smoke test - verifies tabs and initial view', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const DiviCuentaApp());
    await tester.pumpAndSettle();

    // Verify app title and tabs are rendered
    expect(find.text('DiviCuenta'), findsWidgets);
    expect(find.text('División Rápida'), findsOneWidget);
    expect(find.text('Por Amigos'), findsOneWidget);

    // Verify initial state of Quick Split
    expect(find.text('Total de la Cuenta'), findsOneWidget);
    expect(find.text('Número de Personas'), findsOneWidget);
    expect(find.text('Propina'), findsOneWidget);
  });

  testWidgets('DiviCuenta switches to Por Amigos tab', (WidgetTester tester) async {
    await tester.pumpWidget(const DiviCuentaApp());
    await tester.pumpAndSettle();

    // Tap on 'Por Amigos' tab
    await tester.tap(find.text('Por Amigos'));
    await tester.pumpAndSettle();

    // Verify elements in the Detailed Split screen
    expect(find.textContaining('Amigos en la mesa'), findsOneWidget);
    expect(find.text('TOTAL GENERAL DE LA MESA'), findsOneWidget);
  });
}

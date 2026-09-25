import 'package:flutter_test/flutter_test.dart';
import 'package:peerlens/aplicacion.dart';

void main() {
  testWidgets('Renderizado inicial de PeerLens', (WidgetTester tester) async {
    // prueba de humo para el renderizado de la aplicacion
    await tester.pumpWidget(const AplicacionPeerLens());

    expect(find.text('PeerLens'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:notes_app/main.dart';

void main() {
  testWidgets('App démarre et affiche l’écran Dossiers', (WidgetTester tester) async {
    await tester.pumpWidget(const AppleNoteApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text('Dossiers'), findsWidgets);
  });
}

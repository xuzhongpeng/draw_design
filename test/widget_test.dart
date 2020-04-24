// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    DateTime begin = DateTime.parse('20181206');
    DateTime end = DateTime.parse('20190506');

    DateTime dura = DateTime(begin.year, begin.month + 1, begin.day);

    print(dura.toString());


  });
}

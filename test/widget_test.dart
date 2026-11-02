import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:school_receipt_printer/main.dart';

void main() {
  testWidgets('app loads and renders receipt UI', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const SchoolReceiptApp());

    expect(find.text('80mm School Thermal Station'), findsOneWidget);
    expect(find.text('School Fee Receipt'), findsOneWidget);
  });

  testWidgets('fee receipt includes a Class field', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const SchoolReceiptApp());

    expect(find.text('Class'), findsWidgets);
  });
}

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'receipt_model.dart';

class ReceiptProvider extends ChangeNotifier {
  // Global Header
  final TextEditingController schoolNameController = TextEditingController(
    text: 'CITY GRAMMAR HIGH SCHOOL',
  );
  Uint8List? logoBytes;

  // Template Mode (0: Fee Receipt, 1: Free Text Notice)
  int templateIndex = 0;

  // Student & Fee Form Controllers
  final TextEditingController studentNameController = TextEditingController(
    text: 'Zayd Ali',
  );
  final TextEditingController fatherNameController = TextEditingController(
    text: 'Tariq Ali',
  );
  final TextEditingController classSectionController = TextEditingController(
    text: 'Class 9-A',
  ); // Added Controller
  final TextEditingController feeMonthController = TextEditingController(
    text: 'November 2026',
  );
  final TextEditingController totalFeeController = TextEditingController(
    text: '6500',
  );
  final TextEditingController totalPaidController = TextEditingController(
    text: '5000',
  );

  // Notice Body Controller
  final TextEditingController noticeTextController = TextEditingController(
    text:
        'ATTENTION PARENTS:\n\nMid-Term Examinations commence on Monday. All pending dues must be cleared before roll number slips are issued.\n\n- Administration',
  );

  // Meta
  final String receiptNo =
      'BC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
  final DateTime receiptDate = DateTime.now();

  ReceiptProvider() {
    schoolNameController.addListener(_notify);
    studentNameController.addListener(_notify);
    fatherNameController.addListener(_notify);
    classSectionController.addListener(_notify);
    feeMonthController.addListener(_notify);
    totalFeeController.addListener(_notify);
    totalPaidController.addListener(_notify);
    noticeTextController.addListener(_notify);
  }

  void _notify() => notifyListeners();

  void setTemplateIndex(int index) {
    templateIndex = index;
    notifyListeners();
  }

  Future<void> pickLogo() async {
    notifyListeners();
  }

  void removeLogo() {
    logoBytes = null;
    notifyListeners();
  }

  double get totalFee => double.tryParse(totalFeeController.text) ?? 0.0;
  double get totalPaid => double.tryParse(totalPaidController.text) ?? 0.0;
  double get totalRemaining {
    final rem = totalFee - totalPaid;
    return rem < 0 ? 0.0 : rem;
  }

  ReceiptModel get currentReceipt => ReceiptModel(
    schoolName: schoolNameController.text.trim(),
    logoBytes: logoBytes,
    templateIndex: templateIndex,
    receiptNo: receiptNo,
    date: receiptDate,
    studentName: studentNameController.text.trim(),
    fatherName: fatherNameController.text.trim(),
    classSection: classSectionController.text.trim(),
    feeMonth: feeMonthController.text.trim(),
    totalFee: totalFee,
    totalPaid: totalPaid,
    noticeText: noticeTextController.text.trim(),
  );

  @override
  void dispose() {
    schoolNameController.dispose();
    studentNameController.dispose();
    fatherNameController.dispose();
    classSectionController.dispose();
    feeMonthController.dispose();
    totalFeeController.dispose();
    totalPaidController.dispose();
    noticeTextController.dispose();
    super.dispose();
  }
}

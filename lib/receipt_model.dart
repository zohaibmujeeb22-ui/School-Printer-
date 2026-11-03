import 'dart:typed_data';

class ReceiptModel {
  final String schoolName;
  final Uint8List? logoBytes;
  final int templateIndex;
  final String receiptNo;
  final DateTime date;
  final String studentName;
  final String fatherName;
  final String classSection;
  final String feeMonth;
  final double totalFee;
  final double totalPaid;
  final String noticeText;

  const ReceiptModel({
    required this.schoolName,
    this.logoBytes,
    required this.templateIndex,
    required this.receiptNo,
    required this.date,
    required this.studentName,
    required this.fatherName,
    required this.classSection,
    required this.feeMonth,
    required this.totalFee,
    required this.totalPaid,
    required this.noticeText,
  });

  double get remainingFee {
    final diff = totalFee - totalPaid;
    return diff < 0 ? 0.0 : diff;
  }
}

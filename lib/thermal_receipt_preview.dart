import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'receipt_model.dart';

class ThermalReceiptPreview extends StatelessWidget {
  final ReceiptModel receipt;

  const ThermalReceiptPreview({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat('#,##0.00');

    // Constrained precisely to match the 80mm roll printable canvas width (576px / 72mm @ 203 DPI)
    return Container(
      width: 255,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo (Bounded to 34px height to eliminate blank gap)
          if (receipt.logoBytes != null) ...[
            Center(
              child: Image.memory(
                receipt.logoBytes!,
                height: 34,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 2),
          ],

          // Header Title
          Text(
            receipt.schoolName.isEmpty
                ? 'SCHOOL NAME'
                : receipt.schoolName.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Courier',
              fontWeight: FontWeight.w900,
              fontSize: 12,
              height: 1.1,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            receipt.templateIndex == 0
                ? '*** FEE RECEIPT ***'
                : '*** OFFICIAL NOTICE ***',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Courier',
              fontWeight: FontWeight.bold,
              fontSize: 8.5,
            ),
          ),
          const SizedBox(height: 3),
          _buildCompactDashedLine(),
          const SizedBox(height: 2),

          // Metadata Row (Single-line timestamp + ref code)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Date: ${DateFormat('dd/MM/yy HH:mm').format(receipt.date)}',
                style: const TextStyle(fontFamily: 'Courier', fontSize: 8),
              ),
              Text(
                receipt.receiptNo,
                style: const TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          _buildCompactDashedLine(),
          const SizedBox(height: 3),

          // Template 0: School Fee Receipt Layout
          if (receipt.templateIndex == 0) ...[
            _buildDataRow(
              'Student:',
              receipt.studentName.isEmpty ? '---' : receipt.studentName,
            ),
            _buildDataRow(
              'Father:',
              receipt.fatherName.isEmpty ? '---' : receipt.fatherName,
            ),
            _buildDataRow(
              'Class/Sec:',
              receipt.classSection.isEmpty ? '---' : receipt.classSection,
            ),
            _buildDataRow(
              'Month:',
              receipt.feeMonth.isEmpty ? '---' : receipt.feeMonth,
            ),
            const SizedBox(height: 3),
            _buildCompactDashedLine(),
            const SizedBox(height: 3),
            _buildDataRow(
              'Total Fee:',
              'Rs. ${currency.format(receipt.totalFee)}',
            ),
            _buildDataRow(
              'Paid Amount:',
              'Rs. ${currency.format(receipt.totalPaid)}',
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 2),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.black, width: 0.8),
                  bottom: BorderSide(color: Colors.black, width: 0.8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'BALANCE DUE:',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontWeight: FontWeight.w900,
                      fontSize: 9.5,
                    ),
                  ),
                  Text(
                    'Rs. ${currency.format(receipt.remainingFee)}',
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cashier: ________',
                  style: TextStyle(fontFamily: 'Courier', fontSize: 7.5),
                ),
                Text(
                  'Parent: ________',
                  style: TextStyle(fontFamily: 'Courier', fontSize: 7.5),
                ),
              ],
            ),
          ] else ...[
            // Template 1: Custom Announcement / Message
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Text(
                receipt.noticeText.isEmpty
                    ? 'Notice body is empty...'
                    : receipt.noticeText,
                style: const TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 9,
                  height: 1.15,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Authorized Signature: ________',
                style: TextStyle(fontFamily: 'Courier', fontSize: 7.5),
              ),
            ),
          ],

          const SizedBox(height: 3),
          _buildCompactDashedLine(),
          const SizedBox(height: 2),
          const Text(
            'Keep this receipt for verification.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Courier',
              fontSize: 7.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Courier',
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Courier',
                fontWeight: FontWeight.bold,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactDashedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 3.5;
        const dashSpace = 2.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            dashCount,
            (_) => const SizedBox(
              width: dashWidth,
              height: 0.8,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.black87),
              ),
            ),
          ),
        );
      },
    );
  }
}

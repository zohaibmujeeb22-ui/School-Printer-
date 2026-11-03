import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'receipt_model.dart';

class ReceiptPdfService {
  /// Outputs an exact continuous 80mm roll format for Black Copper printers
  static Future<void> printThermalReceipt(ReceiptModel receipt) async {
    final pdf = pw.Document();
    final currency = NumberFormat('#,##0.00');

    const double rollWidth = 80.0 * PdfPageFormat.mm;
    const pageFormat = PdfPageFormat(
      rollWidth,
      double.infinity,
      marginLeft: 3.5 * PdfPageFormat.mm,
      marginRight: 3.5 * PdfPageFormat.mm,
      marginTop: 2.5 * PdfPageFormat.mm,
      marginBottom: 8.5 * PdfPageFormat.mm,
    );

    pw.MemoryImage? logoImage;
    if (receipt.logoBytes != null) {
      logoImage = pw.MemoryImage(receipt.logoBytes!);
    }

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              if (logoImage != null)
                pw.Center(
                  child: pw.Container(
                    height: 32,
                    margin: const pw.EdgeInsets.only(bottom: 2),
                    child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                  ),
                ),
              pw.Text(
                receipt.schoolName.toUpperCase(),
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 1),
              pw.Text(
                receipt.templateIndex == 0
                    ? '*** FEE RECEIPT ***'
                    : '*** OFFICIAL NOTICE ***',
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 7),
              ),
              pw.SizedBox(height: 2),
              _buildPdfDottedRule(),
              pw.SizedBox(height: 2),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Date: ${DateFormat('dd/MM/yy HH:mm').format(receipt.date)}',
                    style: const pw.TextStyle(fontSize: 7),
                  ),
                  pw.Text(
                    receipt.receiptNo,
                    style: pw.TextStyle(
                      fontSize: 7,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 2),
              _buildPdfDottedRule(),
              pw.SizedBox(height: 2.5),
              if (receipt.templateIndex == 0) ...[
                _buildPdfRow('Student:', receipt.studentName),
                _buildPdfRow('Father:', receipt.fatherName),
                _buildPdfRow('Class/Sec:', receipt.classSection),
                _buildPdfRow('Month:', receipt.feeMonth),
                pw.SizedBox(height: 2),
                _buildPdfDottedRule(),
                pw.SizedBox(height: 2),
                _buildPdfRow(
                  'Total Fee:',
                  'Rs. ${currency.format(receipt.totalFee)}',
                ),
                _buildPdfRow(
                  'Paid Amount:',
                  'Rs. ${currency.format(receipt.totalPaid)}',
                ),
                pw.SizedBox(height: 1),
                pw.Container(
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      top: pw.BorderSide(
                        width: 0.6,
                        style: pw.BorderStyle.dashed,
                      ),
                      bottom: pw.BorderSide(
                        width: 0.6,
                        style: pw.BorderStyle.dashed,
                      ),
                    ),
                  ),
                  padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'BALANCE DUE:',
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'Rs. ${currency.format(receipt.remainingFee)}',
                        style: pw.TextStyle(
                          fontSize: 8.5,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Cashier: ________',
                      style: const pw.TextStyle(fontSize: 6.5),
                    ),
                    pw.Text(
                      'Parent: ________',
                      style: const pw.TextStyle(fontSize: 6.5),
                    ),
                  ],
                ),
              ] else ...[
                pw.Text(
                  receipt.noticeText,
                  style: const pw.TextStyle(fontSize: 7.5, lineSpacing: 1.3),
                ),
                pw.SizedBox(height: 6),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    'Authorized Signature: ________',
                    style: const pw.TextStyle(fontSize: 6.5),
                  ),
                ),
              ],
              pw.SizedBox(height: 2.5),
              _buildPdfDottedRule(),
              pw.SizedBox(height: 1.5),
              pw.Text(
                'Keep this receipt for verification.',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 6.5,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Receipt_${receipt.receiptNo}.pdf',
      format: pageFormat,
    );
  }

  static pw.Widget _buildPdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 0.6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 7)),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPdfDottedRule() {
    return pw.Row(
      children: List.generate(
        38,
        (index) => pw.Expanded(
          child: pw.Container(
            height: 0.5,
            color: index % 2 == 0 ? PdfColors.black : PdfColors.white,
          ),
        ),
      ),
    );
  }
}

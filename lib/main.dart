import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SchoolAdminApp());
}

class SchoolAdminApp extends StatelessWidget {
  const SchoolAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Thermal Receipt System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A),
          primary: const Color(0xFF1E3A8A),
          surface: const Color(0xFFF1F5F9),
        ),
        useMaterial3: true,
        fontFamily: 'Segoe UI',
      ),
      home: const SchoolReceiptApp(),
    );
  }
}

class SchoolReceiptApp extends StatelessWidget {
  const SchoolReceiptApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ReceiptHomeScreen();
  }
}

class ReceiptLayoutItem {
  final String id;
  final double dx;
  final double dy;
  final double horizontalPadding;
  final double verticalPadding;
  final double fontSize;

  const ReceiptLayoutItem({
    required this.id,
    required this.dx,
    required this.dy,
    this.horizontalPadding = 0,
    this.verticalPadding = 0,
    this.fontSize = 10.5,
  });

  ReceiptLayoutItem copyWith({
    String? id,
    double? dx,
    double? dy,
    double? horizontalPadding,
    double? verticalPadding,
    double? fontSize,
  }) {
    return ReceiptLayoutItem(
      id: id ?? this.id,
      dx: dx ?? this.dx,
      dy: dy ?? this.dy,
      horizontalPadding: horizontalPadding ?? this.horizontalPadding,
      verticalPadding: verticalPadding ?? this.verticalPadding,
      fontSize: fontSize ?? this.fontSize,
    );
  }
}

class ReceiptLayoutController extends ChangeNotifier {
  ReceiptLayoutController() {
    _items = _defaultItems();
  }

  late Map<String, ReceiptLayoutItem> _items;

  Map<String, ReceiptLayoutItem> get items => Map.unmodifiable(_items);

  ReceiptLayoutItem item(String id) => _items[id] ?? _defaultItems()[id]!;

  void updateItem(
    String id, {
    double? dx,
    double? dy,
    double? horizontalPadding,
    double? verticalPadding,
    double? fontSize,
  }) {
    final existing = _items[id];
    if (existing == null) return;

    _items[id] = existing.copyWith(
      dx: dx,
      dy: dy,
      horizontalPadding: horizontalPadding,
      verticalPadding: verticalPadding,
      fontSize: fontSize,
    );
    notifyListeners();
  }

  void reset() {
    _items = _defaultItems();
    notifyListeners();
  }

  static Map<String, ReceiptLayoutItem> _defaultItems() {
    return {
      'header': const ReceiptLayoutItem(id: 'header', dx: 0, dy: 0),
      'tag': const ReceiptLayoutItem(id: 'tag', dx: 0, dy: 22),
      'date': const ReceiptLayoutItem(id: 'date', dx: 0, dy: 38),
      'student': const ReceiptLayoutItem(
        id: 'student',
        dx: 0,
        dy: 66,
        horizontalPadding: 0,
        verticalPadding: 2,
      ),
      'father': const ReceiptLayoutItem(
        id: 'father',
        dx: 0,
        dy: 86,
        verticalPadding: 2,
      ),
      'class': const ReceiptLayoutItem(
        id: 'class',
        dx: 0,
        dy: 106,
        verticalPadding: 2,
      ),
      'totalFee': const ReceiptLayoutItem(
        id: 'totalFee',
        dx: 0,
        dy: 150,
        verticalPadding: 2,
      ),
      'remainingDue': const ReceiptLayoutItem(
        id: 'remainingDue',
        dx: 0,
        dy: 180,
        verticalPadding: 2,
      ),
      'footer': const ReceiptLayoutItem(
        id: 'footer',
        dx: 0,
        dy: 240,
        verticalPadding: 6,
      ),
    };
  }
}

class ReceiptHomeScreen extends StatefulWidget {
  const ReceiptHomeScreen({super.key});

  @override
  State<ReceiptHomeScreen> createState() => _ReceiptHomeScreenState();
}

class _ReceiptHomeScreenState extends State<ReceiptHomeScreen> {
  // Global Header State
  final TextEditingController _headerController = TextEditingController(
    text: 'CITY GRAMMAR HIGH SCHOOL',
  );
  Uint8List? _logoBytes;

  // Template Selection (0: Fee Receipt, 1: Free Text Notice)
  int _selectedTemplate = 0;

  // Template 0: Fee Receipt Fields
  final TextEditingController _studentNameController = TextEditingController(
    text: 'Zayd Ali',
  );
  final TextEditingController _fatherNameController = TextEditingController(
    text: 'Tariq Ali',
  );
  final TextEditingController _classController = TextEditingController(
    text: '9-A',
  );
  final TextEditingController _feeMonthController = TextEditingController(
    text: 'October 2026',
  );
  final TextEditingController _totalFeeController = TextEditingController(
    text: '8500',
  );
  final TextEditingController _totalPaidController = TextEditingController(
    text: '8000',
  );

  // Template 1: Free Text Notice Field
  final TextEditingController _freeTextController = TextEditingController(
    text:
        'IMPORTANT NOTICE:\n\nThe school will remain closed on Friday for Annual Sports Day preparations. All students must arrive in proper sports uniform on Saturday by 08:00 AM sharp.\n\n- Principal Office',
  );

  // Current receipt issuance timestamp
  final DateTime _receiptDate = DateTime.now();
  final String _receiptNo =
      'REC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

  final ReceiptLayoutController _layoutController = ReceiptLayoutController();
  String? _selectedLayoutItemKey;
  bool _layoutEditorEnabled = false;

  @override
  void initState() {
    super.initState();
    // Add real-time listeners for live re-renders on typed inputs
    _headerController.addListener(_onFieldChanged);
    _studentNameController.addListener(_onFieldChanged);
    _fatherNameController.addListener(_onFieldChanged);
    _classController.addListener(_onFieldChanged);
    _feeMonthController.addListener(_onFieldChanged);
    _totalFeeController.addListener(_onFieldChanged);
    _totalPaidController.addListener(_onFieldChanged);
    _freeTextController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _headerController.dispose();
    _studentNameController.dispose();
    _fatherNameController.dispose();
    _classController.dispose();
    _feeMonthController.dispose();
    _totalFeeController.dispose();
    _totalPaidController.dispose();
    _freeTextController.dispose();
    super.dispose();
  }

  // File Picker for Desktop Logo selection
  Future<void> _pickSchoolLogo() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logo upload is disabled in this web build.'),
        ),
      );
    }
  }

  // Reactive calculations
  double get _totalFee => double.tryParse(_totalFeeController.text) ?? 0.0;
  double get _totalPaid => double.tryParse(_totalPaidController.text) ?? 0.0;
  double get _totalRemaining {
    final rem = _totalFee - _totalPaid;
    return rem < 0 ? 0.0 : rem;
  }

  double _toPdfUnit(double value) => value * 0.75;

  void _toggleLayoutEditor(String key) {
    setState(() {
      _selectedLayoutItemKey = key;
      _layoutEditorEnabled = true;
    });
  }

  void _updateSelectedLayout({
    double? dx,
    double? dy,
    double? hPad,
    double? vPad,
  }) {
    final key = _selectedLayoutItemKey;
    if (key == null) return;

    final current = _layoutController.item(key);
    _layoutController.updateItem(
      key,
      dx: dx ?? current.dx,
      dy: dy ?? current.dy,
      horizontalPadding: hPad ?? current.horizontalPadding,
      verticalPadding: vPad ?? current.verticalPadding,
    );
  }

  // -------------------------------------------------------------
  // PDF THERMAL GENERATION & PRINTING
  // -------------------------------------------------------------
  Future<void> _printReceipt() async {
    final pdf = pw.Document();

    // Keep the thermal slip in a fixed printable height so content cannot spill
    // past the sheet. This matches real receipt paper constraints.
    const double thermalWidth = 90.0 * PdfPageFormat.mm;
    const double thermalHeight = 220.0 * PdfPageFormat.mm;
    const pageFormat = PdfPageFormat(
      thermalWidth,
      thermalHeight,
      marginLeft: 1.5 * PdfPageFormat.mm,
      marginRight: 1.5 * PdfPageFormat.mm,
      marginTop: 1.5 * PdfPageFormat.mm,
      marginBottom: 2.0 * PdfPageFormat.mm,
    );

    pw.MemoryImage? logoImage;
    if (_logoBytes != null) {
      logoImage = pw.MemoryImage(_logoBytes!);
    }

    final currencyFormat = NumberFormat('#,##0.00');
    final formattedDate = DateFormat(
      'dd-MMM-yyyy hh:mm a',
    ).format(_receiptDate);

    final headerLayout = _layoutController.item('header');
    final tagLayout = _layoutController.item('tag');
    final dateLayout = _layoutController.item('date');
    final studentLayout = _layoutController.item('student');
    final feeLayout = _layoutController.item('totalFee');

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              // Logo
              if (logoImage != null)
                pw.Container(
                  width: 48,
                  height: 48,
                  margin: pw.EdgeInsets.only(
                    bottom:
                        _toPdfUnit(4) +
                        _toPdfUnit(headerLayout.verticalPadding),
                  ),
                  child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                ),

              pw.SizedBox(height: _toPdfUnit(headerLayout.dy)),
              pw.Padding(
                padding: pw.EdgeInsets.only(
                  left: _toPdfUnit(headerLayout.horizontalPadding),
                ),
                child: pw.Text(
                  _headerController.text.toUpperCase(),
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: _toPdfUnit(tagLayout.dy)),
              pw.Padding(
                padding: pw.EdgeInsets.only(
                  left: _toPdfUnit(tagLayout.horizontalPadding),
                ),
                child: pw.Text(
                  _selectedTemplate == 0
                      ? '*** OFFICIAL FEE RECEIPT ***'
                      : '*** NOTICE & ANNOUNCEMENT ***',
                  style: const pw.TextStyle(fontSize: 7.5),
                ),
              ),
              pw.SizedBox(height: 3),
              _buildPdfDashedDivider(),
              pw.SizedBox(height: 3),

              pw.SizedBox(height: _toPdfUnit(dateLayout.dy)),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.only(
                      left: _toPdfUnit(dateLayout.horizontalPadding),
                    ),
                    child: pw.Text(
                      'Date: $formattedDate',
                      style: const pw.TextStyle(fontSize: 7.5),
                    ),
                  ),
                  pw.Text(
                    'Ref: $_receiptNo',
                    style: const pw.TextStyle(fontSize: 7.5),
                  ),
                ],
              ),
              pw.SizedBox(height: 3),
              _buildPdfDashedDivider(),
              pw.SizedBox(height: 4),

              if (_selectedTemplate == 0) ...[
                pw.SizedBox(height: _toPdfUnit(studentLayout.dy)),
                _buildPdfReceiptRow(
                  'Student Name:',
                  _studentNameController.text,
                  leftPad: studentLayout.horizontalPadding,
                ),
                _buildPdfReceiptRow(
                  'Father Name:',
                  _fatherNameController.text,
                  leftPad: studentLayout.horizontalPadding,
                ),
                _buildPdfReceiptRow(
                  'Class:',
                  _classController.text,
                  leftPad: studentLayout.horizontalPadding,
                ),
                _buildPdfReceiptRow(
                  'Fee Month:',
                  _feeMonthController.text,
                  leftPad: studentLayout.horizontalPadding,
                ),
                pw.SizedBox(height: 3),
                _buildPdfDashedDivider(),
                pw.SizedBox(height: 3),
                _buildPdfReceiptRow(
                  'Total Fee:',
                  'Rs. ${currencyFormat.format(_totalFee)}',
                  leftPad: feeLayout.horizontalPadding,
                ),
                _buildPdfReceiptRow(
                  'Total Paid:',
                  'Rs. ${currencyFormat.format(_totalPaid)}',
                  leftPad: feeLayout.horizontalPadding,
                ),
                pw.SizedBox(height: 2),
                pw.Container(
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      top: pw.BorderSide(
                        width: 0.5,
                        style: pw.BorderStyle.dashed,
                      ),
                      bottom: pw.BorderSide(
                        width: 0.5,
                        style: pw.BorderStyle.dashed,
                      ),
                    ),
                  ),
                  padding: const pw.EdgeInsets.symmetric(vertical: 3),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'REMAINING DUE:',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'Rs. ${currencyFormat.format(_totalRemaining)}',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Cashier Sig: __________',
                      style: const pw.TextStyle(fontSize: 7),
                    ),
                    pw.Text(
                      'Parent Sig: __________',
                      style: const pw.TextStyle(fontSize: 7),
                    ),
                  ],
                ),
              ] else ...[
                pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text(
                    _freeTextController.text,
                    style: const pw.TextStyle(fontSize: 8.5, lineSpacing: 2),
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    'Authorized Signature',
                    style: const pw.TextStyle(fontSize: 7.5),
                  ),
                ),
              ],

              pw.SizedBox(height: 8),
              _buildPdfDashedDivider(),
              pw.SizedBox(height: 4),
              pw.Text(
                'Thank you for your cooperation.',
                style: pw.TextStyle(
                  fontSize: 7.5,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
              pw.SizedBox(height: 10),
            ],
          );
        },
      ),
    );

    // Send directly to the thermal printer dialog
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Receipt-$_receiptNo.pdf',
      format: pageFormat,
    );
  }

  pw.Widget _buildPdfReceiptRow(
    String label,
    String value, {
    double leftPad = 0,
  }) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(
        left: _toPdfUnit(leftPad),
        top: 1.1,
        bottom: 1.1,
      ),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 42,
            child: pw.Text(label, style: const pw.TextStyle(fontSize: 7.5)),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontSize: 7.8,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfDashedDivider() {
    return pw.Row(
      children: List.generate(
        32,
        (index) => pw.Expanded(
          child: pw.Container(
            height: 0.8,
            color: index % 2 == 0 ? PdfColors.black : PdfColors.white,
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // USER INTERFACE
  // -------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2E8F0),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.print, color: Colors.white),
            SizedBox(width: 10),
            Text(
              '80mm School Thermal Station',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT PANEL: Controls and Form Fields (Flexible)
          Expanded(
            flex: 6,
            child: Container(
              color: Colors.white,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('1. Global Header Configuration'),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _headerController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'School / Institution Name',
                        prefixIcon: Icon(Icons.school_outlined),
                        border: OutlineInputBorder(),
                        hintText: 'Enter school name',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickSchoolLogo,
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Upload School Logo'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF334155),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        if (_logoBytes != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.memory(
                              _logoBytes!,
                              width: 42,
                              height: 42,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () => setState(() => _logoBytes = null),
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 18,
                            ),
                            label: const Text(
                              'Remove',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ] else
                          const Text(
                            'No logo selected (PNG/JPG)',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildSectionTitle('2. Template Selector'),
                    const SizedBox(height: 12),
                    ToggleButtons(
                      isSelected: [
                        _selectedTemplate == 0,
                        _selectedTemplate == 1,
                      ],
                      onPressed: (int index) {
                        setState(() {
                          _selectedTemplate = index;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      selectedColor: Colors.white,
                      fillColor: const Color(0xFF1E3A8A),
                      constraints: const BoxConstraints(
                        minHeight: 44,
                        minWidth: 180,
                      ),
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Icon(Icons.receipt_long),
                              SizedBox(width: 8),
                              Text('School Fee Receipt'),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Icon(Icons.notes),
                              SizedBox(width: 8),
                              Text('Free Text / Notice'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // TEMPLATE SPECIFIC INPUT FIELDS
                    if (_selectedTemplate == 0) ...[
                      _buildSectionTitle('3. Fee Details'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _studentNameController,
                              decoration: const InputDecoration(
                                labelText: 'Student Name',
                                prefixIcon: Icon(Icons.person_outline),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextField(
                              controller: _fatherNameController,
                              decoration: const InputDecoration(
                                labelText: "Father's Name",
                                prefixIcon: Icon(Icons.person),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _classController,
                        decoration: const InputDecoration(
                          labelText: 'Class',
                          prefixIcon: Icon(Icons.class_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _feeMonthController,
                        decoration: const InputDecoration(
                          labelText: 'Fee Month / Session',
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _totalFeeController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Total Fee (Rs.)',
                                prefixIcon: Icon(Icons.attach_money),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextField(
                              controller: _totalPaidController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Total Paid (Rs.)',
                                prefixIcon: Icon(Icons.payments_outlined),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Reactive Summary Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Auto Computed Remaining Balance:',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Rs. ${NumberFormat('#,##0.00').format(_totalRemaining)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _totalRemaining > 0
                                    ? Colors.red[700]
                                    : Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      _buildSectionTitle(
                        '3. Announcement / Custom Notice Text',
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _freeTextController,
                        maxLines: 8,
                        decoration: const InputDecoration(
                          labelText: 'Message Body',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                          hintText: 'Type custom notices or announcements...',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // VERTICAL SEPARATOR
          Container(width: 1, color: const Color(0xFFCBD5E1)),

          // RIGHT PANEL: Live Thermal Preview + Green Print Button
          Expanded(
            flex: 5,
            child: Container(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    color: Colors.white,
                    child: const Row(
                      children: [
                        Icon(
                          Icons.visibility_outlined,
                          size: 20,
                          color: Color(0xFF475569),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Simulated 80mm Thermal Receipt Preview',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Scrollable Paper Container
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: _buildThermalPaperPreview(),
                      ),
                    ),
                  ),

                  // Bottom Action Bar with Green Print Button
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                      ),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _printReceipt,
                        icon: const Icon(
                          Icons.print,
                          color: Colors.white,
                          size: 24,
                        ),
                        label: const Text(
                          'PRINT RECEIPT (80mm THERMAL)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // REAL-TIME ON-SCREEN THERMAL RECEIPT CONTAINER
  // -------------------------------------------------------------
  Widget _buildThermalPaperPreview() {
    final currencyFormat = NumberFormat('#,##0.00');
    final formattedDate = DateFormat(
      'dd-MMM-yyyy hh:mm a',
    ).format(_receiptDate);

    final activeItem = _selectedLayoutItemKey;

    return Stack(
      children: [
        SizedBox(
          width: 320,
          height: 720,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 16,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_logoBytes != null) ...[
                    Image.memory(
                      _logoBytes!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 6),
                  ],

                  _buildEditableText(
                    keyName: 'header',
                    child: Text(
                      _headerController.text.isEmpty
                          ? 'SCHOOL NAME'
                          : _headerController.text.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  _buildEditableText(
                    keyName: 'tag',
                    child: Text(
                      _selectedTemplate == 0
                          ? '*** OFFICIAL FEE RECEIPT ***'
                          : '*** NOTICE & ANNOUNCEMENT ***',
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 10,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildDashedLine(),
                  const SizedBox(height: 6),

                  _buildEditableText(
                    keyName: 'date',
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Date: $formattedDate',
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: const TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 9.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Ref: $_receiptNo',
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: const TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 9.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _buildDashedLine(),
                  const SizedBox(height: 8),

                  if (_selectedTemplate == 0) ...[
                    _buildEditableText(
                      keyName: 'student',
                      child: _buildUiKeyValue(
                        'Student Name',
                        _studentNameController.text.isEmpty
                            ? '---'
                            : _studentNameController.text,
                      ),
                    ),
                    _buildEditableText(
                      keyName: 'father',
                      child: _buildUiKeyValue(
                        "Father's Name",
                        _fatherNameController.text.isEmpty
                            ? '---'
                            : _fatherNameController.text,
                      ),
                    ),
                    _buildEditableText(
                      keyName: 'class',
                      child: _buildUiKeyValue(
                        'Class',
                        _classController.text.isEmpty
                            ? '---'
                            : _classController.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildDashedLine(),
                    const SizedBox(height: 4),
                    _buildEditableText(
                      keyName: 'totalFee',
                      child: _buildUiKeyValue(
                        'Total Fee',
                        'Rs. ${currencyFormat.format(_totalFee)}',
                      ),
                    ),
                    _buildEditableText(
                      keyName: 'remainingDue',
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.black, width: 0.8),
                            bottom: BorderSide(color: Colors.black, width: 0.8),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'REMAINING:',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Courier',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            Text(
                              'Rs. ${currencyFormat.format(_totalRemaining)}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Courier',
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Cashier: ______',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 9,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Parent: ______',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _freeTextController.text.isEmpty
                            ? 'Notice body is empty...'
                            : _freeTextController.text,
                        style: const TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 10.5,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Authorized Signature',
                        style: TextStyle(fontFamily: 'Courier', fontSize: 9.5),
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),
                  _buildDashedLine(),
                  const SizedBox(height: 6),
                  const Text(
                    'Thank you for your cooperation.',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 9.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
        if (_layoutEditorEnabled && activeItem != null)
          Positioned(
            left: 12,
            bottom: 12,
            child: Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Move left',
                      onPressed: () => _updateSelectedLayout(
                        dx: _layoutController.item(activeItem).dx - 4,
                      ),
                      icon: const Icon(Icons.keyboard_arrow_left),
                    ),
                    IconButton(
                      tooltip: 'Move right',
                      onPressed: () => _updateSelectedLayout(
                        dx: _layoutController.item(activeItem).dx + 4,
                      ),
                      icon: const Icon(Icons.keyboard_arrow_right),
                    ),
                    IconButton(
                      tooltip: 'Move up',
                      onPressed: () => _updateSelectedLayout(
                        dy: _layoutController.item(activeItem).dy - 4,
                      ),
                      icon: const Icon(Icons.keyboard_arrow_up),
                    ),
                    IconButton(
                      tooltip: 'Move down',
                      onPressed: () => _updateSelectedLayout(
                        dy: _layoutController.item(activeItem).dy + 4,
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down),
                    ),
                    IconButton(
                      tooltip: 'Decrease horizontal spacing',
                      onPressed: () => _updateSelectedLayout(
                        hPad:
                            (_layoutController
                                        .item(activeItem)
                                        .horizontalPadding -
                                    2)
                                .clamp(0.0, 60.0),
                      ),
                      icon: const Icon(Icons.remove),
                    ),
                    IconButton(
                      tooltip: 'Increase horizontal spacing',
                      onPressed: () => _updateSelectedLayout(
                        hPad:
                            (_layoutController
                                        .item(activeItem)
                                        .horizontalPadding +
                                    2)
                                .clamp(0.0, 60.0),
                      ),
                      icon: const Icon(Icons.add),
                    ),
                    IconButton(
                      tooltip: 'Close editor',
                      onPressed: () => setState(() {
                        _layoutEditorEnabled = false;
                        _selectedLayoutItemKey = null;
                      }),
                      icon: const Icon(Icons.done),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEditableText({required String keyName, required Widget child}) {
    final item = _layoutController.item(keyName);
    final isSelected =
        _selectedLayoutItemKey == keyName && _layoutEditorEnabled;

    return GestureDetector(
      onLongPress: () => _toggleLayoutEditor(keyName),
      onPanUpdate: isSelected
          ? (details) {
              _updateSelectedLayout(
                dx: item.dx + details.delta.dx,
                dy: item.dy + details.delta.dy,
              );
            }
          : null,
      child: Transform.translate(
        offset: Offset(item.dx, item.dy),
        child: Padding(
          padding: EdgeInsets.only(
            left: item.horizontalPadding,
            top: item.verticalPadding,
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildUiKeyValue(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontFamily: 'Courier', fontSize: 10.5),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'Courier',
                  fontWeight: FontWeight.bold,
                  fontSize: 10.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashedLine() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.0;
        const dashSpace = 3.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.black87),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
      ),
    );
  }
}

// Fallback helper to ensure Offset compatibility across all Flutter versions
Offset dynamicOffset(double dx, double dy) => Offset(dx, dy);

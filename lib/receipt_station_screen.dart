import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'receipt_pdf_service.dart';
import 'receipt_provider.dart';
import 'thermal_receipt_preview.dart';

class ReceiptStationScreen extends StatefulWidget {
  const ReceiptStationScreen({super.key});

  @override
  State<ReceiptStationScreen> createState() => _ReceiptStationScreenState();
}

class _ReceiptStationScreenState extends State<ReceiptStationScreen> {
  late final ReceiptProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = ReceiptProvider();
    _provider.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat('#,##0.00');

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text(
          'Black Copper 80mm Station',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 46,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT PANEL: Compact Form Inputs
          Expanded(
            flex: 6,
            child: Container(
              color: Colors.white,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('1. Header Setup'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _provider.schoolNameController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'School / Header Name',
                        isDense: true,
                        prefixIcon: Icon(Icons.school, size: 18),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _provider.pickLogo,
                          icon: const Icon(Icons.upload, size: 15),
                          label: const Text(
                            'Upload Logo',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF334155),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (_provider.logoBytes != null) ...[
                          Image.memory(
                            _provider.logoBytes!,
                            width: 32,
                            height: 32,
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: _provider.removeLogo,
                            child: const Text(
                              'Remove',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        ] else
                          const Text(
                            'No Logo Selected',
                            style: TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1),
                    const SizedBox(height: 10),

                    _buildSectionHeader('2. Print Template'),
                    const SizedBox(height: 6),
                    ToggleButtons(
                      isSelected: [
                        _provider.templateIndex == 0,
                        _provider.templateIndex == 1,
                      ],
                      onPressed: (index) => _provider.setTemplateIndex(index),
                      borderRadius: BorderRadius.circular(6),
                      selectedColor: Colors.white,
                      fillColor: const Color(0xFF1E3A8A),
                      constraints: const BoxConstraints(
                        minHeight: 34,
                        minWidth: 130,
                      ),
                      children: const [
                        Text(
                          'Fee Receipt',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Notice / Message',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1),
                    const SizedBox(height: 10),

                    // TEMPLATE INPUTS
                    if (_provider.templateIndex == 0) ...[
                      _buildSectionHeader('3. Student & Payment Details'),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _provider.studentNameController,
                              decoration: const InputDecoration(
                                labelText: 'Student Name',
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _provider.fatherNameController,
                              decoration: const InputDecoration(
                                labelText: "Father's Name",
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          // Class / Section Field
                          Expanded(
                            child: TextField(
                              controller: _provider.classSectionController,
                              decoration: const InputDecoration(
                                labelText: 'Class / Section',
                                isDense: true,
                                prefixIcon: Icon(
                                  Icons.class_outlined,
                                  size: 17,
                                ),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _provider.feeMonthController,
                              decoration: const InputDecoration(
                                labelText: 'Fee Month',
                                isDense: true,
                                prefixIcon: Icon(
                                  Icons.calendar_month,
                                  size: 17,
                                ),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _provider.totalFeeController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Total Fee (Rs.)',
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _provider.totalPaidController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Total Paid (Rs.)',
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Computed Balance Due:',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Rs. ${currency.format(_provider.totalRemaining)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _provider.totalRemaining > 0
                                    ? Colors.red[700]
                                    : Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      _buildSectionHeader('3. Notice Body'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _provider.noticeTextController,
                        maxLines: 7,
                        decoration: const InputDecoration(
                          labelText: 'Custom Notice Message',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
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

          // RIGHT PANEL: Live Preview & Action
          Expanded(
            flex: 5,
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: ThermalReceiptPreview(
                        receipt: _provider.currentReceipt,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () => ReceiptPdfService.printThermalReceipt(
                        _provider.currentReceipt,
                      ),
                      icon: const Icon(
                        Icons.print,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: const Text(
                        'PRINT TO BLACK COPPER (80mm)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
      ),
    );
  }
}

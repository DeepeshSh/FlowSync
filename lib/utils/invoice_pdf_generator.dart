import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/invoice_model.dart';

class InvoicePdfGenerator {
  static Future<Uint8List> generate(
    Invoice invoice, {
    String businessName = "FlowSync Sanitary Solutions",
    String gstin = "27AAAAA0000A1Z5",
    String address = "Industrial Area, Phase 2, Mumbai - 400001",
    String phone = "+91 98765 43210",
  }) async {
    final pdf = pw.Document();

    final dateFormatted = invoice.date != null
        ? DateFormat('dd/MM/yyyy').format(invoice.date!)
        : DateFormat('dd/MM/yyyy').format(DateTime.now());

    final primaryColor = PdfColor.fromInt(0xFF2563EB);
    final slateDark = PdfColor.fromInt(0xFF0F172A);
    final slateMuted = PdfColor.fromInt(0xFF64748B);
    final borderSlate = PdfColor.fromInt(0xFFE2E8F0);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header Row: Business Info & TAX INVOICE title
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      businessName,
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: slateDark,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(address, style: pw.TextStyle(fontSize: 10, color: slateMuted)),
                    pw.Text("GSTIN: $gstin | Phone: $phone",
                        style: pw.TextStyle(fontSize: 10, color: slateMuted)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: pw.BoxDecoration(
                        color: primaryColor,
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Text(
                        invoice.isSale ? "TAX INVOICE" : "PURCHASE BILL",
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      "Invoice #: ${invoice.invoiceNumber}",
                      style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: slateDark),
                    ),
                    pw.Text("Date: $dateFormatted", style: pw.TextStyle(fontSize: 10, color: slateMuted)),
                    pw.Text(
                      "Status: ${invoice.paymentStatus}",
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: invoice.isPaid ? PdfColor.fromInt(0xFF10B981) : PdfColor.fromInt(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 16),
            pw.Divider(color: borderSlate, thickness: 1),
            pw.SizedBox(height: 12),

            // Billed To / Party Box
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromInt(0xFFF8FAFC),
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: borderSlate),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    invoice.isSale ? "BILLED TO:" : "PURCHASED FROM:",
                    style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: slateMuted),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    invoice.partyName,
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: slateDark),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 16),

            // Items Table
            pw.Table(
              border: pw.TableBorder.all(color: borderSlate, width: 0.5),
              children: [
                // Table Header
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFFF1F5F9)),
                  children: [
                    _tableCell("#", isHeader: true, width: 24),
                    _tableCell("Product / Item Description", isHeader: true),
                    _tableCell("Qty", isHeader: true, align: pw.TextAlign.center, width: 40),
                    _tableCell("Rate (Rs.)", isHeader: true, align: pw.TextAlign.right, width: 70),
                    _tableCell("GST %", isHeader: true, align: pw.TextAlign.center, width: 45),
                    _tableCell("Amount (Rs.)", isHeader: true, align: pw.TextAlign.right, width: 80),
                  ],
                ),
                // Table Rows
                ...invoice.items.asMap().entries.map((entry) {
                  final index = entry.key + 1;
                  final item = entry.value;
                  return pw.TableRow(
                    children: [
                      _tableCell("$index", align: pw.TextAlign.center),
                      _tableCell(item.productName),
                      _tableCell("${item.quantity}", align: pw.TextAlign.center),
                      _tableCell(item.rate.toStringAsFixed(2), align: pw.TextAlign.right),
                      _tableCell("${item.gstRate.toStringAsFixed(0)}%", align: pw.TextAlign.center),
                      _tableCell(item.amount.toStringAsFixed(2), align: pw.TextAlign.right),
                    ],
                  );
                }),
              ],
            ),

            pw.SizedBox(height: 16),

            // Totals Section
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Notes block
                pw.Expanded(
                  child: invoice.notes.isNotEmpty
                      ? pw.Container(
                          padding: const pw.EdgeInsets.all(10),
                          decoration: pw.BoxDecoration(
                            color: PdfColor.fromInt(0xFFF8FAFC),
                            borderRadius: pw.BorderRadius.circular(6),
                            border: pw.Border.all(color: borderSlate),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text("Notes / Terms:",
                                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: slateDark)),
                              pw.SizedBox(height: 2),
                              pw.Text(invoice.notes, style: pw.TextStyle(fontSize: 9, color: slateMuted)),
                            ],
                          ),
                        )
                      : pw.SizedBox(),
                ),
                pw.SizedBox(width: 24),
                // Calculation totals
                pw.Container(
                  width: 210,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFF8FAFC),
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: borderSlate),
                  ),
                  child: pw.Column(
                    children: [
                      _summaryRow("Subtotal", "Rs. ${invoice.subtotal.toStringAsFixed(2)}"),
                      pw.SizedBox(height: 6),
                      _summaryRow("GST Total", "Rs. ${invoice.gstTotal.toStringAsFixed(2)}"),
                      pw.SizedBox(height: 8),
                      pw.Divider(color: borderSlate, thickness: 0.5),
                      pw.SizedBox(height: 6),
                      _summaryRow(
                        "Grand Total",
                        "Rs. ${invoice.grandTotal.toStringAsFixed(2)}",
                        isBold: true,
                        fontSize: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 24),

            // Footer & Signatory Block
            pw.Divider(color: borderSlate, thickness: 1),
            pw.SizedBox(height: 12),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  "This is a computer generated invoice powered by FlowSync.",
                  style: pw.TextStyle(fontSize: 8, color: slateMuted),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text("For $businessName",
                        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: slateDark)),
                    pw.SizedBox(height: 24),
                    pw.Text("Authorized Signatory", style: pw.TextStyle(fontSize: 8, color: slateMuted)),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _tableCell(
    String text, {
    bool isHeader = false,
    pw.TextAlign align = pw.TextAlign.left,
    double? width,
  }) {
    return pw.Container(
      width: width,
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 7),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: isHeader ? 9 : 8.5,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColor.fromInt(0xFF0F172A) : PdfColor.fromInt(0xFF334155),
        ),
      ),
    );
  }

  static pw.Widget _summaryRow(String label, String value, {bool isBold = false, double fontSize = 10}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: isBold ? PdfColor.fromInt(0xFF0F172A) : PdfColor.fromInt(0xFF64748B),
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: isBold ? PdfColor.fromInt(0xFF2563EB) : PdfColor.fromInt(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}

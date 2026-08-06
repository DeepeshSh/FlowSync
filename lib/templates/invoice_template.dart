import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/invoice_data.dart';

class InvoiceTemplate {
  InvoiceTemplate._();

 static Future<Uint8List> buildInvoice({
  required InvoiceData invoice,
}) async {
    final pdf = pw.Document();

    final currency =
        NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );

    final dateFormat =
        DateFormat("dd MMM yyyy");

    pdf.addPage(
      pw.MultiPage(
        pageTheme: _pageTheme(),

        margin: const pw.EdgeInsets.all(30),

        build: (context) {
          return [

          _buildHeader(
  invoice,
  dateFormat,
),

            pw.SizedBox(height: 18),

           _buildPartySection(
  invoice,
),

            pw.SizedBox(height: 20),

            _buildItemsTable(
              invoice,
              currency,
            ),

            pw.SizedBox(height: 20),

           _buildTotals(
  invoice,
  currency,
),

            pw.SizedBox(height: 20),

            _buildFooter(
              invoice,
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.PageTheme _pageTheme() {
    return pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(30),
      theme: pw.ThemeData.withFont(
        base: pw.Font.helvetica(),
        bold: pw.Font.helveticaBold(),
      ),
    );
  }
    static pw.Widget _buildHeader(
  InvoiceData invoice,
  DateFormat dateFormat,
) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue900,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [

          pw.Row(
            mainAxisAlignment:
                pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment:
                pw.CrossAxisAlignment.start,
            children: [

              pw.Column(
                crossAxisAlignment:
                    pw.CrossAxisAlignment.start,
                children: [

                  pw.Text(
                    "FlowSync ERP",
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),

                  pw.SizedBox(height: 4),

                  pw.Text(
                    "Smart Business. Smooth Flow.",
                    style: const pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),

              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius:
                      pw.BorderRadius.circular(8),
                ),
                child: pw.Text(
                  invoice.invoiceTitle.toUpperCase(),
                  style: pw.TextStyle(
                    color: PdfColors.blue900,
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 20),

          pw.Divider(
            color: PdfColors.white,
          ),

          pw.SizedBox(height: 15),

          pw.Row(
            children: [

              pw.Expanded(
                child: _buildInfoTile(
                  "Invoice No.",
                  invoice.invoiceNumber,
                ),
              ),

              pw.Expanded(
                child: _buildInfoTile(
                  "Date",
                  dateFormat.format(
                   invoice.invoiceDate,
                  ),
                ),
              ),

              pw.Expanded(
                child: _buildInfoTile(
                  "Payment Status",
                  invoice.paymentStatus,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoTile(
    String title,
    String value,
  ) {
    return pw.Column(
      crossAxisAlignment:
          pw.CrossAxisAlignment.start,
      children: [

        pw.Text(
          title,
          style: const pw.TextStyle(
            color: PdfColors.grey300,
            fontSize: 9,
          ),
        ),

        pw.SizedBox(height: 4),

        pw.Text(
          value,
          style: pw.TextStyle(
            color: PdfColors.white,
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }
  static pw.Widget _buildPartySection(
  InvoiceData invoice,
) {
    final party = invoice.party;

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: PdfColors.grey300,
        ),
        borderRadius:
            pw.BorderRadius.circular(10),
        color: PdfColors.grey50,
      ),
      child: pw.Column(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: [

          pw.Text(
           invoice.partyTitle.toUpperCase(),
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),

          pw.SizedBox(height: 12),

          pw.Row(
            crossAxisAlignment:
                pw.CrossAxisAlignment.start,
            children: [

              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment:
                      pw.CrossAxisAlignment.start,
                  children: [

                    _detailRow(
                      "Name",
                      party.name,
                    ),

                    _detailRow(
                      "Phone",
                      party.phone,
                    ),

                    if (party.email.isNotEmpty)
                      _detailRow(
                        "Email",
                        party.email,
                      ),
                  ],
                ),
              ),

              pw.SizedBox(width: 30),

              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment:
                      pw.CrossAxisAlignment.start,
                  children: [

                    _detailRow(
                      "Address",
                      party.address,
                    ),

                    if (party.gstNumber.isNotEmpty)
                      _detailRow(
                        "GST No.",
                        party.gstNumber,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _detailRow(
    String title,
    String value,
  ) {
    return pw.Padding(
      padding:
          const pw.EdgeInsets.only(
        bottom: 8,
      ),
      child: pw.Row(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: [

          pw.SizedBox(
            width: 70,
            child: pw.Text(
              "$title :",
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),
          ),

          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
    static pw.Widget _buildItemsTable(
   InvoiceData invoice,
    NumberFormat currency,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(
        color: PdfColors.grey300,
        width: 0.6,
      ),
      columnWidths: {
        0: const pw.FixedColumnWidth(28),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FixedColumnWidth(40),
        4: const pw.FixedColumnWidth(65),
        5: const pw.FixedColumnWidth(75),
      },
      children: [

        // HEADER
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColors.blue900,
          ),
          children: [
            _tableHeader("Sr"),
            _tableHeader("Product"),
            _tableHeader("Variant"),
            _tableHeader("Qty"),
            _tableHeader("Rate"),
            _tableHeader("Total"),
          ],
        ),

        // DATA
        ...List.generate(
          invoice.items.length,
          (index) {
            final item = invoice.items[index];

            return pw.TableRow(
              decoration: pw.BoxDecoration(
                color: index.isEven
                    ? PdfColors.white
                    : PdfColors.grey100,
              ),
              children: [

                _tableCell(
                  "${index + 1}",
                  center: true,
                ),

                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Column(
                    crossAxisAlignment:
                        pw.CrossAxisAlignment.start,
                    children: [

                      pw.Text(
                        item.productName,
                        style: pw.TextStyle(
                          fontWeight:
                              pw.FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),

                      if (item.productNote
                          .trim()
                          .isNotEmpty) ...[

                        pw.SizedBox(height: 3),

                        pw.Text(
                          "Note: ${item.productNote}",
                          style: pw.TextStyle(
                            color:
                                PdfColors.grey700,
                            fontSize: 8,
                            fontStyle:
                                pw.FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                _tableCell(
                  item.variantName.isEmpty
                      ? "-"
                      : item.variantName,
                ),

                _tableCell(
                  item.quantity.toString(),
                  center: true,
                ),

                _tableCell(
                  currency.format(item.rate),
                  right: true,
                ),

                _tableCell(
                  currency.format(item.total),
                  right: true,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  static pw.Widget _tableHeader(
    String text,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontWeight: pw.FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  static pw.Widget _tableCell(
    String text, {
    bool center = false,
    bool right = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textAlign: center
            ? pw.TextAlign.center
            : right
                ? pw.TextAlign.right
                : pw.TextAlign.left,
        style: const pw.TextStyle(
          fontSize: 9,
        ),
      ),
    );
  }
   static pw.Widget _buildTotals(
  InvoiceData invoice,
  NumberFormat currency,
){
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [

        pw.Expanded(
          flex: 3,
          child: pw.Container(),
        ),

        pw.Expanded(
          flex: 2,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(10),
              border: pw.Border.all(
                color: PdfColors.grey400,
              ),
            ),
            child: pw.Column(
              children: [

                _summaryRow(
                  "Subtotal",
                  currency.format(invoice.subtotal),
                ),
if (invoice.discount > 0) ...[
  pw.SizedBox(height: 8),

  _summaryRow(
    "Discount",
    "- ${currency.format(invoice.discount)}",
    valueColor: PdfColors.green700,
  ),
],
                pw.SizedBox(height: 8),

              if (invoice.gstAmount > 0) ...[
  _summaryRow(
    "GST",
    currency.format(invoice.gstAmount),
  ),
],

                pw.SizedBox(height: 8),

               if (invoice.transportCost > 0) ...[
  _summaryRow(
    "Transport Cost",
    currency.format(invoice.transportCost),
  ),
],
                pw.Divider(),

                _summaryRow(
                  "Invoice Total",
                  currency.format(invoice.grandTotal),
                  isBold: true,
                ),

                pw.SizedBox(height: 8),

            if (invoice.advanceAmount > 0) ...[
  _summaryRow(
    invoice.advanceTitle,
    "- ${currency.format(invoice.advanceAmount)}",
    valueColor: PdfColors.red700,
  ),
],

                pw.Divider(
                  thickness: 1.2,
                ),

                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 8,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue900,
                    borderRadius:
                        pw.BorderRadius.circular(8),
                  ),
                  child: pw.Row(
                    mainAxisAlignment:
                        pw.MainAxisAlignment.spaceBetween,
                    children: [

                      pw.Text(
                        "Balance Due",
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight:
                              pw.FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),

                      pw.Text(
                        currency.format(
                          invoice.balanceDue,
                        ),
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight:
                              pw.FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _summaryRow(
    String title,
    String value, {
    bool isBold = false,
    PdfColor? valueColor,
  }) {
    return pw.Row(
      mainAxisAlignment:
          pw.MainAxisAlignment.spaceBetween,
      children: [

        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: isBold
                ? pw.FontWeight.bold
                : pw.FontWeight.normal,
          ),
        ),

        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 10,
            color: valueColor ?? PdfColors.black,
            fontWeight: isBold
                ? pw.FontWeight.bold
                : pw.FontWeight.normal,
          ),
        ),
      ],
    );
  }
    static pw.Widget _buildFooter(
    InvoiceData invoice,
  ) {
    return pw.Column(
      crossAxisAlignment:
          pw.CrossAxisAlignment.start,
      children: [

        if (invoice.notes.trim().isNotEmpty) ...[

          pw.Text(
            "Notes",
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),

          pw.SizedBox(height: 6),

          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius:
                  pw.BorderRadius.circular(8),
              border: pw.Border.all(
                color: PdfColors.grey300,
              ),
            ),
            child: pw.Text(
              invoice.notes,
              style: const pw.TextStyle(
                fontSize: 10,
              ),
            ),
          ),

          pw.SizedBox(height: 20),
        ],

        pw.Divider(),

        pw.SizedBox(height: 10),

        pw.Row(
          mainAxisAlignment:
              pw.MainAxisAlignment.spaceBetween,
          children: [

            pw.Column(
              crossAxisAlignment:
                  pw.CrossAxisAlignment.start,
              children: [

                pw.Text(
                  "Generated by FlowSync ERP",
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.blue900,
                    fontWeight:
                        pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 3),

                pw.Text(
                  "This is a computer generated invoice.",
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),

            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue900,
                borderRadius:
                    pw.BorderRadius.circular(6),
              ),
              child: pw.Text(
                "FlowSync",
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontWeight:
                      pw.FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
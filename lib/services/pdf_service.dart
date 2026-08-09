import 'dart:io';
import 'dart:typed_data';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import 'package:pdf/pdf.dart';

import 'package:printing/printing.dart';


import '../models/invoice_data.dart';
import '../models/purchase_model.dart';
import '../models/sale_model.dart';
import '../templates/invoice_template.dart';

class PdfService {
  PdfService._();

  static final PdfService instance = PdfService._();

  //==========================================================
  // Creates a unique file inside the application documents
  // directory and writes the PDF bytes.
  //==========================================================

  Future<File> _savePdf({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final directory =
        await getApplicationDocumentsDirectory();

    final file = File(
      "${directory.path}/$fileName",
    );

    await file.writeAsBytes(
      bytes,
      flush: true,
    );

    return file;
  }

  //==========================================================
  // PURCHASE PDF
  //==========================================================

  Future<File> generatePurchasePdf(
    Purchase purchase,
  ) async {
    final invoice =
        InvoiceData.fromPurchase(
      purchase,
    );

    final pdfBytes =
        await InvoiceTemplate.buildInvoice(
      invoice: invoice,
    );

    final fileName =
        "Purchase_${purchase.purchaseNumber}.pdf";

    return await _savePdf(
      fileName: fileName,
      bytes: pdfBytes,
    );
  }
    //==========================================================
  // SALES PDF
  //==========================================================

  Future<File> generateSalesPdf(
    Sale sale,
  ) async {
    final invoice =
        InvoiceData.fromSale(
      sale,
    );

    final pdfBytes =
        await InvoiceTemplate.buildInvoice(
      invoice: invoice,
    );

    final fileName =
        "Sale_${sale.saleNumber}.pdf";

    return await _savePdf(
      fileName: fileName,
      bytes: pdfBytes,
    );
  }

  //==========================================================
  // OPEN PDF
  //==========================================================

  Future<void> openPdf(
    File file,
  ) async {
    final result =
        await OpenFilex.open(
      file.path,
    );

    if (result.type !=
        ResultType.done) {
      throw Exception(
        result.message,
      );
    }
  }

  //==========================================================
  // SHARE PDF
  //==========================================================

 Future<void> sharePdf(File file) async {
  // Sharing temporarily disabled.
}
    //==========================================================
  // PRINT PDF
  //==========================================================

  Future<void> printPdf(
    File file,
  ) async {
    final bytes =
        await file.readAsBytes();

   await Printing.layoutPdf(
  onLayout: (PdfPageFormat format) async {
    return bytes;
  },
);
  }

  //==========================================================
  // PDF PREVIEW
  //==========================================================

 Future<void> previewPdf(
  Uint8List pdfBytes,
) async {
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async {
      return pdfBytes;
    },
  );
}
  //==========================================================
  // PREVIEW PURCHASE PDF
  //==========================================================

  Future<void> previewPurchasePdf(
    Purchase purchase,
  ) async {
    final invoice =
        InvoiceData.fromPurchase(
      purchase,
    );

    final pdfBytes =
        await InvoiceTemplate.buildInvoice(
      invoice: invoice,
    );

    await previewPdf(
      pdfBytes,
    );
  }

  //==========================================================
  // PREVIEW SALES PDF
  //==========================================================

  Future<void> previewSalesPdf(
    Sale sale,
  ) async {
    final invoice =
        InvoiceData.fromSale(
      sale,
    );

    final pdfBytes =
        await InvoiceTemplate.buildInvoice(
      invoice: invoice,
    );

    await previewPdf(
      pdfBytes,
    );
  }
}
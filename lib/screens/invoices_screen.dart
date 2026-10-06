import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../models/invoice_model.dart';
import '../services/invoice_service.dart';
import '../utils/app_theme.dart';
import '../utils/invoice_pdf_generator.dart';
import '../widgets/custom_app_bar.dart';
import 'create_invoice_screen.dart';

class InvoicesScreen extends StatefulWidget {
  final List<Invoice>? initialInvoices;

  const InvoicesScreen({super.key, this.initialInvoices});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> with SingleTickerProviderStateMixin {
  final InvoiceService _invoiceService = InvoiceService();
  late TabController _tabController;

  List<Invoice> _invoices = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });

    if (widget.initialInvoices != null) {
      _invoices = List.from(widget.initialInvoices!);
    } else {
      _loadInvoices();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInvoices() async {
    setState(() => _isLoading = true);
    try {
      final list = await _invoiceService.getInvoices();
      if (mounted) {
        setState(() {
          _invoices = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Invoice> get _filteredInvoices {
    if (_tabController.index == 1) {
      return _invoices.where((i) => i.isSale).toList();
    } else if (_tabController.index == 2) {
      return _invoices.where((i) => i.isPurchase).toList();
    }
    return _invoices;
  }

  double get _totalInvoiced {
    return _invoices.fold<double>(0.0, (sum, i) => sum + i.grandTotal);
  }

  double get _totalSales {
    return _invoices.where((i) => i.isSale).fold<double>(0.0, (sum, i) => sum + i.grandTotal);
  }

  double get _totalUnpaid {
    return _invoices.where((i) => !i.isPaid).fold<double>(0.0, (sum, i) => sum + i.grandTotal);
  }

  Future<void> _viewInvoicePdf(Invoice invoice) async {
    final pdfBytes = await InvoicePdfGenerator.generate(invoice);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: '${invoice.invoiceNumber}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: "Invoices & Billing",
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            tooltip: "Refresh",
            onPressed: _loadInvoices,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        icon: const Icon(Icons.add, size: 18),
        label: const Text(
          "New Invoice",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
        ),
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (ctx) => const CreateInvoiceScreen()),
          );
          if (res == true && mounted) {
            _loadInvoices();
          }
        },
      ),
      body: Column(
        children: [
          _buildSummaryBar(),
          _buildTabBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _filteredInvoices.isEmpty
                    ? _buildEmptyState()
                    : _buildInvoiceList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Total Invoiced", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              const SizedBox(height: 4),
              Text(
                "₹${_totalInvoiced.toStringAsFixed(0)}",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
          Container(width: 1, height: 28, color: AppColors.cardBorder),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Sales Volume", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              const SizedBox(height: 4),
              Text(
                "₹${_totalSales.toStringAsFixed(0)}",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
              ),
            ],
          ),
          Container(width: 1, height: 28, color: AppColors.cardBorder),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text("Unpaid Bills", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              const SizedBox(height: 4),
              Text(
                "₹${_totalUnpaid.toStringAsFixed(0)}",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(6),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
        tabs: const [
          Tab(text: "All"),
          Tab(text: "Sales Invoices"),
          Tab(text: "Purchase Bills"),
        ],
      ),
    );
  }

  Widget _buildInvoiceList() {
    final list = _filteredInvoices;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 80),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, idx) {
        final invoice = list[idx];
        final dateStr = invoice.date != null
            ? DateFormat('dd/MM/yyyy').format(invoice.date!)
            : 'Recent';

        Color statusColor;
        Color statusBg;
        Color statusBorder;
        if (invoice.isPaid) {
          statusColor = const Color(0xFF10B981);
          statusBg = const Color(0xFFECFDF5);
          statusBorder = const Color(0xFFA7F3D0);
        } else if (invoice.isUnpaid) {
          statusColor = const Color(0xFFEF4444);
          statusBg = const Color(0xFFFEF2F2);
          statusBorder = const Color(0xFFFECACA);
        } else {
          statusColor = const Color(0xFFD97706);
          statusBg = const Color(0xFFFFFBEB);
          statusBorder = const Color(0xFFFDE68A);
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: invoice.isSale ? const Color(0xFFECFDF5) : const Color(0xFFE8EEF5),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: invoice.isSale ? const Color(0xFFA7F3D0) : const Color(0xFFBFDBFE),
                          ),
                        ),
                        child: Icon(
                          invoice.isSale ? Icons.receipt_long_rounded : Icons.shopping_bag_outlined,
                          size: 16,
                          color: invoice.isSale ? const Color(0xFF10B981) : AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            invoice.invoiceNumber,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dateStr,
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: invoice.isSale ? const Color(0xFFECFDF5) : const Color(0xFFE8EEF5),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: invoice.isSale ? const Color(0xFFA7F3D0) : const Color(0xFFBFDBFE),
                      ),
                    ),
                    child: Text(
                      invoice.isSale ? "SALE" : "PURCHASE",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: invoice.isSale ? const Color(0xFF10B981) : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.storefront_outlined, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            invoice.partyName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "${invoice.items.length} items",
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, color: AppColors.cardBorder),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Grand Total", style: TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                      const SizedBox(height: 2),
                      Text(
                        "₹${invoice.grandTotal.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: statusBorder),
                        ),
                        child: Text(
                          invoice.paymentStatus,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.primary, size: 18),
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: EdgeInsets.zero,
                        tooltip: "View / Print PDF",
                        onPressed: () => _viewInvoicePdf(invoice),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EEF5),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Icon(Icons.receipt_long_outlined, size: 44, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            const Text(
              "No Invoices Generated",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              "Create your first GST sales invoice or purchase bill with itemized calculations and instant PDF generation.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
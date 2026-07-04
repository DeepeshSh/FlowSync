import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../models/variant_model.dart';
import '../models/warehouse_model.dart';

import '../services/variant_service.dart';
import '../services/warehouse_service.dart';

import 'add_edit_variant_screen.dart';

class ManageVariantsScreen extends StatefulWidget {
  final Product product;

  const ManageVariantsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ManageVariantsScreen> createState() => _ManageVariantsScreenState();
}

class _ManageVariantsScreenState extends State<ManageVariantsScreen> {
  final VariantService _variantService = VariantService();
  final WarehouseService _warehouseService = WarehouseService();
  final TextEditingController _searchController = TextEditingController();

  List<Variant> _variants = [];
  List<Variant> _filteredVariants = [];
  List<Warehouse> _warehouses = [];
  Warehouse? _selectedWarehouse;
  bool _isLoading = true;

  double get totalInventoryValue {
    double total = 0;
    for (final variant in _filteredVariants) {
      total += variant.stock * variant.purchasePrice;
    }
    return total;
  }

  int get totalStock {
    int total = 0;
    for (final variant in _filteredVariants) {
      total += variant.stock;
    }
    return total;
  }

  int get totalVariants => _filteredVariants.length;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final variants = await _variantService.getVariantsByProduct(
        widget.product.id,
      );
      final warehouses = await _warehouseService.getWarehouses();

      setState(() {
        _variants = variants;
        _filteredVariants = variants;
        _warehouses = warehouses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _filterVariants() {
    List<Variant> filtered = List.from(_variants);

    if (_selectedWarehouse != null) {
      filtered = filtered.where((variant) {
        return variant.warehouseId == _selectedWarehouse!.id;
      }).toList();
    }

    if (_searchController.text.trim().isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((variant) {
        return variant.variantName.toLowerCase().contains(query) ||
            variant.sku.toLowerCase().contains(query);
      }).toList();
    }

    setState(() {
      _filteredVariants = filtered;
    });
  }

  Future<void> _deleteVariant(Variant variant) async {
    final delete = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Delete Variant?"),
          content: Text("Delete ${variant.variantName} permanently?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (delete != true) return;

    await _variantService.deleteVariant(variant.id);
    _loadData();
  }

 Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 16),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Standard Navigation Top Bar
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
                ),
                const SizedBox(width: 4),
                const Text(
                  "Manage Variants",
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Text-Only Product Information Layer
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "SKU: ${widget.product.sku}",
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                    ),
                  ),
                  
                  // Conditional spacing and status chips
                  if (widget.product.categoryName.trim().isNotEmpty || 
                      widget.product.brandName.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (widget.product.categoryName.trim().isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.product.categoryName,
                              style: const TextStyle(
                                color: Color(0xFF475569),
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        if (widget.product.brandName.trim().isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.product.brandName,
                              style: const TextStyle(
                                color: Color(0xFF475569),
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _statCard("Variants", totalVariants.toString(), Icons.layers),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _statCard("Stock", totalStock.toString(), Icons.inventory),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _statCard(
              "Value",
              "₹${totalInventoryValue.toStringAsFixed(0)}",
              Icons.currency_rupee,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF2563EB)),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _filterVariants(),
              decoration: InputDecoration(
                hintText: "Search variant...",
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                fillColor: Colors.white,
                filled: true,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<Warehouse>(
              value: _selectedWarehouse,
              hint: const Text("Warehouse", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
              isExpanded: true,
              items: [
                const DropdownMenuItem<Warehouse>(
                  value: null,
                  child: Text("All Warehouses", style: TextStyle(fontSize: 13)),
                ),
                ..._warehouses.map((w) {
                  return DropdownMenuItem<Warehouse>(
                    value: w,
                    child: Text(w.name, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedWarehouse = value;
                  _filterVariants();
                });
              },
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantList() {
    if (_filteredVariants.isEmpty) {
      return const Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.layers_clear_outlined, size: 48, color: Color(0xFF94A3B8)),
              SizedBox(height: 12),
              Text(
                "No variants found",
                style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        itemCount: _filteredVariants.length,
        itemBuilder: (context, index) {
          final variant = _filteredVariants[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        variant.variantName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "SKU: ${variant.sku}",
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "Stock: ${variant.stock}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF334155)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "₹${variant.sellingPrice.toStringAsFixed(2)}",
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF10B981)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Color(0xFF2563EB), size: 20),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEditVariantScreen(
                              product: widget.product,
                              variant: variant,
                            ),
                          ),
                        );
                        _loadData();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                      onPressed: () => _deleteVariant(variant),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2563EB),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditVariantScreen(
                product: widget.product,
              ),
            ),
          );
          _loadData();
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Variant", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2563EB)),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              color: const Color(0xFF2563EB),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 18),
                  _buildStats(),
                  _buildSearchSection(),
                  _buildVariantList(),
                ],
              ),
            ),
    );
  }
}
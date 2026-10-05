import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/product_model.dart';
import '../services/movement_service.dart';
import '../services/notification_service.dart';
import '../services/product_service.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_app_bar.dart';
import 'edit_product_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  final MovementService? movementService;
  final List<dynamic>? initialMovements;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    this.movementService,
    this.initialMovements,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late Product _product;
  late final MovementService _movementService;
  List<dynamic> _movements = [];
  bool _isLoadingMovements = false;
  bool _hasUpdatedStock = false;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _movementService = widget.movementService ?? MovementService();
    if (widget.initialMovements != null) {
      _movements = List.from(widget.initialMovements!);
    } else {
      _loadMovements();
    }
  }

  Future<void> _loadMovements() async {
    if (!mounted) return;
    setState(() {
      _isLoadingMovements = true;
    });

    try {
      final movements = await _movementService.getProductMovements(_product.id);
      if (mounted) {
        setState(() {
          _movements = movements;
          _isLoadingMovements = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingMovements = false;
        });
      }
    }
  }

  Future<void> _handleDeleteProduct() async {
    final deleted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isDeleting = false;
        return StatefulBuilder(
          builder: (builderContext, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              title: const Text(
                "Delete Product",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              content: isDeleting
                  ? Row(
                      children: const [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 16),
                        Text(
                          "Deleting product...",
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    )
                  : const Text(
                      "Are you sure you want to delete this product? This action cannot be undone.",
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
              actions: isDeleting
                  ? null
                  : [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          setDialogState(() {
                            isDeleting = true;
                          });

                          try {
                            final success = await ProductService().deleteProduct(widget.product.id);
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext, success);
                            }
                          } catch (e) {
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext, false);
                            }
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Failed to delete product: $e"),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                        child: const Text("Delete"),
                      ),
                    ],
            );
          },
        );
      },
    );

    if (deleted == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Product deleted successfully"),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  void _openStockBottomSheet({required String type}) {
    final isStockIn = type == 'STOCK_IN';
    final formKey = GlobalKey<FormState>();
    final qtyController = TextEditingController();
    final reasonController = TextEditingController();
    final referenceController = TextEditingController();

    final presetReasons = isStockIn
        ? ["Supplier Restock", "Purchase Order", "Customer Return", "Inventory Correction"]
        : ["Retail Sale", "Broken / Damaged", "Customer Delivery", "Defective Return"];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (sheetContext) {
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.cardBorder,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isStockIn
                                  ? const Color(0xFFECFDF5)
                                  : const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isStockIn
                                    ? const Color(0xFFA7F3D0)
                                    : const Color(0xFFFDE68A),
                              ),
                            ),
                            child: Icon(
                              isStockIn
                                  ? Icons.south_west_rounded
                                  : Icons.north_east_rounded,
                              color: isStockIn
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFD97706),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isStockIn ? "Add Stock (Stock In)" : "Remove Stock (Stock Out)",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Current Available: ${_product.stock} ${_product.unit}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: qtyController,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: _inputDecoration(
                          label: "Quantity (${_product.unit})",
                          hint: "Enter quantity (e.g. 5)",
                          icon: Icons.tag_rounded,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter a quantity";
                          }
                          final parsed = int.tryParse(value.trim());
                          if (parsed == null || parsed <= 0) {
                            return "Quantity must be a positive integer";
                          }
                          if (!isStockIn && parsed > _product.stock) {
                            return "Cannot remove more than available stock (${_product.stock})";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Common Reasons",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: presetReasons.map((reason) {
                          final isSelected = reasonController.text == reason;
                          return ChoiceChip(
                            label: Text(reason),
                            selected: isSelected,
                            selectedColor: isStockIn
                                ? const Color(0xFFECFDF5)
                                : const Color(0xFFFFFBEB),
                            backgroundColor: AppColors.background,
                            showCheckmark: false,
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected
                                  ? (isStockIn ? const Color(0xFF10B981) : const Color(0xFFD97706))
                                  : AppColors.textSecondary,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: isSelected
                                    ? (isStockIn ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A))
                                    : AppColors.cardBorder,
                              ),
                            ),
                            onSelected: (selected) {
                              setSheetState(() {
                                reasonController.text = selected ? reason : "";
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: reasonController,
                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                        decoration: _inputDecoration(
                          label: "Reason / Notes",
                          hint: isStockIn ? "e.g. Vendor Restock" : "e.g. Retail Sale",
                          icon: Icons.notes_rounded,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: referenceController,
                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                        decoration: _inputDecoration(
                          label: "Reference # (Optional)",
                          hint: "e.g. PO-1029, Bill #45",
                          icon: Icons.receipt_outlined,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.cardBorder),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: isSubmitting
                                  ? null
                                  : () => Navigator.pop(sheetContext),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isStockIn
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFD97706),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              onPressed: isSubmitting
                                  ? null
                                  : () async {
                                      if (!formKey.currentState!.validate()) {
                                        return;
                                      }

                                      setSheetState(() {
                                        isSubmitting = true;
                                      });

                                      final qty = int.parse(qtyController.text.trim());
                                      final reason = reasonController.text.trim();
                                      final reference = referenceController.text.trim();
                                      final messenger = ScaffoldMessenger.of(context);
                                      final sheetNavigator = Navigator.of(sheetContext);

                                      try {
                                        final result = await _movementService.recordMovement(
                                          productId: _product.id,
                                          type: type,
                                          quantity: qty,
                                          productName: _product.name,
                                          reason: reason.isNotEmpty ? reason : null,
                                          reference: reference.isNotEmpty ? reference : null,
                                        );

                                        final updatedStockRaw = result['updatedStock'];
                                        final int newStock = updatedStockRaw is int
                                            ? updatedStockRaw
                                            : (updatedStockRaw as num?)?.toInt() ??
                                                (isStockIn
                                                    ? _product.stock + qty
                                                    : _product.stock - qty);

                                        if ((type == 'STOCK_OUT' || type == 'DAMAGE') && newStock < 10) {
                                          NotificationService().showLowStockAlert(
                                            productName: _product.name,
                                            remainingStock: newStock,
                                          );
                                        }

                                        if (mounted) {
                                          setState(() {
                                            _product.stock = newStock;
                                            _hasUpdatedStock = true;
                                            if (result['movement'] != null) {
                                              _movements.insert(0, result['movement']);
                                            } else {
                                              _movements.insert(0, {
                                                'productId': _product.id,
                                                'type': type,
                                                'quantity': qty,
                                                'previousStock': isStockIn
                                                    ? newStock - qty
                                                    : newStock + qty,
                                                'newStock': newStock,
                                                'reason': reason,
                                                'reference': reference,
                                                'timestamp': DateTime.now().toIso8601String(),
                                              });
                                            }
                                          });
                                        }

                                        sheetNavigator.pop();

                                        messenger.showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              isStockIn
                                                  ? "Stock In recorded! New stock: $newStock ${_product.unit}"
                                                  : "Stock Out recorded! Remaining: $newStock ${_product.unit}",
                                            ),
                                            backgroundColor: isStockIn
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFFD97706),
                                          ),
                                        );
                                      } catch (err) {
                                        setSheetState(() {
                                          isSubmitting = false;
                                        });
                                        messenger.showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              err.toString().replaceAll("Exception: ", ""),
                                            ),
                                            backgroundColor: AppColors.error,
                                          ),
                                        );
                                      }
                                    },
                              child: isSubmitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      isStockIn ? "Confirm Stock In" : "Confirm Stock Out",
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
      prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error, width: 1.2),
      ),
    );
  }

  Map<String, dynamic> _getTypeBadgeStyle(String type) {
    switch (type.toUpperCase()) {
      case 'STOCK_IN':
        return {
          'label': 'STOCK IN',
          'bgColor': const Color(0xFFECFDF5),
          'borderColor': const Color(0xFFA7F3D0),
          'textColor': const Color(0xFF10B981),
          'sign': '+',
        };
      case 'STOCK_OUT':
        return {
          'label': 'STOCK OUT',
          'bgColor': const Color(0xFFE8EEF5),
          'borderColor': const Color(0xFFBFDBFE),
          'textColor': const Color(0xFF0F294A),
          'sign': '-',
        };
      case 'DAMAGE':
        return {
          'label': 'DAMAGE',
          'bgColor': const Color(0xFFFEF2F2),
          'borderColor': const Color(0xFFFECACA),
          'textColor': const Color(0xFFEF4444),
          'sign': '-',
        };
      case 'RETURN':
        return {
          'label': 'RETURN',
          'bgColor': const Color(0xFFF5F3FF),
          'borderColor': const Color(0xFFDDD6FE),
          'textColor': const Color(0xFF8B5CF6),
          'sign': '+',
        };
      case 'ADJUSTMENT':
      default:
        return {
          'label': 'ADJUSTMENT',
          'bgColor': const Color(0xFFFFFBEB),
          'borderColor': const Color(0xFFFDE68A),
          'textColor': const Color(0xFFD97706),
          'sign': '±',
        };
    }
  }

  String _formatTimestamp(dynamic raw) {
    if (raw == null) return "Recent";
    try {
      final dt = raw is DateTime ? raw : DateTime.parse(raw.toString()).toLocal();
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final year = dt.year;
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$day/$month/$year, $hour:$minute $ampm';
    } catch (_) {
      return raw.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _hasUpdatedStock);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: "Product Details",
          onBack: () => Navigator.pop(context, _hasUpdatedStock),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _product.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (_product.brandName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        _product.brandName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: AppColors.cardBorder),
                    const SizedBox(height: 4),
                    _detailTile("SKU", _product.sku),
                    _detailTile("Category", _product.categoryName),
                    _detailTile("Stock", "${_product.stock} ${_product.unit}"),
                    _detailTile("Purchase Price", "₹${_product.purchasePrice.toStringAsFixed(2)}"),
                    _detailTile("Selling Price", "₹${_product.sellingPrice.toStringAsFixed(2)}"),
                    if (_product.storageLocation.isNotEmpty)
                      _detailTile("Location", _product.storageLocation),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
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
                      children: [
                        const Icon(
                          Icons.receipt_long_outlined,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Movement History",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        if (_isLoadingMovements)
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.refresh, size: 18, color: AppColors.textPrimary),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            onPressed: _loadMovements,
                            tooltip: "Refresh Ledger",
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1, color: AppColors.cardBorder),
                    if (_isLoadingMovements && _movements.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else if (_movements.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Column(
                            children: const [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 36,
                                color: AppColors.textMuted,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "No movement history recorded yet",
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Column(
                        children: _movements.take(5).map((movement) {
                          final type = movement['type']?.toString() ?? 'STOCK_IN';
                          final qty = movement['quantity'] ?? 0;
                          final prevStock = movement['previousStock'] ?? '?';
                          final newStock = movement['newStock'] ?? '?';
                          final reason = movement['reason']?.toString() ?? '';
                          final reference = movement['reference']?.toString() ?? '';
                          final timestamp = movement['timestamp'] ?? movement['createdAt'];
                          final badgeStyle = _getTypeBadgeStyle(type);

                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: AppColors.cardBorder),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: badgeStyle['bgColor'] as Color,
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(
                                                color: badgeStyle['borderColor'] as Color,
                                              ),
                                            ),
                                            child: Text(
                                              badgeStyle['label'] as String,
                                              style: TextStyle(
                                                color: badgeStyle['textColor'] as Color,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Stock: $prevStock → $newStock ${_product.unit}",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (reason.isNotEmpty || reference.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          [
                                            if (reason.isNotEmpty) reason,
                                            if (reference.isNotEmpty) "Ref: $reference",
                                          ].join(" • "),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time_rounded,
                                            size: 12,
                                            color: AppColors.textMuted,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatTimestamp(timestamp),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: badgeStyle['bgColor'] as Color,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: badgeStyle['borderColor'] as Color),
                                  ),
                                  child: Text(
                                    "${badgeStyle['sign']}$qty ${_product.unit}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: badgeStyle['textColor'] as Color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFA7F3D0)),
                        backgroundColor: const Color(0xFFECFDF5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.south_west_rounded, size: 16, color: Color(0xFF10B981)),
                      label: const Text(
                        "Stock In",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      onPressed: () => _openStockBottomSheet(type: 'STOCK_IN'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFBFDBFE)),
                        backgroundColor: const Color(0xFFE8EEF5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.north_east_rounded, size: 16, color: AppColors.primary),
                      label: const Text(
                        "Stock Out",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      onPressed: () => _openStockBottomSheet(type: 'STOCK_OUT'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text(
                    "Edit Product",
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProductScreen(product: _product),
                      ),
                    );

                    if (mounted && result == true) {
                      navigator.pop(true);
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFECACA)),
                    backgroundColor: const Color(0xFFFEF2F2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 16),
                  label: const Text(
                    "Delete Product",
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: _handleDeleteProduct,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12.5,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
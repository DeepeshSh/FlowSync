import 'package:flutter/material.dart';
import '../services/movement_service.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_app_bar.dart';

class ProductLogsScreen extends StatefulWidget {
  final List<dynamic>? initialLogs;

  const ProductLogsScreen({super.key, this.initialLogs});

  @override
  State<ProductLogsScreen> createState() => _ProductLogsScreenState();
}

class _ProductLogsScreenState extends State<ProductLogsScreen> {
  final MovementService _movementService = MovementService();
  bool _isLoading = true;
  List<dynamic> _allMovements = [];
  String? _errorMessage;
  String _selectedFilter = 'ALL';

  final List<String> _filters = [
    'ALL',
    'STOCK_IN',
    'STOCK_OUT',
    'DAMAGE',
    'RETURN',
    'ADJUSTMENT',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialLogs != null) {
      _allMovements = widget.initialLogs!;
      _isLoading = false;
    } else {
      _loadLogs();
    }
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final movements = await _movementService.getAllMovements();
      if (mounted) {
        setState(() {
          _allMovements = movements;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<dynamic> get _filteredMovements {
    if (_selectedFilter == 'ALL') return _allMovements;
    return _allMovements.where((item) => item['type'] == _selectedFilter).toList();
  }

  String _formatDateTime(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    try {
      final dt = DateTime.parse(timestamp.toString()).toLocal();
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final year = dt.year;
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$day/$month/$year, $hour:$minute $ampm';
    } catch (_) {
      return timestamp.toString();
    }
  }

  Map<String, dynamic> _getTypeBadgeStyle(String type) {
    switch (type) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: "Product Logs",
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            tooltip: "Refresh",
            onPressed: _loadLogs,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _errorMessage != null && _allMovements.isEmpty
                    ? _buildErrorView()
                    : _filteredMovements.isEmpty
                        ? _buildEmptyState()
                        : _buildLogsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: _filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            final label = filter == 'ALL'
                ? 'All Logs'
                : filter.replaceAll('_', ' ');

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(label),
                selected: isSelected,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.background,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.cardBorder,
                  ),
                ),
                showCheckmark: false,
                onSelected: (val) {
                  if (val) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLogsList() {
    final list = _filteredMovements;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = list[index];
        final product = item['productId'];
        final String productName = (product is Map ? product['name'] : null) ?? 'Unknown Product';
        final String sku = (product is Map ? product['sku'] : null) ?? 'N/A';
        final String type = (item['type'] as String?) ?? 'ADJUSTMENT';
        final int quantity = (item['quantity'] as num?)?.toInt() ?? 0;
        final int prevStock = (item['previousStock'] as num?)?.toInt() ?? 0;
        final int newStock = (item['newStock'] as num?)?.toInt() ?? 0;
        final String reason = (item['reason'] as String?)?.isNotEmpty == true
            ? item['reason']
            : 'No note recorded';
        final String reference = (item['reference'] as String?) ?? '';
        final String dateStr = _formatDateTime(item['timestamp'] ?? item['createdAt']);

        final badgeStyle = _getTypeBadgeStyle(type);

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "SKU: $sku",
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
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
                      "${badgeStyle['sign']}$quantity pcs",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: badgeStyle['textColor'] as Color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badgeStyle['label'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: badgeStyle['textColor'] as Color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Stock: $prevStock → $newStock pcs",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                reason,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, color: AppColors.cardBorder),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 13,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  if (reference.isNotEmpty)
                    Text(
                      "Ref: $reference",
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
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
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 44,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "No Movement Logs Found",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _selectedFilter == 'ALL'
                  ? "Stock movements, restocks, and adjustments will appear here automatically."
                  : "No movements found for the selected filter '$_selectedFilter'.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            const Text(
              "Failed to load product logs",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? "Unknown error occurred",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _loadLogs,
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}
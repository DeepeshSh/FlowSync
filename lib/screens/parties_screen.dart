import 'package:flutter/material.dart';
import '../models/party_model.dart';
import '../services/party_service.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_app_bar.dart';

class PartiesScreen extends StatefulWidget {
  final List<Party>? initialParties;

  const PartiesScreen({super.key, this.initialParties});

  @override
  State<PartiesScreen> createState() => _PartiesScreenState();
}

class _PartiesScreenState extends State<PartiesScreen> with SingleTickerProviderStateMixin {
  final PartyService _partyService = PartyService();

  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<Party> _parties = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });

    if (widget.initialParties != null) {
      _parties = List.from(widget.initialParties!);
    } else {
      _loadParties();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadParties() async {
    setState(() => _isLoading = true);
    try {
      final list = await _partyService.getParties();
      if (mounted) {
        setState(() {
          _parties = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Party> get _filteredParties {
    List<Party> tabList;
    if (_tabController.index == 1) {
      tabList = _parties.where((p) => p.isSupplier).toList();
    } else if (_tabController.index == 2) {
      tabList = _parties.where((p) => p.isCustomer || p.isDealer).toList();
    } else {
      tabList = _parties;
    }

    if (_searchQuery.trim().isEmpty) return tabList;

    final q = _searchQuery.toLowerCase().trim();
    return tabList.where((p) {
      return p.businessName.toLowerCase().contains(q) ||
          p.name.toLowerCase().contains(q) ||
          p.phone.toLowerCase().contains(q) ||
          p.gstin.toLowerCase().contains(q);
    }).toList();
  }

  double get _totalReceivable {
    return _parties.fold<double>(0.0, (sum, p) {
      return p.currentBalance > 0 ? sum + p.currentBalance : sum;
    });
  }

  double get _totalPayable {
    return _parties.fold<double>(0.0, (sum, p) {
      return p.currentBalance < 0 ? sum + p.currentBalance.abs() : sum;
    });
  }

  void _showAddEditPartySheet({Party? existingParty}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: existingParty?.name ?? '');
    final businessNameController = TextEditingController(text: existingParty?.businessName ?? '');
    final phoneController = TextEditingController(text: existingParty?.phone ?? '');
    final emailController = TextEditingController(text: existingParty?.email ?? '');
    final gstinController = TextEditingController(text: existingParty?.gstin ?? '');
    final addressController = TextEditingController(text: existingParty?.address ?? '');
    final balanceController = TextEditingController(
      text: existingParty != null ? existingParty.currentBalance.toStringAsFixed(0) : '0',
    );

    String selectedType = existingParty?.type ??
        (_tabController.index == 1
            ? 'SUPPLIER'
            : _tabController.index == 2
                ? 'CUSTOMER'
                : 'CUSTOMER');

    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
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
                      Text(
                        existingParty == null ? "Add New Party" : "Edit Party Details",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Manage your supplier, customer, or dealer contact",
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: ['CUSTOMER', 'SUPPLIER', 'DEALER'].map((type) {
                          final isSelected = selectedType == type;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: ChoiceChip(
                                label: Center(
                                  child: Text(
                                    type,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: AppColors.primary,
                                backgroundColor: AppColors.background,
                                showCheckmark: false,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: isSelected ? AppColors.primary : AppColors.cardBorder,
                                  ),
                                ),
                                onSelected: (val) {
                                  if (val) setModalState(() => selectedType = type);
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: businessNameController,
                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                        decoration: _inputDecoration(
                          label: "Firm / Shop / Business Name",
                          hint: "e.g. Royal Sanitary Stores",
                          icon: Icons.storefront_outlined,
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? "Business Name is required" : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: nameController,
                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                        decoration: _inputDecoration(
                          label: "Contact Person Name",
                          hint: "e.g. Rajesh Kumar",
                          icon: Icons.person_outline_rounded,
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? "Contact Person Name is required" : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                        decoration: _inputDecoration(
                          label: "Phone Number",
                          hint: "e.g. +91 98765 43210",
                          icon: Icons.phone_outlined,
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? "Phone number is required" : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: gstinController,
                        textCapitalization: TextCapitalization.characters,
                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                        decoration: _inputDecoration(
                          label: "GSTIN (Optional)",
                          hint: "15-character GSTIN",
                          icon: Icons.badge_outlined,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: addressController,
                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                        decoration: _inputDecoration(
                          label: "Address (Optional)",
                          hint: "City, area, address",
                          icon: Icons.location_on_outlined,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: balanceController,
                        keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                        decoration: _inputDecoration(
                          label: "Opening Balance (₹)",
                          hint: "+ for To Receive, - for To Pay",
                          icon: Icons.account_balance_wallet_outlined,
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) return;
                                  setModalState(() => isSubmitting = true);

                                  final double balance = double.tryParse(balanceController.text.trim()) ?? 0.0;

                                  try {
                                    if (existingParty == null) {
                                      final newParty = Party(
                                        id: '',
                                        name: nameController.text.trim(),
                                        businessName: businessNameController.text.trim(),
                                        type: selectedType,
                                        phone: phoneController.text.trim(),
                                        email: emailController.text.trim(),
                                        gstin: gstinController.text.trim().toUpperCase(),
                                        address: addressController.text.trim(),
                                        currentBalance: balance,
                                      );
                                      final created = await _partyService.createParty(newParty);
                                      if (mounted) {
                                        setState(() {
                                          _parties.insert(0, created);
                                        });
                                      }
                                    } else {
                                      final payload = {
                                        'name': nameController.text.trim(),
                                        'businessName': businessNameController.text.trim(),
                                        'type': selectedType,
                                        'phone': phoneController.text.trim(),
                                        'email': emailController.text.trim(),
                                        'gstin': gstinController.text.trim().toUpperCase(),
                                        'address': addressController.text.trim(),
                                        'currentBalance': balance,
                                      };
                                      final updated = await _partyService.updateParty(existingParty.id, payload);
                                      if (mounted && updated != null) {
                                        setState(() {
                                          final idx = _parties.indexWhere((p) => p.id == existingParty.id);
                                          if (idx != -1) _parties[idx] = updated;
                                        });
                                      }
                                    }

                                    if (ctx.mounted) Navigator.pop(ctx);
                                  } catch (e) {
                                    setModalState(() => isSubmitting = false);
                                    if (ctx.mounted) {
                                      ScaffoldMessenger.of(ctx).showSnackBar(
                                        SnackBar(
                                          content: Text("Error: $e"),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                    }
                                  }
                                },
                          child: Text(
                            isSubmitting
                                ? "Saving..."
                                : existingParty == null
                                    ? "Add Party"
                                    : "Save Changes",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
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

  Future<void> _confirmDeleteParty(Party party) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 22),
            SizedBox(width: 8),
            Text(
              "Delete Party?",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to remove '${party.businessName}'? This action cannot be undone.",
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel", style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _partyService.deleteParty(party.id);
        setState(() {
          _parties.removeWhere((p) => p.id == party.id);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Deleted ${party.businessName}"),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to delete: $e"),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
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
      case 'SUPPLIER':
        return {
          'label': 'SUPPLIER',
          'bgColor': const Color(0xFFF5F3FF),
          'borderColor': const Color(0xFFDDD6FE),
          'textColor': const Color(0xFF8B5CF6),
        };
      case 'DEALER':
        return {
          'label': 'DEALER',
          'bgColor': const Color(0xFFE8EEF5),
          'borderColor': const Color(0xFFBFDBFE),
          'textColor': const Color(0xFF0F294A),
        };
      case 'CUSTOMER':
      default:
        return {
          'label': 'CUSTOMER',
          'bgColor': const Color(0xFFECFDF5),
          'borderColor': const Color(0xFFA7F3D0),
          'textColor': const Color(0xFF10B981),
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: "Parties & Contacts",
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            tooltip: "Refresh",
            onPressed: _loadParties,
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
          "Add Party",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
        ),
        onPressed: () => _showAddEditPartySheet(),
      ),
      body: Column(
        children: [
          _buildSummaryBar(),
          _buildSearchBar(),
          _buildTabBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _filteredParties.isEmpty
                    ? _buildEmptyState()
                    : _buildPartiesList(),
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
              const Text("To Receive", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              const SizedBox(height: 4),
              Text(
                "₹${_totalReceivable.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
          Container(width: 1, height: 28, color: AppColors.cardBorder),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("To Pay", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              const SizedBox(height: 4),
              Text(
                "₹${_totalPayable.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          Container(width: 1, height: 28, color: AppColors.cardBorder),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text("Total Parties", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              const SizedBox(height: 4),
              Text(
                "${_parties.length}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
          });
        },
        decoration: InputDecoration(
          hintText: "Search by firm, name, phone, or GST...",
          hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.textSecondary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18, color: AppColors.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.cardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
          ),
        ),
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
          Tab(text: "Suppliers"),
          Tab(text: "Customers / Dealers"),
        ],
      ),
    );
  }

  Widget _buildPartiesList() {
    final list = _filteredParties;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final party = list[index];
        final badgeStyle = _getTypeBadgeStyle(party.type);

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
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: badgeStyle['bgColor'] as Color,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: badgeStyle['borderColor'] as Color),
                    ),
                    child: Center(
                      child: Text(
                        party.businessName.isNotEmpty
                            ? party.businessName[0].toUpperCase()
                            : "P",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: badgeStyle['textColor'] as Color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          party.businessName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.person_outline_rounded, size: 13, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                party.name,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeStyle['bgColor'] as Color,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: badgeStyle['borderColor'] as Color),
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
                  const SizedBox(width: 4),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz_rounded, size: 20, color: AppColors.textMuted),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onSelected: (val) {
                      if (val == 'edit') {
                        _showAddEditPartySheet(existingParty: party);
                      } else if (val == 'delete') {
                        _confirmDeleteParty(party);
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 16, color: AppColors.textPrimary),
                            SizedBox(width: 8),
                            Text("Edit Party", style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
                            SizedBox(width: 8),
                            Text("Delete Party", style: TextStyle(color: AppColors.error, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.phone_outlined, size: 12, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          party.phone,
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  if (party.gstin.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "GST: ${party.gstin}",
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, color: AppColors.cardBorder),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (party.address.isNotEmpty)
                    Expanded(
                      child: Text(
                        party.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    )
                  else
                    const Spacer(),
                  _buildBalanceIndicator(party.currentBalance),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBalanceIndicator(double balance) {
    if (balance > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFA7F3D0)),
        ),
        child: Text(
          "₹${balance.toStringAsFixed(0)} (To Receive)",
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF10B981),
          ),
        ),
      );
    } else if (balance < 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Text(
          "₹${(-balance).toStringAsFixed(0)} (To Pay)",
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFFEF4444),
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: const Text(
          "Settled (₹0)",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
      );
    }
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
                Icons.people_alt_outlined,
                size: 44,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "No Parties Found",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _searchQuery.isNotEmpty
                  ? "No contacts matching '$_searchQuery'"
                  : "Add your suppliers, dealers, and customers to manage ledger balances.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../services/warehouse_service.dart';
class AddWarehouseScreen extends StatefulWidget {
  const AddWarehouseScreen({super.key});

  @override
  State<AddWarehouseScreen> createState() => _AddWarehouseScreenState();
}

class _AddWarehouseScreenState extends State<AddWarehouseScreen> {
  final _formKey = GlobalKey<FormState>();

final WarehouseService
    warehouseService =
    WarehouseService();

  // Input Controllers
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _contactController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedType;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _contactController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {

  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {

    await warehouseService
        .createWarehouse(
      name:
          _nameController.text.trim(),

      code:
          _codeController.text.trim(),

      address:
          _addressController.text.trim(),

      city:
          _cityController.text.trim(),

      contactPerson:
          _contactController.text.trim(),

      phone:
          _phoneController.text.trim(),

      warehouseType:
          _selectedType ??
              "Secondary",

      notes:
          _notesController.text.trim(),
    );

    if (mounted) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Warehouse Added Successfully",
          ),
        ),
      );

      Navigator.pop(
        context,
        true,
      );
    }

  } catch (e) {

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          e.toString(),
        ),
      ),
    );

  } finally {

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // 1. Structural Dynamic Layout Layer
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // Top Custom Header Zone with Overlapping Rack Asset Image
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Color(0xFF1E293B),
                                  size: 20,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Add Warehouse',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Create a new stock location\nfor your inventory',
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF64748B),
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Mini Info Shield Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.verified_user_outlined,
                                    color: Color(0xFF2563EB),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Organize. Track. Grow.',
                                        style: TextStyle(
                                          color: Color(0xFF2563EB),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Streamline your inventory operations',
                                        style: TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Top Right Rack Image Placement
                        Positioned(
                          right: -24,
                          top: -10,
                          child: Image.asset(
                            'lib/assets/images/warehouse_rack.png',
                            height: 180,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const SizedBox(height: 180, width: 140),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Form Field Cards Block
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                  sliver: SliverToBoxAdapter(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildFormCard(
                            icon: Icons.store_outlined,
                            iconColor: const Color(0xFF2563EB),
                            iconBg: const Color(0xFFEFF6FF),
                            label: 'Warehouse Name *',
                            child: TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                hintText: 'Enter warehouse name',
                              ),
                              validator: (v) =>
                                  v!.isEmpty ? 'Name is required' : null,
                            ),
                          ),
                          _buildFormCard(
                            icon: Icons.qr_code_scanner_outlined,
                            iconColor: const Color(0xFF3B82F6),
                            iconBg: const Color(0xFFEFF6FF),
                            label: 'Warehouse Code *',
                            child: TextFormField(
                              controller: _codeController,
                              decoration: const InputDecoration(
                                hintText: 'Enter warehouse code',
                              ),
                              validator: (v) =>
                                  v!.isEmpty ? 'Code is required' : null,
                            ),
                          ),
                          _buildFormCard(
                            icon: Icons.business_outlined,
                            iconColor: const Color(0xFF475569),
                            iconBg: const Color(0xFFF1F5F9),
                            label: 'Warehouse Type *',
                            child: DropdownButtonFormField<String>(
                              value: _selectedType,
                              items: ['Primary', 'Secondary'].map((t) {
                                return DropdownMenuItem(
                                  value: t,
                                  child: Text(t),
                                );
                              }).toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedType = val),
                              decoration: const InputDecoration(
                                hintText: 'Select warehouse type',
                              ),
                              validator: (v) =>
                                  v == null ? 'Type is required' : null,
                            ),
                          ),
                          _buildFormCard(
                            icon: Icons.location_on_outlined,
                            iconColor: const Color(0xFFEF4444),
                            iconBg: const Color(0xFFFEF2F2),
                            label: 'Address',
                            child: TextFormField(
                              controller: _addressController,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                hintText: 'Enter complete address',
                              ),
                            ),
                          ),
                          _buildFormCard(
                            icon: Icons.location_city_outlined,
                            iconColor: const Color(0xFF0EA5E9),
                            iconBg: const Color(0xFFF0F9FF),
                            label: 'City',
                            child: TextFormField(
                              controller: _cityController,
                              decoration: const InputDecoration(
                                hintText: 'Enter city',
                              ),
                            ),
                          ),
                          _buildFormCard(
                            icon: Icons.person_outline_rounded,
                            iconColor: const Color(0xFF6366F1),
                            iconBg: const Color(0xFFEEF2FF),
                            label: 'Contact Person',
                            child: TextFormField(
                              controller: _contactController,
                              decoration: const InputDecoration(
                                hintText: 'Enter contact person name',
                              ),
                            ),
                          ),
                          _buildFormCard(
                            icon: Icons.phone_outlined,
                            iconColor: const Color(0xFF10B981),
                            iconBg: const Color(0xFFECFDF5),
                            label: 'Phone Number',
                            child: TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                hintText: 'Enter phone number',
                              ),
                            ),
                          ),
                          _buildFormCard(
                            icon: Icons.description_outlined,
                            iconColor: const Color(0xFFF59E0B),
                            iconBg: const Color(0xFFFEF3C7),
                            label: 'Notes',
                            child: TextFormField(
                              controller: _notesController,
                              maxLines: 1,
                              decoration: const InputDecoration(
                                hintText: 'Enter any additional notes',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Decorative Footer Asset Graphic Layer (Floating Bottom Placements)
          // --- REPLACE EVERYTHING AFTER THE CUSTOMSCROLLVIEW SAFEAREA WITH THIS ---

          // 2. Corrected Bottom Layer Asset Placements
          

          // 3. Re-aligned Save Warehouse Sticky Action Button Card
          Positioned(
            left: 24,
            right: 24,
            bottom:
                34, // Margins align completely flush with form card padding boundaries
            child: SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitForm,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.save_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                label: Text(
                  _isLoading ? 'Saving...' : 'Save Warehouse',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ), // Matches 16px curve radius
                  elevation: 0, // Flat design matching layout specification
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Unified Functional Component Wrapper for Unified Input Cards
  Widget _buildFormCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center, // Center aligns icon with input field
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ALTERED: Increased label typography size to 15 and weighted beautifully
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                // ALTERED: Clean custom theme injection that enforces soft outlined input fields
                Theme(
                  data: ThemeData(
                    inputDecorationTheme: InputDecorationTheme(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF2563EB),
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  child: child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

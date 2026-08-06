const Purchase = require("../models/Purchase");

// Create Purchase
exports.createPurchase = async (req, res) => {
  try {
    const purchase = await Purchase.create({
      purchaseNumber: req.body.purchaseNumber,

      // Supplier Snapshot
      supplierId: req.body.supplierId,
      supplierName: req.body.supplierName,
      contactPerson: req.body.contactPerson,
      phone: req.body.phone,
      email: req.body.email,
      gstNumber: req.body.gstNumber,
      address: req.body.address,
      city: req.body.city,
      state: req.body.state,
      pincode: req.body.pincode,
      paymentTerms: req.body.paymentTerms,

      // Dates
      purchaseDate: req.body.purchaseDate,
      deliveryDate: req.body.deliveryDate,

      // Products
      items: req.body.items,

      // Notes
      notes: req.body.notes,

      // Financials
      subtotal: req.body.subtotal,
      discount: req.body.discount,
      gst: req.body.gst,
      transportCharges: req.body.transportCharges,
      advancePayment: req.body.advancePayment,
      balanceDue: req.body.balanceDue,
      totalAmount: req.body.totalAmount,

      // Status
      paymentStatus: req.body.paymentStatus,
      status: req.body.status,
    });

    res.status(201).json({
      success: true,
      message: "Purchase created successfully.",
      data: purchase,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// Get All Purchases
exports.getPurchases = async (req, res) => {
  try {
    const purchases = await Purchase.find()
      .populate(
        "supplierId",
        "supplierName companyName contactPerson phone email gstNumber address city state pincode"
      )
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      count: purchases.length,
      data: purchases,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// Get Purchase By Id
exports.getPurchaseById = async (req, res) => {
  try {
    const purchase = await Purchase.findById(req.params.id).populate(
      "supplierId",
      "supplierName companyName contactPerson phone email gstNumber address city state pincode"
    );

    if (!purchase) {
      return res.status(404).json({
        success: false,
        message: "Purchase order not found.",
      });
    }

    res.json({
      success: true,
      data: purchase,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// Update Purchase
exports.updatePurchase = async (req, res) => {
  try {
    const purchase = await Purchase.findByIdAndUpdate(
      req.params.id,
      req.body,
      {
        new: true,
        runValidators: true,
      }
    );

    if (!purchase) {
      return res.status(404).json({
        success: false,
        message: "Purchase not found.",
      });
    }

    res.json({
      success: true,
      message: "Purchase updated successfully.",
      data: purchase,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// Delete Purchase
exports.deletePurchase = async (req, res) => {
  try {
    const purchase = await Purchase.findByIdAndDelete(req.params.id);

    if (!purchase) {
      return res.status(404).json({
        success: false,
        message: "Purchase not found.",
      });
    }

    res.json({
      success: true,
      message: "Purchase deleted successfully.",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
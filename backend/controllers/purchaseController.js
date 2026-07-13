const Purchase = require("../models/Purchase");

// Create a new purchase record
exports.createPurchase = async (req, res) => {
  try {
    const purchase = await Purchase.create(req.body);
    res.status(201).json(purchase);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Fetch all purchase historical records (sorted by newest first)
exports.getPurchases = async (req, res) => {
  try {
    const purchases = await Purchase.find().sort({ createdAt: -1 });
    res.json(purchases);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Fetch a specific purchase transaction entry by Database Primary key ID
exports.getPurchaseById = async (req, res) => {
  try {
    const purchase = await Purchase.findById(req.params.id);
    
    // FIX: Verify if the document actually exists in collection
    if (!purchase) {
      return res.status(404).json({ message: "Purchase order record not found." });
    }
    
    res.json(purchase);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Update an existing purchase ledger entries
exports.updatePurchase = async (req, res) => {
  try {
    const purchase = await Purchase.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true } // Added runValidators to enforce model schema matching
    );

    // FIX: Prevent 200 empty responses if target entry ID is dead
    if (!purchase) {
      return res.status(404).json({ message: "Failed to update. Target record not found." });
    }

    res.json(purchase);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Purge or delete a purchase log entry
exports.deletePurchase = async (req, res) => {
  try {
    const purchase = await Purchase.findByIdAndDelete(req.params.id);

    // FIX: Warn user if document is already removed or non-existent
    if (!purchase) {
      return res.status(404).json({ message: "Failed to delete. Target record does not exist." });
    }

    res.json({ message: "Purchase Deleted" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
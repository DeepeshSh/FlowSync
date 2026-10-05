const mongoose = require("mongoose");
const Party = require("../models/Party");

// @desc    Get all parties with optional type filtering
// @route   GET /api/parties
// @access  Public
const getParties = async (req, res) => {
  try {
    const { type, search } = req.query;
    const filter = {};

    if (type && ["SUPPLIER", "CUSTOMER", "DEALER"].includes(type.toUpperCase())) {
      filter.type = type.toUpperCase();
    }

    if (search && search.trim().length > 0) {
      const regex = new RegExp(search.trim(), "i");
      filter.$or = [
        { name: regex },
        { businessName: regex },
        { phone: regex },
        { gstin: regex },
      ];
    }

    const parties = await Party.find(filter).sort({ createdAt: -1 });

    return res.status(200).json({
      success: true,
      count: parties.length,
      parties,
    });
  } catch (error) {
    console.error("GET PARTIES ERROR:", error);
    return res.status(500).json({
      success: false,
      message: error.message || "Server error while fetching parties",
    });
  }
};

// @desc    Get a single party by ID
// @route   GET /api/parties/:id
// @access  Public
const getPartyById = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid party ID format",
      });
    }

    const party = await Party.findById(id);
    if (!party) {
      return res.status(404).json({
        success: false,
        message: "Party not found",
      });
    }

    return res.status(200).json({
      success: true,
      party,
    });
  } catch (error) {
    console.error("GET PARTY BY ID ERROR:", error);
    return res.status(500).json({
      success: false,
      message: error.message || "Server error while fetching party details",
    });
  }
};

// @desc    Create a new party
// @route   POST /api/parties
// @access  Public
const createParty = async (req, res) => {
  try {
    const {
      name,
      businessName,
      type,
      phone,
      email,
      gstin,
      address,
      currentBalance,
      creditLimit,
    } = req.body;

    if (!name || !businessName || !type || !phone) {
      return res.status(400).json({
        success: false,
        message: "name, businessName, type, and phone are required fields",
      });
    }

    const upperType = type.toUpperCase();
    if (!["SUPPLIER", "CUSTOMER", "DEALER"].includes(upperType)) {
      return res.status(400).json({
        success: false,
        message: "type must be SUPPLIER, CUSTOMER, or DEALER",
      });
    }

    const party = await Party.create({
      name: name.trim(),
      businessName: businessName.trim(),
      type: upperType,
      phone: phone.trim(),
      email: email ? email.trim() : "",
      gstin: gstin ? gstin.trim().toUpperCase() : "",
      address: address ? address.trim() : "",
      currentBalance: Number(currentBalance) || 0,
      creditLimit: Number(creditLimit) || 0,
      createdAt: new Date(),
    });

    return res.status(201).json({
      success: true,
      party,
    });
  } catch (error) {
    console.error("CREATE PARTY ERROR:", error);
    return res.status(500).json({
      success: false,
      message: error.message || "Server error while creating party",
    });
  }
};

// @desc    Update a party
// @route   PUT /api/parties/:id
// @access  Public
const updateParty = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid party ID format",
      });
    }

    if (req.body.type) {
      req.body.type = req.body.type.toUpperCase();
    }
    if (req.body.gstin) {
      req.body.gstin = req.body.gstin.toUpperCase();
    }

    const party = await Party.findByIdAndUpdate(id, req.body, {
      new: true,
      runValidators: true,
    });

    if (!party) {
      return res.status(404).json({
        success: false,
        message: "Party not found",
      });
    }

    return res.status(200).json({
      success: true,
      party,
    });
  } catch (error) {
    console.error("UPDATE PARTY ERROR:", error);
    return res.status(500).json({
      success: false,
      message: error.message || "Server error while updating party",
    });
  }
};

// @desc    Delete a party
// @route   DELETE /api/parties/:id
// @access  Public
const deleteParty = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid party ID format",
      });
    }

    const party = await Party.findByIdAndDelete(id);
    if (!party) {
      return res.status(404).json({
        success: false,
        message: "Party not found",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Party deleted successfully",
      id,
    });
  } catch (error) {
    console.error("DELETE PARTY ERROR:", error);
    return res.status(500).json({
      success: false,
      message: error.message || "Server error while deleting party",
    });
  }
};

module.exports = {
  getParties,
  getPartyById,
  createParty,
  updateParty,
  deleteParty,
};

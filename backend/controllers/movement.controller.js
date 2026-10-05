const mongoose = require("mongoose");
const Movement = require("../models/Movement");
const Product = require("../models/Product");

// @desc    Record inventory movement (STOCK_IN, STOCK_OUT, DAMAGE, RETURN, ADJUSTMENT)
// @route   POST /api/movements
// @access  Public
const createMovement = async (req, res) => {
  try {
    const { productId, type, quantity, reason, reference } = req.body;

    if (!productId || !type || quantity === undefined || quantity === null) {
      return res.status(400).json({
        success: false,
        message: "productId, type, and quantity are required",
      });
    }

    if (!mongoose.Types.ObjectId.isValid(productId)) {
      return res.status(400).json({
        success: false,
        message: "Invalid product ID format",
      });
    }

    const qty = Number(quantity);
    if (isNaN(qty) || qty <= 0) {
      return res.status(400).json({
        success: false,
        message: "Quantity must be a positive number greater than 0",
      });
    }

    const validTypes = ["STOCK_IN", "STOCK_OUT", "DAMAGE", "RETURN", "ADJUSTMENT"];
    if (!validTypes.includes(type)) {
      return res.status(400).json({
        success: false,
        message: `Invalid movement type. Allowed types: ${validTypes.join(", ")}`,
      });
    }

    const product = await Product.findById(productId);
    if (!product) {
      return res.status(404).json({
        success: false,
        message: "Product not found",
      });
    }

    const currentStock = Number(product.stock) || 0;
    let newStock = currentStock;

    if (type === "STOCK_IN" || type === "RETURN") {
      newStock = currentStock + qty;
    } else if (type === "STOCK_OUT" || type === "DAMAGE") {
      newStock = currentStock - qty;
      if (newStock < 0) {
        return res.status(400).json({
          success: false,
          message: "Insufficient stock for this operation",
          currentStock,
          requestedQuantity: qty,
        });
      }
    } else if (type === "ADJUSTMENT") {
      newStock = currentStock + qty;
      if (newStock < 0) {
        return res.status(400).json({
          success: false,
          message: "Insufficient stock for this adjustment",
          currentStock,
          requestedQuantity: qty,
        });
      }
    }

    // Atomically update product stock
    await Product.findByIdAndUpdate(
      productId,
      { stock: newStock },
      { new: true }
    );

    // Create Movement record
    const movement = await Movement.create({
      productId,
      type,
      quantity: qty,
      previousStock: currentStock,
      newStock,
      reason: reason || "",
      reference: reference || "",
      timestamp: new Date(),
    });

    return res.status(201).json({
      success: true,
      movement,
      updatedStock: newStock,
    });
  } catch (error) {
    console.error("Error creating movement:", error);
    return res.status(500).json({
      success: false,
      message: error.message || "Server error while recording movement",
    });
  }
};

// @desc    Get movement ledger history for a specific product
// @route   GET /api/movements/product/:productId
// @access  Public
const getProductMovements = async (req, res) => {
  try {
    const { productId } = req.params;

    if (!productId) {
      return res.status(400).json({
        success: false,
        message: "productId parameter is required",
      });
    }

    if (!mongoose.Types.ObjectId.isValid(productId)) {
      return res.status(400).json({
        success: false,
        message: "Invalid product ID format",
      });
    }

    const movements = await Movement.find({ productId }).sort({
      timestamp: -1,
      createdAt: -1,
    });

    return res.status(200).json({
      success: true,
      count: movements.length,
      movements,
    });
  } catch (error) {
    console.error("Error fetching product movements:", error);
    return res.status(500).json({
      success: false,
      message: error.message || "Server error while fetching movements",
    });
  }
};

// @desc    Get all inventory movements / master logs
// @route   GET /api/movements/all
// @access  Public
const getAllMovements = async (req, res) => {
  try {
    const limit = parseInt(req.query.limit, 10) || 100;
    const movements = await Movement.find()
      .populate("productId", "name sku price stock category")
      .sort({ timestamp: -1, createdAt: -1 })
      .limit(limit);

    return res.status(200).json({
      success: true,
      count: movements.length,
      movements,
    });
  } catch (error) {
    console.error("Error fetching all movements:", error);
    return res.status(500).json({
      success: false,
      message: error.message || "Server error while fetching all movements",
    });
  }
};

// @desc    Get damaged products movements
// @route   GET /api/movements/damaged
// @access  Public
const getDamagedProducts = async (req, res) => {
  try {
    const limit = parseInt(req.query.limit, 10) || 100;
    const damagedMovements = await Movement.find({ type: "DAMAGE" })
      .populate("productId", "name sku price stock category")
      .sort({ timestamp: -1, createdAt: -1 })
      .limit(limit);

    return res.status(200).json({
      success: true,
      count: damagedMovements.length,
      movements: damagedMovements,
    });
  } catch (error) {
    console.error("Error fetching damaged products:", error);
    return res.status(500).json({
      success: false,
      message: error.message || "Server error while fetching damaged products",
    });
  }
};

module.exports = {
  createMovement,
  getProductMovements,
  getAllMovements,
  getDamagedProducts,
};

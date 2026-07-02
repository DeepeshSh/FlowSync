const mongoose = require("mongoose");

const variantSchema = new mongoose.Schema(
  {
    // ============================
    // PRODUCT REFERENCE
    // ============================

    productId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Product",
      required: true,
      index: true,
    },

    // ============================
    // BASIC INFORMATION
    // ============================

    variantName: {
      type: String,
      required: true,
      trim: true,
    },

    sku: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      uppercase: true,
    },

    barcode: {
      type: String,
      default: "",
      trim: true,
    },

    // ============================
    // WAREHOUSE
    // ============================

    warehouseId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Warehouse",
      required: true,
      index: true,
    },

    storageLocation: {
      type: String,
      default: "",
      trim: true,
    },

    // ============================
    // INVENTORY
    // ============================

    stock: {
      type: Number,
      default: 0,
      min: 0,
    },

    reservedStock: {
      type: Number,
      default: 0,
      min: 0,
    },

    availableStock: {
      type: Number,
      default: 0,
      min: 0,
    },

    lowStockThreshold: {
      type: Number,
      default: 5,
      min: 0,
    },

    // ============================
    // PRICING
    // ============================

    purchasePrice: {
      type: Number,
      default: 0,
      min: 0,
    },

    sellingPrice: {
      type: Number,
      default: 0,
      min: 0,
    },

    mrp: {
      type: Number,
      default: 0,
      min: 0,
    },

    gstPercentage: {
      type: Number,
      default: 0,
      min: 0,
    },

    // ============================
    // IMAGE
    // ============================

    imageUrl: {
      type: String,
      default: "",
    },

    // ============================
    // STATUS
    // ============================

    isActive: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
  }
);

// ======================================
// AUTO CALCULATE AVAILABLE STOCK
// ======================================

variantSchema.pre("save", function (next) {
  this.availableStock =
    this.stock - this.reservedStock;

  if (this.availableStock < 0) {
    this.availableStock = 0;
  }

  next();
});

// ======================================
// INDEXES
// ======================================

variantSchema.index({
  productId: 1,
  warehouseId: 1,
});

variantSchema.index({
  sku: 1,
});

module.exports = mongoose.model(
  "Variant",
  variantSchema
);
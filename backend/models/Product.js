const mongoose = require("mongoose");

const productSchema = new mongoose.Schema(
  {
    // =========================
    // BASIC INFORMATION
    // =========================

    name: {
      type: String,
      required: true,
      trim: true,
    },

    sku: {
      type: String,
      required: true,
      trim: true,
      unique: true,
    },

    brandName: {
      type: String,
      required: true,
      trim: true,
    },

    category: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Category",
      required: true,
    },

    warehouseId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Warehouse",
      required: true,
    },

    hsnCode: {
      type: String,
      default: "",
      trim: true,
    },

    barcode: {
      type: String,
      default: "",
      trim: true,
    },

    description: {
      type: String,
      default: "",
      trim: true,
    },

    // =========================
    // INVENTORY
    // =========================

    stock: {
      type: Number,
      default: 0,
    },

    unit: {
      type: String,
      default: "Piece",
    },

    lowStockThreshold: {
      type: Number,
      default: 5,
    },

    storageLocation: {
      type: String,
      default: "",
      trim: true,
    },

    dimensions: {
      length: {
        type: Number,
        default: 0,
      },

      width: {
        type: Number,
        default: 0,
      },

      height: {
        type: Number,
        default: 0,
      },

      unit: {
        type: String,
        default: "cm",
      },
    },

    fragile: {
      type: Boolean,
      default: false,
    },

    // =========================
    // PRICING
    // =========================

    purchasePrice: {
      type: Number,
      default: 0,
    },

    sellingPrice: {
      type: Number,
      default: 0,
    },

    gstPercentage: {
      type: Number,
      default: 0,
    },

    mrp: {
      type: Number,
      default: 0,
    },

    // =========================
    // SUPPLIER
    // =========================

    supplierName: {
      type: String,
      default: "",
      trim: true,
    },

    amountPaid: {
      type: Number,
      default: 0,
    },

    outstandingBalance: {
      type: Number,
      default: 0,
    },

    purchaseDate: {
      type: Date,
      default: Date.now,
    },

    // =========================
    // IMAGE
    // =========================

    imageUrl: {
      type: String,
      default: "",
    },

    // =========================
    // STATUS
    // =========================

    isActive: {
      type: Boolean,
      default: true,
    },

    // =========================
    // FUTURE VARIANTS SUPPORT
    // =========================

    hasVariants: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model(
  "Product",
  productSchema
);
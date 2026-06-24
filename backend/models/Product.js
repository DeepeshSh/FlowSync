const mongoose = require("mongoose");

const productSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },

    sku: {
      type: String,
      required: true,
      trim: true,
    },

    brandName: {
      type: String,
      required: true,
      trim: true,
    },

    category: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Category",
      default: null,
    },

    warehouseId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Warehouse",
      default: null,
    },

    stock: {
      type: Number,
      default: 0,
    },

    unit: {
      type: String,
      default: "pcs",
    },

    lowStockThreshold: {
      type: Number,
      default: 5,
    },

    storageLocation: {
      type: String,
      required: true,
      trim: true,
    },

    purchasePrice: {
      type: Number,
      default: 0,
    },

    sellingPrice: {
      type: Number,
      default: 0,
    },

    imageUrl: {
      type: String,
      default: "",
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
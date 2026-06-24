const mongoose = require("mongoose");

const warehouseSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },

    code: {
      type: String,
      required: true,
      trim: true,
      unique: true,
    },

    address: {
      type: String,
      trim: true,
    },

    city: {
      type: String,
      trim: true,
    },

    contactPerson: {
      type: String,
      trim: true,
    },

    phone: {
      type: String,
      trim: true,
    },

    warehouseType: {
      type: String,
      enum: [
        "Primary",
        "Secondary",
      ],
      default: "Secondary",
    },

    isActive: {
      type: Boolean,
      default: true,
    },

    notes: {
      type: String,
      trim: true,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model(
  "Warehouse",
  warehouseSchema
);
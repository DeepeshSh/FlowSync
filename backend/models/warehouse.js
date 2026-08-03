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

    // NEW: Total storage capacity of the warehouse, expressed in stock
    // units (pieces). Used by the dashboard to compute "Utilization %"
    // (totalStockUnits / totalCapacity). Defaults to 0 for existing
    // warehouses created before this field was added — update these
    // records (via PUT /api/warehouses/:id) so utilization reflects
    // real capacity instead of showing 0%.
    capacity: {
      type: Number,
      default: 0,
      min: 0,
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
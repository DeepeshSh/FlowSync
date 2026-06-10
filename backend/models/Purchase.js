const mongoose = require("mongoose");

const purchaseSchema = new mongoose.Schema(
  {
    purchaseNumber: {
      type: String,
      required: true,
      unique: true,
    },

    // Supplier Details

    supplierId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Supplier",
    },

    supplierName: {
      type: String,
      required: true,
    },

    contactPerson: {
      type: String,
      default: "",
    },

    phone: {
      type: String,
      default: "",
    },

    paymentTerms: {
      type: String,
      default: "30 Days",
    },

    // Dates

    purchaseDate: {
      type: Date,
      default: Date.now,
    },

    deliveryDate: {
      type: Date,
    },

    // Products

    items: [
      {
        productId: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "Product",
        },

        productName: {
          type: String,
          required: true,
        },

        sku: {
          type: String,
          default: "",
        },

        quantity: {
          type: Number,
          required: true,
          default: 1,
        },

        rate: {
          type: Number,
          required: true,
          default: 0,
        },

        amount: {
          type: Number,
          required: true,
          default: 0,
        },
      },
    ],

    // Notes

    notes: {
      type: String,
      default: "",
    },

    // Summary

    subtotal: {
      type: Number,
      default: 0,
    },

    discount: {
      type: Number,
      default: 0,
    },

    gst: {
      type: Number,
      default: 0,
    },

    transportCharges: {
      type: Number,
      default: 0,
    },

    advancePayment: {
      type: Number,
      default: 0,
    },

    balanceDue: {
      type: Number,
      default: 0,
    },

    totalAmount: {
      type: Number,
      required: true,
      default: 0,
    },

    // Status

    paymentStatus: {
      type: String,

      enum: [
        "Pending",
        "Partial",
        "Paid",
      ],

      default: "Pending",
    },

    status: {
      type: String,

      enum: [
        "Draft",
        "Confirmed",
      ],

      default: "Draft",
    },
  },

  {
    timestamps: true,
  }
);

module.exports = mongoose.model(
  "Purchase",
  purchaseSchema
);
const mongoose = require("mongoose");

const purchaseSchema = new mongoose.Schema(
  {
    purchaseNumber: {
      type: String,
      required: true,
      unique: true,
    },

    // Supplier Reference
    supplierId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Supplier",
    },

    // Supplier Snapshot Details
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

    email: {
      type: String,
      default: "",
    },

    gstNumber: {
      type: String,
      default: "",
    },

    address: {
      type: String,
      default: "",
    },

    city: {
      type: String,
      default: "",
    },

    state: {
      type: String,
      default: "",
    },

    pincode: {
      type: String,
      default: "",
    },

    paymentTerms: {
      type: String,
      default: "30 Days",
    },

    // Purchase Dates
    purchaseDate: {
      type: Date,
      default: Date.now,
    },

    deliveryDate: {
      type: Date,
    },

    // Purchased Products
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

        unit: {
          type: String,
          default: "Pcs",
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

        notes: {
          type: String,
          default: "",
        },
      },
    ],

    // Order Notes
    notes: {
      type: String,
      default: "",
    },

    // Financial Summary
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

    // Purchase Status
    paymentStatus: {
      type: String,
      enum: [
        "Pending",
        "Partial",
        "Paid",
      ],
      default: "Pending",
    },

    paymentStatus: {
      type: String,
      enum: [
        "Pending",
        "Partial",
        "Partially Paid",
        "Paid",
      ],
      default: "Pending",
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
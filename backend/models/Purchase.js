const mongoose = require("mongoose");

const purchaseSchema = new mongoose.Schema(
  {
    purchaseNumber: {
      type: String,
      required: true,
      unique: true,
    },

    supplierName: {
      type: String,
      required: true,
    },

    items: [
      {
        productId: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "Product",
        },

        productName: String,

        quantity: Number,

        purchasePrice: Number,

        total: Number,
      },
    ],

    totalAmount: {
      type: Number,
      required: true,
    },

    paymentStatus: {
      type: String,
      enum: [
        "Paid",
        "Pending",
      ],
      default: "Pending",
    },

    purchaseDate: {
      type: Date,
      default: Date.now,
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
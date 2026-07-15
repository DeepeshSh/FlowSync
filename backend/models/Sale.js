const mongoose =
require("mongoose");

const saleSchema =
new mongoose.Schema({

  saleNumber: {
    type: String,
    required: true,
    unique: true,
  },

  customerName: {
    type: String,
    required: true,
  },

  items: [
    {
      productId: {
        type:
            mongoose.Schema.Types.ObjectId,
        ref: "Product",
      },

      productName: String,

      quantity: Number,

      sellingPrice: Number,

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
      "Partially Paid",
      "Draft" // Add "Draft" here!
    ],
    default: "Pending",
  },

  saleDate: {
    type: Date,
    default: Date.now,
  },

}, {
  timestamps: true,
});

module.exports =
mongoose.model(
  "Sale",
  saleSchema,
);
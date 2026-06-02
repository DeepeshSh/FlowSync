const mongoose = require("mongoose");

const productSchema =
new mongoose.Schema({

  name: {
    type: String,
    required: true,
  },

  sku: {
    type: String,
    required: true,
  },

  stock: {
    type: Number,
    default: 0,
  },

  purchasePrice: {
    type: Number,
    default: 0,
  },

  sellingPrice: {
    type: Number,
    default: 0,
  },

  category: {
    type:
      mongoose.Schema.Types.ObjectId,

    ref: "Category",

    default: null,
  },

},
{
  timestamps: true,
});

module.exports =
mongoose.model(
  "Product",
  productSchema
);
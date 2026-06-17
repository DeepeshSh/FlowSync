const mongoose = require("mongoose");

const categorySchema =
new mongoose.Schema({

  name: {
    type: String,
    required: true,
    trim: true,
  },

  description: {
    type: String,
    default: "",
  },

  parentCategoryId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Category",
    default: null,
  },

  unit: {
    type: String,
    default: "",
  },

  isFragile: {
    type: Boolean,
    default: false,
  },

  isReturnable: {
    type: Boolean,
    default: false,
  },

  notes: {
    type: String,
    default: "",
  },

},
{
  timestamps: true,
});

module.exports =
mongoose.model(
  "Category",
  categorySchema
);
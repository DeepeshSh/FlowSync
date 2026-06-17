const mongoose = require("mongoose");

const customerSchema =
new mongoose.Schema({

  customerName: {
    type: String,
    required: true,
  },

  contactPerson: String,

  phone: {
    type: String,
    required: true,
  },

  email: String,

  gstNumber: String,

  address: String,

  city: String,

  state: String,

  pincode: String,

  creditLimit: {
    type: Number,
    default: 0,
  },

  openingBalance: {
    type: Number,
    default: 0,
  },

  isActive: {
    type: Boolean,
    default: true,
  },

}, {
  timestamps: true,
});

module.exports =
mongoose.model(
  "Customer",
  customerSchema
);
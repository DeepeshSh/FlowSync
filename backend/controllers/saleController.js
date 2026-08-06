const Sale = require("../models/Sale");

// Create Sale
exports.createSale = async (req, res) => {
  try {
    console.log("===== CREATE SALE HIT =====");
    console.log(req.body);

    const sale = await Sale.create({
      saleNumber: req.body.saleNumber,

      // Customer Snapshot
      customerId: req.body.customerId,
      customerName: req.body.customerName,
      contactPerson: req.body.contactPerson,
      phone: req.body.phone,
      email: req.body.email,
      gstNumber: req.body.gstNumber,
      address: req.body.address,
      city: req.body.city,
      state: req.body.state,
      pincode: req.body.pincode,

      // Sale Items
      items: req.body.items,

      // Financial Details
      subtotal: req.body.subtotal,
      discount: req.body.discount,
      gst: req.body.gst,
      transportCharges: req.body.transportCharges,
      advancePayment: req.body.advancePayment,
      balanceDue: req.body.balanceDue,
      totalAmount: req.body.totalAmount,

      // Notes
      notes: req.body.notes,

      // Status
      paymentStatus: req.body.paymentStatus,

      saleDate: req.body.saleDate,
    });

    res.status(201).json(sale);
  } catch (error) {
    console.log(error);

    res.status(500).json({
      message: error.message,
    });
  }
};

// Get All Sales
exports.getSales = async (req, res) => {
  try {
    const sales = await Sale.find()
      .populate(
        "customerId",
        "customerName contactPerson phone email gstNumber address city state pincode"
      )
      .sort({
        createdAt: -1,
      });

    res.json(sales);
  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
};

// Get Sale By Id
exports.getSaleById = async (req, res) => {
  try {
    const sale = await Sale.findById(req.params.id).populate(
      "customerId",
      "customerName contactPerson phone email gstNumber address city state pincode"
    );

    if (!sale) {
      return res.status(404).json({
        message: "Sale not found.",
      });
    }

    res.json(sale);
  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
};

// Delete Sale
exports.deleteSale = async (req, res) => {
  try {
    const sale = await Sale.findByIdAndDelete(req.params.id);

    if (!sale) {
      return res.status(404).json({
        message: "Sale not found.",
      });
    }

    res.json({
      message: "Sale Deleted",
    });
  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
};
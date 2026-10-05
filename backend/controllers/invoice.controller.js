const mongoose = require("mongoose");
const Invoice = require("../models/Invoice");
const Product = require("../models/Product");
const Movement = require("../models/Movement");
const Party = require("../models/Party");

// @desc    Create a new invoice with atomic stock movement and party balance update
// @route   POST /api/invoices
// @access  Public
const createInvoice = async (req, res) => {
  try {
    const {
      type,
      partyId,
      partyName,
      items,
      paymentStatus,
      notes,
      date,
    } = req.body;

    if (!type || !partyId || !partyName || !items || !Array.isArray(items) || items.length === 0) {
      return res.status(400).json({
        success: false,
        message: "type, partyId, partyName, and at least one item are required",
      });
    }

    const upperType = type.toUpperCase();
    if (!["SALE", "PURCHASE"].includes(upperType)) {
      return res.status(400).json({
        success: false,
        message: "type must be SALE or PURCHASE",
      });
    }

    // Auto-generate invoice number if not explicitly given
    const prefix = upperType === "SALE" ? "INV" : "PUR";
    const randomSuffix = Math.floor(1000 + Math.random() * 9000);
    const invoiceNumber = req.body.invoiceNumber && req.body.invoiceNumber.trim().isNotEmpty
        ? req.body.invoiceNumber.trim().toUpperCase()
        : `${prefix}-${Date.now().toString().slice(-6)}${randomSuffix}`;

    // Process and calculate line items
    let subtotal = 0;
    let gstTotal = 0;
    const processedItems = [];

    for (const item of items) {
      const qty = Number(item.quantity);
      const rate = Number(item.rate);
      const gstRate = item.gstRate !== undefined ? Number(item.gstRate) : 18;

      if (!item.productId || isNaN(qty) || qty <= 0 || isNaN(rate) || rate < 0) {
        return res.status(400).json({
          success: false,
          message: "Each item must have a valid productId, positive quantity, and non-negative rate",
        });
      }

      const itemAmount = Math.round(qty * rate * 100) / 100;
      const itemGst = Math.round(itemAmount * (gstRate / 100) * 100) / 100;

      subtotal += itemAmount;
      gstTotal += itemGst;

      processedItems.push({
        productId: item.productId,
        productName: item.productName || "Product",
        quantity: qty,
        rate,
        gstRate,
        amount: itemAmount,
      });

      // Synchronize Product Stock and log inventory movement
      if (mongoose.Types.ObjectId.isValid(item.productId)) {
        try {
          const product = await Product.findById(item.productId);
          if (product) {
            const currentStock = Number(product.stock) || 0;
            const newStock = upperType === "SALE" ? currentStock - qty : currentStock + qty;

            await Product.findByIdAndUpdate(item.productId, { stock: newStock });

            // Record Movement ledger entry
            await Movement.create({
              productId: item.productId,
              type: upperType === "SALE" ? "STOCK_OUT" : "STOCK_IN",
              quantity: qty,
              previousStock: currentStock,
              newStock,
              reason: `${upperType} Invoice #${invoiceNumber}`,
              reference: invoiceNumber,
              timestamp: date ? new Date(date) : new Date(),
            });
          }
        } catch (itemErr) {
          console.error(`Error updating product stock for ${item.productId}:`, itemErr);
        }
      }
    }

    subtotal = Math.round(subtotal * 100) / 100;
    gstTotal = Math.round(gstTotal * 100) / 100;
    const grandTotal = Math.round((subtotal + gstTotal) * 100) / 100;

    const finalPaymentStatus = (paymentStatus || "UNPAID").toUpperCase();

    // Create Invoice record
    const invoice = await Invoice.create({
      invoiceNumber,
      type: upperType,
      partyId,
      partyName: partyName.trim(),
      items: processedItems,
      subtotal,
      gstTotal,
      grandTotal,
      paymentStatus: finalPaymentStatus,
      notes: notes ? notes.trim() : "",
      date: date ? new Date(date) : new Date(),
    });

    // Synchronize Party Balance if unpaid or partial
    if (mongoose.Types.ObjectId.isValid(partyId) && finalPaymentStatus !== "PAID") {
      try {
        const balanceDelta = upperType === "SALE" ? grandTotal : -grandTotal;
        await Party.findByIdAndUpdate(partyId, {
          $inc: { currentBalance: balanceDelta },
        });
      } catch (partyErr) {
        console.error(`Error updating balance for party ${partyId}:`, partyErr);
      }
    }

    return res.status(201).json({
      success: true,
      message: `${upperType} invoice created successfully`,
      invoice,
    });
  } catch (error) {
    console.error("CREATE INVOICE ERROR:", error);
    return res.status(500).json({
      success: false,
      message: error.message || "Server error while creating invoice",
    });
  }
};

// @desc    Get all invoices with optional type & status filtering
// @route   GET /api/invoices
// @access  Public
const getInvoices = async (req, res) => {
  try {
    const { type, paymentStatus, partyId } = req.query;
    const filter = {};

    if (type && ["SALE", "PURCHASE"].includes(type.toUpperCase())) {
      filter.type = type.toUpperCase();
    }
    if (paymentStatus && ["PAID", "UNPAID", "PARTIAL"].includes(paymentStatus.toUpperCase())) {
      filter.paymentStatus = paymentStatus.toUpperCase();
    }
    if (partyId && mongoose.Types.ObjectId.isValid(partyId)) {
      filter.partyId = partyId;
    }

    const invoices = await Invoice.find(filter).sort({ date: -1, createdAt: -1 });

    return res.status(200).json({
      success: true,
      count: invoices.length,
      invoices,
    });
  } catch (error) {
    console.error("GET INVOICES ERROR:", error);
    return res.status(500).json({
      success: false,
      message: error.message || "Server error while fetching invoices",
    });
  }
};

// @desc    Get invoice by ID
// @route   GET /api/invoices/:id
// @access  Public
const getInvoiceById = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid invoice ID format",
      });
    }

    const invoice = await Invoice.findById(id)
      .populate("partyId", "name businessName phone email gstin address")
      .populate("items.productId", "name sku price");

    if (!invoice) {
      return res.status(404).json({
        success: false,
        message: "Invoice not found",
      });
    }

    return res.status(200).json({
      success: true,
      invoice,
    });
  } catch (error) {
    console.error("GET INVOICE BY ID ERROR:", error);
    return res.status(500).json({
      success: false,
      message: error.message || "Server error while fetching invoice",
    });
  }
};

module.exports = {
  createInvoice,
  getInvoices,
  getInvoiceById,
};

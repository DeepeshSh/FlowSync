const express = require("express");
const router = express.Router();

const {
  createInvoice,
  getInvoices,
  getInvoiceById,
} = require("../controllers/invoice.controller");

router.post("/", createInvoice);
router.get("/", getInvoices);
router.get("/:id", getInvoiceById);

module.exports = router;

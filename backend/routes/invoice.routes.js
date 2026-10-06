const express = require("express");
const router = express.Router();
const authMiddleware = require("../middleware/authMiddleware");

const {
  createInvoice,
  getInvoices,
  getInvoiceById,
} = require("../controllers/invoice.controller");

router.use(authMiddleware);

router.post("/", createInvoice);
router.get("/", getInvoices);
router.get("/:id", getInvoiceById);

module.exports = router;

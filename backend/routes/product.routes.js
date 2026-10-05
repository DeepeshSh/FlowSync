const express = require("express");

const router = express.Router();

const {
  createProduct,
  getProducts,
  getProductById,
  updateProduct,
  deleteProduct,
  getInventoryStats,
} = require("../controllers/product.controller");

router.post("/", createProduct);
router.get("/", getProducts);
router.get("/stats/summary", getInventoryStats);
router.get("/:id", getProductById);
router.put("/:id", updateProduct);
router.delete("/:id", deleteProduct);

module.exports = router;
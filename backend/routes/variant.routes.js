const express = require("express");

const router = express.Router();

const {
    createVariant,
    getVariants,
    getVariantsByProduct,
    getVariantsByWarehouse,
    getVariantById,
    updateVariant,
    deleteVariant,
  } = require("../controllers/variant.controller");
// ======================================
// CREATE VARIANT
// ======================================

router.get("/test", (req, res) => {
    res.json({
      success: true,
      message: "Variant route working",
    });
  });

router.post("/", createVariant);

router.get("/", getVariants);

router.get(
  "/product/:productId",
  getVariantsByProduct
);

router.get(
  "/warehouse/:warehouseId",
  getVariantsByWarehouse
);

router.get(
  "/:id",
  getVariantById
);

router.put(
  "/:id",
  updateVariant
);

router.delete(
  "/:id",
  deleteVariant
);

module.exports = router;
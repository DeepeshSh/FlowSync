const express =
require("express");

const router =
express.Router();

const {
  createSale,
  getSales,
  getSaleById,
  deleteSale,
} = require(
  "../controllers/saleController"
);

router.post(
  "/",
  createSale
);

router.get(
  "/",
  getSales
);

router.get(
  "/:id",
  getSaleById
);

router.delete(
  "/:id",
  deleteSale
);

module.exports =
router;
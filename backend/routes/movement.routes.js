const express = require("express");
const router = express.Router();

const {
  createMovement,
  getProductMovements,
  getAllMovements,
  getDamagedProducts,
} = require("../controllers/movement.controller");

router.post("/", createMovement);
router.get("/all", getAllMovements);
router.get("/damaged", getDamagedProducts);
router.get("/product/:productId", getProductMovements);

module.exports = router;

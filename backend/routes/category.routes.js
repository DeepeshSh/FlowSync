const express = require("express");
const router = express.Router();

const {
  getCategories,
  createCategory,
  updateCategory, // 1. Add updateCategory here
  deleteCategory,
} = require("../controllers/category.controller");

router.post("/", createCategory);
router.get("/", getCategories);

// 2. Add this line right here to handle the PUT request!
router.put("/:id", updateCategory); 

router.delete("/:id", deleteCategory);

module.exports = router;
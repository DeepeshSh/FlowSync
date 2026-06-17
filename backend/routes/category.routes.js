const express =
require("express");

const router =
express.Router();

const {
  getCategories,
  createCategory,
  deleteCategory,
} = require(
  "../controllers/category.controller"
);

router.post(
  "/",
  createCategory
);

router.get(
  "/",
  getCategories
);


router.delete(
  "/:id",
  deleteCategory
);

module.exports =
router;
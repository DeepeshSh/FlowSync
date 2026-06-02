const Category =
require("../models/Category");

// CREATE CATEGORY
exports.createCategory =
async (req, res) => {

  try {

    const category =
      await Category.create(
        req.body
      );

    res.status(201).json(
      category
    );

  } catch (error) {

    res.status(500).json({
      message:
        error.message,
    });
  }
};

// GET ALL CATEGORIES
exports.getCategories =
async (req, res) => {

  try {

    const categories =
      await Category.find();

    res.status(200).json(
      categories
    );

  } catch (error) {

    res.status(500).json({
      message:
        error.message,
    });
  }
};

// UPDATE CATEGORY
exports.updateCategory =
async (req, res) => {

  try {

    const category =
      await Category.findByIdAndUpdate(
        req.params.id,
        req.body,
        { new: true }
      );

    res.json(category);

  } catch (error) {

    res.status(500).json({
      message:
        error.message,
    });
  }
};

// DELETE CATEGORY
exports.deleteCategory =
async (req, res) => {

  try {

    await Category.findByIdAndDelete(
      req.params.id
    );

    res.json({
      message:
        "Category Deleted",
    });

  } catch (error) {

    res.status(500).json({
      message:
        error.message,
    });
  }
};
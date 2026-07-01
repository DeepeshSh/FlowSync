const Product = require("../models/Product");

// =============================
// CREATE PRODUCT
// =============================
exports.createProduct = async (req, res) => {
  try {

    const {
      name,
      sku,
      brandName,
      category,
      warehouseId,
      hsnCode,
      barcode,
      description,
      stock,
      unit,
      lowStockThreshold,
      storageLocation,
      dimensions,
      fragile,
      purchasePrice,
      sellingPrice,
      gstPercentage,
      mrp,
      supplierName,
      amountPaid,
      outstandingBalance,
      purchaseDate,
      imageUrl,
      isActive,
      hasVariants,
    } = req.body;

    // Basic validation
    if (
      !name ||
      !sku ||
      !brandName ||
      !category ||
      !warehouseId
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Name, SKU, Brand, Category and Warehouse are required.",
      });
    }
    const product = await Product.create({
      name,
      sku,
      brandName,
      category,
      warehouseId,
      hsnCode,
      barcode,
      description,
      stock,
      unit,
      lowStockThreshold,
      storageLocation,
      dimensions,
      fragile,
      purchasePrice,
      sellingPrice,
      gstPercentage,
      mrp,
      supplierName,
      amountPaid,
      outstandingBalance,
      purchaseDate,
      imageUrl,
      isActive,
      hasVariants,
    });

    res.status(201).json({
      success: true,
      message: "Product created successfully.",
      data: product,
    });

  } catch (error) {

    console.error("CREATE PRODUCT ERROR");
    console.error(error);

    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// =============================
// GET ALL PRODUCTS
// =============================
exports.getProducts = async (req, res) => {
  try {

    const products = await Product.find()
      .populate("category")
      .populate("warehouseId");

    res.status(200).json({
      success: true,
      count: products.length,
      data: products,
    });

  } catch (error) {

    console.error(error);

    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// =============================
// GET SINGLE PRODUCT
// =============================
exports.getProductById = async (req, res) => {

  try {

    const product = await Product.findById(req.params.id)
      .populate("category")
      .populate("warehouseId");

    if (!product) {

      return res.status(404).json({
        success: false,
        message: "Product not found",
      });
    }

    res.json({
      success: true,
      data: product,
    });

  } catch (error) {

    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// =============================
// UPDATE PRODUCT
// =============================
exports.updateProduct = async (req, res) => {

  try {

    const product = await Product.findByIdAndUpdate(
      req.params.id,
      req.body,
      {
        new: true,
        runValidators: true,
      }
    );

    if (!product) {

      return res.status(404).json({
        success: false,
        message: "Product not found",
      });
    }

    res.json({
      success: true,
      message: "Product updated successfully.",
      data: product,
    });

  } catch (error) {

    console.error(error);

    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// =============================
// DELETE PRODUCT
// =============================
exports.deleteProduct = async (req, res) => {

  try {

    const product = await Product.findByIdAndDelete(
      req.params.id
    );

    if (!product) {

      return res.status(404).json({
        success: false,
        message: "Product not found",
      });
    }

    res.json({
      success: true,
      message: "Product deleted successfully.",
    });

  } catch (error) {

    console.error(error);

    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
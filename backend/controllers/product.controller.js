const Product = require("../models/Product");
const Variant = require("../models/Variant");
const Movement = require("../models/Movement");
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

    if (stock && Number(stock) > 0) {
      try {
        await Movement.create({
          productId: product._id,
          type: "STOCK_IN",
          quantity: Number(stock),
          previousStock: 0,
          newStock: Number(stock),
          reason: "Initial Inventory Setup",
          reference: product.sku || "INIT",
        });
      } catch (movErr) {
        console.error("Initial movement logging error:", movErr);
      }
    }

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

    const variants = await Variant.find({
      productId: product._id,
      isActive: true,
    })
    .populate("warehouseId", "name code")
    .sort({ variantName: 1 });
    
    res.json({
      success: true,
      data: {
        product,
        variants,
      },
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
    const existing = await Product.findById(req.params.id);
    if (!existing) {
      return res.status(404).json({
        success: false,
        message: "Product not found",
      });
    }

    const oldStock = Number(existing.stock) || 0;

    const product = await Product.findByIdAndUpdate(
      req.params.id,
      req.body,
      {
        new: true,
        runValidators: true,
      }
    );

    if (req.body.stock !== undefined) {
      const newStock = Number(req.body.stock);
      if (!isNaN(newStock) && newStock !== oldStock) {
        try {
          const diff = Math.abs(newStock - oldStock);
          await Movement.create({
            productId: product._id,
            type: newStock > oldStock ? "STOCK_IN" : "STOCK_OUT",
            quantity: diff,
            previousStock: oldStock,
            newStock: newStock,
            reason: "Manual Stock Adjustment",
            reference: product.sku || "ADJUST",
          });
        } catch (movErr) {
          console.error("Update movement logging error:", movErr);
        }
      }
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
    const { id } = req.params;

    const product = await Product.findByIdAndDelete(id);

    if (!product) {
      return res.status(404).json({
        success: false,
        message: "Product not found",
      });
    }

    // Clean up associated variants if any
    await Variant.deleteMany({
      productId: id,
    });

    return res.status(200).json({
      success: true,
      message: "Product deleted successfully",
      id,
    });
  } catch (error) {
    console.error("DELETE PRODUCT ERROR:", error);
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// =============================
// GET INVENTORY STATS SUMMARY
// =============================
exports.getInventoryStats = async (req, res) => {
  try {
    const products = await Product.find({}, "stock sellingPrice purchasePrice lowStockThreshold");

    let totalProducts = products.length;
    let totalStock = 0;
    let lowStockCount = 0;
    let outOfStockCount = 0;
    let totalValue = 0;

    for (const p of products) {
      const stock = Number(p.stock) || 0;
      const price = Number(p.sellingPrice) || Number(p.purchasePrice) || 0;

      totalStock += stock;
      totalValue += stock * price;

      if (stock === 0) {
        outOfStockCount++;
      } else if (stock < 10) {
        lowStockCount++;
      }
    }

    return res.status(200).json({
      success: true,
      stats: {
        totalProducts,
        totalStock,
        lowStockCount,
        outOfStockCount,
        totalValue,
      },
    });
  } catch (error) {
    console.error("GET INVENTORY STATS ERROR:", error);
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
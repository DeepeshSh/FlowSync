const Variant = require("../models/Variant");
const Product = require("../models/Product");

// ======================================
// SYNC PRODUCT STOCK
// ======================================

async function syncProductStock(productId) {
  try {
    const variants = await Variant.find({
      productId,
      isActive: true,
    });

    let totalStock = 0;

    for (const variant of variants) {
      totalStock += variant.stock;
    }

    await Product.findByIdAndUpdate(
      productId,
      {
        stock: totalStock,
      }
    );
  } catch (error) {
    console.error(
      "SYNC PRODUCT STOCK ERROR:",
      error
    );
  }
}

// ======================================
// CREATE VARIANT
// ======================================

exports.createVariant = async (req, res) => {
  try {
    const {
      productId,
      variantName,
      sku,
      barcode,
      warehouseId,
      storageLocation,
      stock,
      reservedStock,
      lowStockThreshold,
      purchasePrice,
      sellingPrice,
      mrp,
      gstPercentage,
      imageUrl,
      isActive,
    } = req.body;

    // ===========================
    // VALIDATION
    // ===========================

    if (
      !productId ||
      !variantName ||
      !sku ||
      !warehouseId
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Product, Variant Name, SKU and Warehouse are required.",
      });
    }

    // ===========================
    // CHECK PRODUCT
    // ===========================

    const product =
      await Product.findById(productId);

    if (!product) {
      return res.status(404).json({
        success: false,
        message: "Product not found.",
      });
    }

    // ===========================
    // DUPLICATE SKU
    // ===========================

    const existingVariant =
      await Variant.findOne({
        sku: sku.toUpperCase(),
      });

    if (existingVariant) {
      return res.status(400).json({
        success: false,
        message:
          "Variant SKU already exists.",
      });
    }

    // ===========================
    // CREATE VARIANT
    // ===========================

    const variant =
      await Variant.create({
        productId,
        variantName,
        sku: sku.toUpperCase(),
        barcode,
        warehouseId,
        storageLocation,
        stock,
        reservedStock,
        lowStockThreshold,
        purchasePrice,
        sellingPrice,
        mrp,
        gstPercentage,
        imageUrl,
        isActive,
      });

    // ===========================
    // UPDATE PRODUCT
    // ===========================

    await Product.findByIdAndUpdate(
      productId,
      {
        hasVariants: true,
      }
    );

    await syncProductStock(productId);

    res.status(201).json({
      success: true,
      message:
        "Variant created successfully.",
      data: variant,
    });

  } catch (error) {

    console.error(
      "CREATE VARIANT ERROR:",
      error
    );

    res.status(500).json({
      success: false,
      message: error.message,
    });

  }
};

// ======================================
// GET ALL VARIANTS
// ======================================

exports.getVariants = async (
  req,
  res
) => {
  try {

    const variants =
      await Variant.find()

        .populate(
          "productId",
          "name sku brandName category"
        )

        .populate(
          "warehouseId",
          "name code"
        )

        .sort({
          createdAt: -1,
        });

    res.status(200).json({
      success: true,
      count: variants.length,
      data: variants,
    });

  } catch (error) {

    console.error(
      "GET VARIANTS ERROR:",
      error
    );

    res.status(500).json({
      success: false,
      message: error.message,
    });

  }
};
exports.getVariantById = async (req, res) => {
    try {
  
      const variant = await Variant.findById(req.params.id)
        .populate("productId", "name sku brandName category")
        .populate("warehouseId", "name code");
  
      if (!variant) {
        return res.status(404).json({
          success: false,
          message: "Variant not found.",
        });
      }
  
      res.status(200).json({
        success: true,
        data: variant,
      });
  
    } catch (error) {
  
      console.error(error);
  
      res.status(500).json({
        success: false,
        message: error.message,
      });
  
    }
  };
  
  exports.getVariantsByProduct = async (req, res) => {
    try {
  
      const variants = await Variant.find({
        productId: req.params.productId,
        isActive: true,
      })
        .populate("warehouseId", "name code")
        .sort({
          variantName: 1,
        });
  
      res.status(200).json({
        success: true,
        count: variants.length,
        data: variants,
      });
  
    } catch (error) {
  
      console.error(error);
  
      res.status(500).json({
        success: false,
        message: error.message,
      });
  
    }
  };
  
  exports.updateVariant = async (req, res) => {
    try {
  
      const oldVariant = await Variant.findById(
        req.params.id
      );
  
      if (!oldVariant) {
        return res.status(404).json({
          success: false,
          message: "Variant not found.",
        });
      }
  
      if (
        req.body.sku &&
        req.body.sku.toUpperCase() !== oldVariant.sku
      ) {
  
        const duplicate = await Variant.findOne({
          sku: req.body.sku.toUpperCase(),
          _id: { $ne: req.params.id },
        });
  
        if (duplicate) {
          return res.status(400).json({
            success: false,
            message: "SKU already exists.",
          });
        }
  
        req.body.sku =
            req.body.sku.toUpperCase();
      }
  
      const variant =
          await Variant.findByIdAndUpdate(
        req.params.id,
        req.body,
        {
          new: true,
          runValidators: true,
        }
      );
  
      await syncProductStock(
        variant.productId
      );
  
      res.status(200).json({
        success: true,
        message:
            "Variant updated successfully.",
        data: variant,
      });
  
    } catch (error) {
  
      console.error(error);
  
      res.status(500).json({
        success: false,
        message: error.message,
      });
  
    }
  };
  exports.deleteVariant = async (req, res) => {
    try {
  
      const variant = await Variant.findById(req.params.id);
  
      if (!variant) {
        return res.status(404).json({
          success: false,
          message: "Variant not found.",
        });
      }
  
      const productId = variant.productId;
  
      await Variant.findByIdAndDelete(req.params.id);
  
      const remainingVariants =
          await Variant.countDocuments({
        productId,
        isActive: true,
      });
  
      await Product.findByIdAndUpdate(
        productId,
        {
          hasVariants: remainingVariants > 0,
        }
      );
  
      await syncProductStock(productId);
  
      res.status(200).json({
        success: true,
        message: "Variant deleted successfully.",
      });
  
    } catch (error) {
  
      console.error(error);
  
      res.status(500).json({
        success: false,
        message: error.message,
      });
  
    }
  };
  
  exports.getVariantsByWarehouse = async (
    req,
    res
  ) => {
    try {
  
      const variants = await Variant.find({
        warehouseId: req.params.warehouseId,
        isActive: true,
      })
        .populate(
          "productId",
          "name sku brandName category"
        )
        .sort({
          variantName: 1,
        });
  
      res.status(200).json({
        success: true,
        count: variants.length,
        data: variants,
      });
  
    } catch (error) {
  
      console.error(error);
  
      res.status(500).json({
        success: false,
        message: error.message,
      });
  
    }
  };
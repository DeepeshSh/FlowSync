const Sale = require("../models/Sale");
exports.createSale = async (req, res) => {
  try {
    console.log("===== CREATE SALE HIT =====");
    console.log(req.body);

    const sale = await Sale.create(req.body);

    res.status(201).json(sale);
  } catch (error) {
    console.log(error);
    res.status(500).json({
      message: error.message,
    });
  }
};


exports.getSales =
  async (req, res) => {

    try {

      const sales =
        await Sale.find()
          .sort({
            createdAt: -1,
          });

      res.json(
        sales
      );

    } catch (error) {

      res.status(500).json({
        message:
          error.message,
      });
    }
  };

exports.getSaleById =
  async (req, res) => {

    try {

      const sale =
        await Sale.findById(
          req.params.id
        );

      res.json(
        sale
      );

    } catch (error) {

      res.status(500).json({
        message:
          error.message,
      });
    }
  };

exports.deleteSale =
  async (req, res) => {

    try {

      await Sale.findByIdAndDelete(
        req.params.id
      );

      res.json({
        message:
          "Sale Deleted",
      });

    } catch (error) {

      res.status(500).json({
        message:
          error.message,
      });
    }
  };
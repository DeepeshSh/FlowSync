const Purchase = require("../models/Purchase");

exports.createPurchase =
  async (req, res) => {
    try {
      const purchase =
        await Purchase.create(
          req.body
        );

      res.status(201).json(
        purchase
      );
    } catch (error) {
      res.status(500).json({
        message:
          error.message,
      });
    }
  };

exports.getPurchases =
  async (req, res) => {
    try {
      const purchases =
        await Purchase.find()
          .sort({
            createdAt: -1,
          });

      res.json(
        purchases
      );
    } catch (error) {
      res.status(500).json({
        message:
          error.message,
      });
    }
  };

exports.getPurchaseById =
  async (req, res) => {
    try {
      const purchase =
        await Purchase.findById(
          req.params.id
        );

      res.json(
        purchase
      );
    } catch (error) {
      res.status(500).json({
        message:
          error.message,
      });
    }
  };

exports.updatePurchase =
  async (req, res) => {
    try {
      const purchase =
        await Purchase.findByIdAndUpdate(
          req.params.id,
          req.body,
          {
            new: true,
          }
        );

      res.json(
        purchase
      );
    } catch (error) {
      res.status(500).json({
        message:
          error.message,
      });
    }
  };

exports.deletePurchase =
  async (req, res) => {
    try {
      await Purchase.findByIdAndDelete(
        req.params.id
      );

      res.json({
        message:
          "Purchase Deleted",
      });
    } catch (error) {
      res.status(500).json({
        message:
          error.message,
      });
    }
  };
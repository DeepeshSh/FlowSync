const Supplier = require("../models/Supplier");

exports.createSupplier =
  async (req, res) => {
    try {

      const supplier =
        await Supplier.create(
          req.body
        );

      res.status(201).json(
        supplier
      );

    } catch (error) {

      res.status(500).json({
        message:
          error.message,
      });
    }
  };

exports.getSuppliers =
  async (req, res) => {

    try {

      const suppliers =
        await Supplier.find()
          .sort({
            createdAt: -1,
          });

      res.json(
        suppliers
      );

    } catch (error) {

      res.status(500).json({
        message:
          error.message,
      });
    }
  };

exports.getSupplierById =
  async (req, res) => {

    try {

      const supplier =
        await Supplier.findById(
          req.params.id
        );

      res.json(
        supplier
      );

    } catch (error) {

      res.status(500).json({
        message:
          error.message,
      });
    }
  };

exports.updateSupplier =
  async (req, res) => {

    try {

      const supplier =
        await Supplier.findByIdAndUpdate(
          req.params.id,
          req.body,
          {
            new: true,
          }
        );

      res.json(
        supplier
      );

    } catch (error) {

      res.status(500).json({
        message:
          error.message,
      });
    }
  };

exports.deleteSupplier =
  async (req, res) => {

    try {

      await Supplier.findByIdAndDelete(
        req.params.id
      );

      res.json({
        message:
          "Supplier Deleted",
      });

    } catch (error) {

      res.status(500).json({
        message:
          error.message,
      });
    }
  };
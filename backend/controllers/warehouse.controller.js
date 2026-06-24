const Warehouse = require(
    "../models/warehouse"
  );
  
  // CREATE WAREHOUSE
  
  exports.createWarehouse =
  async (req, res) => {
  
    try {
  
      const warehouse =
        await Warehouse.create(
          req.body
        );
  
      res.status(201).json(
        warehouse
      );
  
    } catch (error) {
  
      res.status(500).json({
        message: error.message,
      });
    }
  };
  
  // GET ALL WAREHOUSES
  
  exports.getWarehouses =
  async (req, res) => {
  
    try {
  
      const warehouses =
        await Warehouse.find();
  
      res.json(
        warehouses
      );
  
    } catch (error) {
  
      res.status(500).json({
        message: error.message,
      });
    }
  };
  
  // GET SINGLE WAREHOUSE
  
  exports.getWarehouseById =
  async (req, res) => {
  
    try {
  
      const warehouse =
        await Warehouse.findById(
          req.params.id
        );
  
      if (!warehouse) {
  
        return res
          .status(404)
          .json({
            message:
              "Warehouse not found",
          });
      }
  
      res.json(
        warehouse
      );
  
    } catch (error) {
  
      res.status(500).json({
        message: error.message,
      });
    }
  };
  
  // UPDATE
  
  exports.updateWarehouse =
  async (req, res) => {
  
    try {
  
      const warehouse =
        await Warehouse.findByIdAndUpdate(
          req.params.id,
          req.body,
          { new: true }
        );
  
      res.json(
        warehouse
      );
  
    } catch (error) {
  
      res.status(500).json({
        message: error.message,
      });
    }
  };
  
  // DELETE
  
  exports.deleteWarehouse =
  async (req, res) => {
  
    try {
  
      await Warehouse.findByIdAndDelete(
        req.params.id
      );
  
      res.json({
        message:
          "Warehouse deleted",
      });
  
    } catch (error) {
  
      res.status(500).json({
        message: error.message,
      });
    }
  };
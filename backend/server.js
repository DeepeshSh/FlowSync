require("dotenv").config();

const express = require("express");
const connectDB = require("./config/db");

const categoryRoutes =
require("./routes/category.routes");

const productRoutes =
require("./routes/product.routes");

const purchaseRoutes =
require("./routes/purchaseRoutes");

const supplierRoutes =
require("./routes/supplierRoutes");

const app = express();

app.use(express.json());

connectDB();

app.get("/", (req, res) => {
  res.send("Inventory API Running");
});

app.use(
  "/api/categories",
  categoryRoutes
);

app.use(
  "/api/products",
  productRoutes
);

app.use(
  "/api/auth",
  require("./routes/auth.routes")
);

app.use(
  "/api/purchases",
  purchaseRoutes
);

app.use(
  "/api/suppliers",
  supplierRoutes
);

const PORT =
process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(
    `Server Running On Port ${PORT}`
  );
});
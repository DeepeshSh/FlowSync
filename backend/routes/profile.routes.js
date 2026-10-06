const express = require("express");
const router = express.Router();
const authMiddleware = require("../middleware/authMiddleware");

const {
  getProfile,
  updateProfile,
  updatePersonalProfile,
  updateBusinessProfile,
  deleteAccount,
} = require("../controllers/profile.controller");

router.use(authMiddleware);

router.get("/", getProfile);
router.put("/", updateProfile);
router.put("/personal", updatePersonalProfile);
router.put("/business", updateBusinessProfile);
router.delete("/", deleteAccount);

module.exports = router;

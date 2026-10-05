const express = require("express");
const router = express.Router();

const {
  getProfile,
  updateProfile,
  updatePersonalProfile,
  updateBusinessProfile,
  deleteAccount,
} = require("../controllers/profile.controller");

router.get("/", getProfile);
router.put("/", updateProfile);
router.put("/personal", updatePersonalProfile);
router.put("/business", updateBusinessProfile);
router.delete("/", deleteAccount);

module.exports = router;

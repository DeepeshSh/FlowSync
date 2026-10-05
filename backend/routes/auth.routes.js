const express = require("express");

const router =
    express.Router();

const {
  register,
  login,
  getMe,
  forgotPassword,
  googleAuth,
} = require(
  "../controllers/auth.controller"
);

const authMiddleware = require("../middleware/authMiddleware");

router.post(
  "/register",
  register,
);

router.post(
  "/login",
  login,
);

router.post(
  "/google",
  googleAuth,
);

router.post(
  "/forgot-password",
  forgotPassword,
);

router.get(
  "/me",
  authMiddleware,
  getMe,
);

module.exports = router;
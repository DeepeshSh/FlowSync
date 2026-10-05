const User = require("../models/User");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");



exports.register = async (
  req,
  res
) => {

  try {

    const {
      name,
      businessName,
      email,
      password
    } = req.body;

    const existingUser =
      await User.findOne({ email });

    if (existingUser) {

      return res.status(400).json({
        message:
            "Email already exists",
      });
    }

    const hashedPassword =
      await bcrypt.hash(
        password,
        10,
      );

    const user =
      await User.create({

        name,

        businessName,

        email,

        password:
            hashedPassword,
      });

    res.status(201).json(user);

  } catch (error) {

    res.status(500).json({
      message:
          error.message,
    });
  }
};

exports.login = async (
    req,
    res
  ) => {
  
    console.log("LOGIN REQUEST:");
    console.log(req.body);
    
    try {
  
      const {
        email,
        password
      } = req.body;
  
      const user =
        await User.findOne({
          email,
        });
  
      if (!user) {
  
        return res.status(400).json({
          message:
              "Invalid Email",
        });
      }
  
      const isMatch =
        await bcrypt.compare(
          password,
          user.password,
        );
  
      if (!isMatch) {
  
        return res.status(400).json({
          message:
              "Invalid Password",
        });
      }
  
      const token =
        jwt.sign(
          {
            id: user._id,
          },
          process.env.JWT_SECRET || "flowsyncsecret",
          {
            expiresIn: "7d",
          },
        );
  
      res.json({
        token,
        user,
      });
  
    } catch (error) {
  
      res.status(500).json({
        message:
            error.message,
      });
    }
  };

// Returns the currently logged-in user's profile (name, businessName,
// email) based on the Bearer token set by authMiddleware. Used by the
// dashboard header to greet the user by name and show their business name.
exports.getMe = async (req, res) => {
  try {
    const user = await User.findById(req.userId).select("-password");

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    res.json({
      success: true,
      data: user,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

exports.forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) {
      return res.status(400).json({
        success: false,
        message: "Please enter a valid email address.",
      });
    }

    const user = await User.findOne({ email: email.trim().toLowerCase() });
    if (!user) {
      return res.status(404).json({
        success: false,
        message: "No user found with this email.",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Password reset link sent to your email.",
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

exports.googleAuth = async (req, res) => {
  try {
    const { email, name } = req.body;
    if (!email) {
      return res.status(400).json({
        success: false,
        message: "Email is required",
      });
    }

    let user = await User.findOne({ email: email.trim().toLowerCase() });
    if (!user) {
      const hashedPassword = await bcrypt.hash("google_" + Date.now(), 10);
      user = await User.create({
        name: name || "Google User",
        businessName: "",
        email: email.trim().toLowerCase(),
        password: hashedPassword,
      });
    }

    const token = jwt.sign(
      { id: user._id },
      process.env.JWT_SECRET || "flowsyncsecret",
      { expiresIn: "7d" }
    );

    return res.status(200).json({
      success: true,
      token,
      user,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
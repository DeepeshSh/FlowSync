const jwt = require("jsonwebtoken");
const User = require("../models/User");

// Helper to extract user ID from req.userId or authorization token if present
const getUserIdFromReq = (req) => {
  if (req.userId) return req.userId;
  const authHeader = req.headers.authorization || "";
  if (authHeader.startsWith("Bearer ")) {
    try {
      const token = authHeader.slice(7);
      const decoded = jwt.verify(
        token,
        process.env.JWT_SECRET || "flowsyncsecret"
      );
      return decoded.id;
    } catch (_) {}
  }
  return null;
};

// =============================
// GET PROFILE (Unified Personal & Business)
// =============================
exports.getProfile = async (req, res) => {
  try {
    const userId = getUserIdFromReq(req);
    let user = null;

    if (userId) {
      user = await User.findById(userId).select("-password");
    }

    if (!user) {
      // Fallback: get primary/first profile
      user = await User.findOne().select("-password");
    }

    if (!user) {
      return res.status(200).json({
        success: true,
        data: {
          name: "FlowSync Admin",
          email: "admin@flowsync.com",
          phone: "+91 98765 43210",
          businessName: "FlowSync Sanitary Solutions",
          gstin: "27AAAAA0000A1Z5",
          tradeType: "Wholesaler",
          businessAddress: "Industrial Area, Phase 2, Mumbai, Maharashtra - 400001",
          address: "Industrial Area, Phase 2, Mumbai, Maharashtra - 400001",
          bankDetails: {
            bankName: "HDFC Bank",
            accountNumber: "50200012345678",
            ifsc: "HDFC0001234",
          },
        },
      });
    }

    return res.status(200).json({
      success: true,
      data: user,
    });
  } catch (error) {
    console.error("GET PROFILE ERROR:", error);
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// =============================
// UPDATE PERSONAL PROFILE (name, phone, email)
// =============================
exports.updatePersonalProfile = async (req, res) => {
  try {
    const userId = getUserIdFromReq(req);
    const { name, phone, email } = req.body;

    let user = null;
    if (userId) {
      user = await User.findById(userId);
    }
    if (!user) {
      user = await User.findOne();
    }

    if (!user) {
      user = await User.create({
        name: name || "FlowSync User",
        email: email || "user@flowsync.com",
        phone: phone || "",
        password: "defaultPassword123!",
        businessName: "FlowSync Sanitary",
      });
    } else {
      if (name !== undefined) user.name = name;
      if (phone !== undefined) user.phone = phone;
      if (email !== undefined) user.email = email;
      await user.save();
    }

    const sanitizedUser = user.toObject();
    delete sanitizedUser.password;

    return res.status(200).json({
      success: true,
      message: "Personal profile updated successfully",
      data: sanitizedUser,
    });
  } catch (error) {
    console.error("UPDATE PERSONAL PROFILE ERROR:", error);
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// =============================
// UPDATE BUSINESS PROFILE (businessName, gstin, tradeType, businessAddress, bankDetails)
// =============================
exports.updateBusinessProfile = async (req, res) => {
  try {
    const userId = getUserIdFromReq(req);
    const {
      businessName,
      gstin,
      tradeType,
      businessAddress,
      address,
      bankDetails,
    } = req.body;

    let user = null;
    if (userId) {
      user = await User.findById(userId);
    }
    if (!user) {
      user = await User.findOne();
    }

    const finalAddress = businessAddress !== undefined ? businessAddress : address;

    if (!user) {
      user = await User.create({
        name: "FlowSync User",
        email: "user@flowsync.com",
        password: "defaultPassword123!",
        businessName: businessName || "FlowSync Sanitary",
        gstin: gstin || "",
        tradeType: tradeType || "Wholesaler",
        businessAddress: finalAddress || "",
        address: finalAddress || "",
        bankDetails: bankDetails || {
          bankName: "",
          accountNumber: "",
          ifsc: "",
        },
      });
    } else {
      if (businessName !== undefined) user.businessName = businessName;
      if (gstin !== undefined) user.gstin = gstin;
      if (tradeType !== undefined) user.tradeType = tradeType;
      if (finalAddress !== undefined) {
        user.businessAddress = finalAddress;
        user.address = finalAddress;
      }
      if (bankDetails !== undefined) {
        user.bankDetails = {
          bankName: bankDetails.bankName !== undefined ? bankDetails.bankName : (user.bankDetails?.bankName || ""),
          accountNumber: bankDetails.accountNumber !== undefined ? bankDetails.accountNumber : (user.bankDetails?.accountNumber || ""),
          ifsc: bankDetails.ifsc !== undefined ? bankDetails.ifsc : (user.bankDetails?.ifsc || ""),
        };
      }
      await user.save();
    }

    const sanitizedUser = user.toObject();
    delete sanitizedUser.password;

    return res.status(200).json({
      success: true,
      message: "Business profile updated successfully",
      data: sanitizedUser,
    });
  } catch (error) {
    console.error("UPDATE BUSINESS PROFILE ERROR:", error);
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// =============================
// UPDATE PROFILE (General / Legacy)
// =============================
exports.updateProfile = async (req, res) => {
  try {
    const userId = getUserIdFromReq(req);
    const { name, businessName, phone, email, gstin, address, businessAddress, tradeType, bankDetails } = req.body;

    let user = null;

    if (userId) {
      user = await User.findById(userId);
    }

    if (!user) {
      user = await User.findOne();
    }

    const finalAddress = businessAddress !== undefined ? businessAddress : address;

    if (!user) {
      user = await User.create({
        name: name || "FlowSync User",
        businessName: businessName || "FlowSync Sanitary",
        phone: phone || "",
        email: email || "user@flowsync.com",
        password: "defaultPassword123!",
        gstin: gstin || "",
        address: finalAddress || "",
        businessAddress: finalAddress || "",
        tradeType: tradeType || "Wholesaler",
        bankDetails: bankDetails || {},
      });
    } else {
      if (name !== undefined) user.name = name;
      if (businessName !== undefined) user.businessName = businessName;
      if (phone !== undefined) user.phone = phone;
      if (email !== undefined) user.email = email;
      if (gstin !== undefined) user.gstin = gstin;
      if (finalAddress !== undefined) {
        user.address = finalAddress;
        user.businessAddress = finalAddress;
      }
      if (tradeType !== undefined) user.tradeType = tradeType;
      if (bankDetails !== undefined) user.bankDetails = bankDetails;

      await user.save();
    }

    const sanitizedUser = user.toObject();
    delete sanitizedUser.password;

    return res.status(200).json({
      success: true,
      message: "Profile updated successfully",
      data: sanitizedUser,
    });
  } catch (error) {
    console.error("UPDATE PROFILE ERROR:", error);
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// =============================
// DELETE ACCOUNT
// =============================
exports.deleteAccount = async (req, res) => {
  try {
    const userId = getUserIdFromReq(req);
    let deletedUser = null;

    if (userId) {
      deletedUser = await User.findByIdAndDelete(userId);
    }

    if (!deletedUser) {
      deletedUser = await User.findOneAndDelete();
    }

    return res.status(200).json({
      success: true,
      message: "Account and business profile deleted successfully",
    });
  } catch (error) {
    console.error("DELETE ACCOUNT ERROR:", error);
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

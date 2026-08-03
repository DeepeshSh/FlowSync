const jwt = require("jsonwebtoken");

// Reads the "Authorization: Bearer <token>" header, verifies it against
// the same secret used at login, and attaches the decoded user id to
// req.userId for downstream controllers to use.
module.exports = function authMiddleware(req, res, next) {
  try {
    const authHeader = req.headers.authorization || "";
    const token = authHeader.startsWith("Bearer ")
      ? authHeader.slice(7)
      : null;

    if (!token) {
      return res.status(401).json({
        success: false,
        message: "No auth token provided.",
      });
    }

    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET || "flowsyncsecret"
    );

    req.userId = decoded.id;
    next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: "Invalid or expired token.",
    });
  }
};

const express = require("express");
const router = express.Router();

const {
  getParties,
  getPartyById,
  createParty,
  updateParty,
  deleteParty,
} = require("../controllers/party.controller");

router.get("/", getParties);
router.get("/:id", getPartyById);
router.post("/", createParty);
router.put("/:id", updateParty);
router.delete("/:id", deleteParty);

module.exports = router;

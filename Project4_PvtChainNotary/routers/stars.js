const express = require("express");
const router = express.Router();
const {blockchain} = require('./block');

// GET a star by hash
router.get('/hash::blockHash', async (req, res) => {
    const hash = req.params.blockHash;
    
    try {
        let block = await blockchain.getBlockWithHash(hash);
        return res.status(202).send(block);
    } catch (e) {
        return res.status(404).send(e);
    }
});

module.exports = router;
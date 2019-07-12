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

// GET stars by wallet address
router.get('/address::walletAddress', async (req, res) => {
    const walletAddress = req.params.walletAddress;
    try {
        let allBlocks = await blockchain.getBlockWithAddress(walletAddress);
        return res.status(202).send(allBlocks);
        
    } catch (e) {
        return res.status(404).send(e);
    }
});

module.exports = router;
const express = require("express");
const router = express.Router();
const {Block, Blockchain} = require("../simpleChain");
const {
    bodySchema,
    validateBody,
    starRegisterSchema
    
} = require('../utility/joi');
const {requestCache} = require('./requestValidation');
const {ASCII2Hexa, Hexa2ASCII} = require('../utility/encodeDecode');

// initiating a new Blockchain with genesis on server startup
let blockchain = new Blockchain();

// POST a star block to chain after registration validated
router.post('/', async (req, res) => {
    try {
        
        // first validate the request body if it is in the right
        // format
        const validationResult = validateBody(req.body, starRegisterSchema);
        if (validationResult.error) {
            throw new Error(validationResult.error.details[0].message);
        }
        
        // then check if the wallet address in the request body is
        // registered to buy a star
        let walletAddress = req.body.address;
        if (!requestCache[walletAddress] || !requestCache[walletAddress].registerStar) {
            throw new Error('The given wallet address has either' +
                                ' not registered to notarise a' +
                                ' star, or is making a request' +
                                ' past the validation window.');
        }
        
        // if everything is passed then send the registration response
        let reqBody = req.body;
        reqBody.star.story = ASCII2Hexa(reqBody.star.story);
        
        // if validation passes, create a new block
        let newBlock = new Block(reqBody);
        let blockAddResult = await blockchain.addBlock(newBlock);
        return res.send(blockAddResult);
        
    } catch (e) {
        return res.status(404).send(e.message);
    }
    
});

// GET a star by blockheight
router.get('/:blockHeight', async (req, res) => {
    const blockHeight = parseInt(req.params.blockHeight);
    if (Number.isNaN(blockHeight)) {
        return res.status(404)
                  .send('Invalid parameter for block height.');
    } else {
        let block = await blockchain.getBlock(blockHeight);
        block.body.star.storyDecoded = Hexa2ASCII(block.body.star.story);
        return res.send(block);
    }
    
});

module.exports = router;
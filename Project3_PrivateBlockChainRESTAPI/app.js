// import necessary files and libs
const Joi = require("joi");
const {Block, Blockchain} = require("./simpleChain");

// express related imports and initialisations
const express = require("express");
const app = express();
app.use(express.json());
const PORT = 8000;

// initiating a new Blockchain with genesis on server startup
let blockchain = new Blockchain();

// GET a list of all blocks in the chain
app.get('/', async (req, res) => {
    let allBlocks = await blockchain.getALLBlocks();
    return res.send(allBlocks);
});

// GET the info of a block against a blockHeight
app.get('/block/:blockHeight', async (req, res) => {
    const blockHeight = parseInt(req.params.blockHeight);
    if (Number.isNaN(blockHeight)) {
        return res.send('Invalid parameter for block height.');
    } else {
        let block = await blockchain.getBlock(blockHeight);
        return res.send(block);
    }
});

// POST request to add blocks to the chain
app.post('/block', async (req, res) => {
    try {
        const validationResult = validateBody(req.body);
        if (validationResult.error) {
            return res.status(404)
                      .send(`${validationResult.error.details[0].message}`);
        }
        
        // if validation passes, create a new block with body message
        let blockBodyData = req.body.body;
        let newBlock = new Block(blockBodyData);
        let blockAddResult = await blockchain.addBlock(newBlock);
        return res.send(blockAddResult);
        
    } catch (e) {
        return res.status(404).send(e.message);
    }
    
});

// Joi schema to validate POST request body
const schema = {
    body: Joi.string().min(3).required()
};

function validateBody(req) {
    return Joi.validate(req, schema);
}

app.listen(PORT, () => {
    console.log(`visit: http://localhost:${PORT}`);
});

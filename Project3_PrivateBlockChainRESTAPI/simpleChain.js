const cryptojs = require('crypto-js');
const db = require("./levelDB");

class Block {
    constructor(data) {
        this.hash = "";
        this.height = 0;
        this.body = data;
        this.time = 0;
        this.previousBlockHash = "";
    }
}

class Blockchain {
    
    constructor() {
        this.getBlockHeight()
            .then(async (latestBlockHeight) => {
                if (latestBlockHeight >= 0) {
                    console.log("genesis already exists. " +
                                    "new chain creation halted");
                } else {
                    console.log("creating new chain with genesis");
                    await this.addBlock(new Block("genesis block"));
                }
            })
            .catch((err) => {
                console.log(err);
            });
    }
    
    // Add new block
    async addBlock(newBlock) {
        
        // first check if genesis block or other blocks exist or not
        try {
            let chainLength = (await db.readAllOrWriteToLevelDB(
                null,
                null,
                true)).chainLength;
            
            // blockHeight after this block is added = previous
            // ChainLength
            newBlock.height = chainLength;
            
            // add current UTC timestamp to body
            newBlock.time = new Date().getTime().toString().slice(0, -3);
            
            // populate previous block hash field
            if (chainLength > 0) {
                let latestBlockHeight = await this.getBlockHeight();
                newBlock.previousBlockHash = (await this.getBlock(latestBlockHeight)).hash;
            }
            
            // Block hash with cryptojs.SHA256 using newBlock and
            // converting to a string
            newBlock.hash = cryptojs.SHA256(JSON.stringify(newBlock)).toString();
            
            // Adding block object to chain
            await db.readAllOrWriteToLevelDB(newBlock.height,
                                             JSON.stringify(newBlock).toString());
            return await this.getBlock(chainLength);
        } catch (e) {
            return e;
        }
        
    }
    
    // Returns the the height of the last added block
    async getBlockHeight() {
        
        try {
            return ((await db.readAllOrWriteToLevelDB(null,
                                                      null,
                                                      true)).chainLength) - 1;
        } catch (e) {
            return e;
        }
    }
    
    // get block when a blockHeight is supplied as key for DB query
    async getBlock(blockHeight) {
        // return object as a single string
        try {
            return JSON.parse(await db.getLevelDBData(blockHeight));
        } catch (e) {
            return e;
        }
        
    }
    
    // validate block
    async validateBlock(blockHeight) {
        
        // get block object
        let block = await this.getBlock(blockHeight);
        // get block hash
        let blockHash = block.hash;
        // remove block hash to test block integrity
        block.hash = '';
        // generate block hash
        let validBlockHash = cryptojs.SHA256(JSON.stringify(block)).toString();
        // Compare
        if (blockHash === validBlockHash) {
            return true;
        } else {
            console.log(`Block no: ${blockHeight} has invalid hash. \n
            Calculated Hash is: ${blockHash} \n
            Valid Hash is: ${validBlockHash}`);
            return false;
        }
    }
    
    // Validate blockchain
    async validateChain() {
        let errorLog = [];
        let latestBlockHeight = await this.getBlockHeight();
        
        for (let blockHeight = 0; blockHeight <= latestBlockHeight; blockHeight++) {
            
            // validate block
            if (!(await this.validateBlock(blockHeight))) {
                errorLog.push(blockHeight);
            }
            
            if (blockHeight < latestBlockHeight) {
                let currentBlockHash = (await this.getBlock(blockHeight)).hash;
                let nextBlockHash = (await this.getBlock(blockHeight + 1)).previousBlockHash;
                
                if (nextBlockHash !== currentBlockHash) {
                    errorLog.push(blockHeight);
                }
            }
        }
        
        if (errorLog.length > 0) {
            console.log('Block errors = ' + errorLog.length);
            console.log('Blocks: ' + errorLog);
        } else {
            console.log('No errors detected');
        }
    }
    
    // get all blocks
    async getALLBlocks() {
        try {
            let allBlocks = await db.readAllOrWriteToLevelDB(null, null, true);
            return allBlocks;
        } catch (e) {
            return e.message;
        }
    }
}

module.exports = {
    Block,
    Blockchain
};
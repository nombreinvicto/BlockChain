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
                true,
                3)).chainLength;
            
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
            
            // First save hash to - table 1: hash-> blockheight
            // hash to blockHeight is 1:1 relation
            await db.readAllOrWriteToLevelDB([1, newBlock.hash],
                                             newBlock.height, false, 1);
            
            // Second save walletaddress - table 2: height -> addr
            await db.readAllOrWriteToLevelDB([2, newBlock.body.address],
                                             newBlock.height, false, 2);
            
            // Adding block to chain - table 3: blockheight-> block
            await db.readAllOrWriteToLevelDB([3, newBlock.height],
                                             JSON.stringify(newBlock).toString(), false, 3);
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
                                                      true,
                                                      3)).chainLength) - 1;
        } catch (e) {
            return e;
        }
    }
    
    // get block when a blockHeight is supplied as key for DB query
    async getBlock(blockHeight) {
        // return object as a single string
        try {
            return JSON.parse(await db.getLevelDBData([3, blockHeight]));
        } catch (e) {
            return e;
        }
    }
    
    async getBlockWithHash(hash) {
        
        try {
            // first get the blockheight corresponding to hash
            let blockHeight = await db.getLevelDBData('1,' + hash);
            
            // next get the block corr to blockHeight
            return JSON.parse(await db.getLevelDBData('3,' + blockHeight));
            
        } catch (e) {
            return e;
        }
    }
    
    async getBlockWithAddr(addr) {
        
        try {
            // first get the blockheight corresponding to address
            let blockHeight = await db.getLevelDBData('2,' + addr);
            blockHeight = parseInt(blockHeight);
            
            // next get the block corr to blockHeight
            return JSON.parse(await db.getLevelDBData('3,' + blockHeight));
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
            let allBlocks = await db.readAllOrWriteToLevelDB(null, null, true, 3);
            return allBlocks;
        } catch (e) {
            return e.message;
        }
    }
}

module.exports = {
    Block,
    Blockchain,
};
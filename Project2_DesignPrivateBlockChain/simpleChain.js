/* ===== cryotojs.SHA256 with Crypto-js ===============================
 |  Learn more: Crypto-js: https://github.com/brix/crypto-js  |
 |  =========================================================*/

const cryotojs = require('crypto-js');
const db = require("./levelDB");

/* ===== Block Class ==============================
 |  Class with a constructor for block 			   |
 |  ===============================================*/

class Block {
    constructor(data) {
        this.hash = "";
        this.height = 0;
        this.body = data;
        this.time = 0;
        this.previousBlockHash = "";
    }
}

/* ===== Blockchain Class ==========================
 |  Class with a constructor for new blockchain 		|
 |  ================================================*/

class Blockchain {
    constructor() {
        
        this.getBlockHeight()
            .then(async (latestBlockHeight) => {
                if (latestBlockHeight >= 0) {
                    console.log("genesis already exists. using existing chain");
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
            
            // Block height
            newBlock.height = chainLength;
            
            // UTC timestamp
            newBlock.time = new Date().getTime().toString().slice(0, -3);
            
            // previous block hash
            if (chainLength > 0) {
                let latestBlockHeight = await this.getBlockHeight();
                
                newBlock.previousBlockHash = (await this.getBlock(latestBlockHeight)).hash;
            }
            // Block hash with cryotojs.SHA256 using newBlock and
            // converting to a string
            newBlock.hash = cryotojs.SHA256(JSON.stringify(newBlock)).toString();
            
            // Adding block object to chain
            await db.readAllOrWriteToLevelDB(newBlock.height,
                                             JSON.stringify(newBlock).toString());
        } catch (e) {
            console.log(e);
        }
        
    }
    
    // Get block height
    async getBlockHeight() {
        try {
            return ((await db.readAllOrWriteToLevelDB(null,
                                                      null,
                                                      true))
                .chainLength) - 1;
        } catch (e) {
            return e;
        }
    }
    
    // JSON.parse(JSON.stringify(this.chain[blockHeight]))
    
    // get block
    async getBlock(blockHeight) {
        // return object as a single string
        return JSON.parse(await db.getLevelDBData(blockHeight));
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
        let validBlockHash = cryotojs.SHA256(JSON.stringify(block)).toString();
        // Compare
        if (blockHash === validBlockHash) {
            return true;
        } else {
            console.log('Block #' + blockHeight + ' invalid hash:\n' + blockHash + '<>' + validBlockHash);
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
            
            if (blockHeight !== latestBlockHeight) {
                // get the current block and next block
            let iterBlock = await this.getBlock(blockHeight);
            let iterNextBlock = await this.getBlock(blockHeight + 1);
                // compare blocks hash link
            let blockHash = iterBlock.hash;
            let previousHash = iterNextBlock.previousBlockHash;
            if (blockHash !== previousHash) {
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
}

let chain = new Blockchain();

chain.getBlock(0).then((block) => {console.log(block);}).catch((err) => {console.log(err);});

chain.getBlockHeight().then((block) => {console.log(block);}).catch((err) => {console.log(err);});

chain.addBlock(new Block('block')).then((res) => {console.log(res);}).catch((err) => {console.log(err);});

db.readAllOrWriteToLevelDB(null, null, true).then((res) => {console.log(res);});

chain.validateBlock(0).then((block) => {console.log(block);}).catch((err) => {console.log(err);});

chain.validateChain().then((block) => {console.log(block);}).catch((err) => {console.log(err);});

db.readAllOrWriteToLevelDB(7, JSON.stringify({
    hash: "hackhash",
    height: 7,
    body: "hackdata",
    time: "1559976065",
    previousBlockHash: "5edb94433459b5329716aef2d56c2f7bfac06269414eeff982694646741b9568"
}), false).then((res) => {console.log(res);});
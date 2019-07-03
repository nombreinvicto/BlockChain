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
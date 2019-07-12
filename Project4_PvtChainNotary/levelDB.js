/* ===== Persist data with LevelDB ===================================
 |  Learn more: level: https://github.com/Level/level     |
 |  =============================================================*/

let level = require('level');
let chainDB = './chaindata';
let db = level(chainDB);

// Add data to levelDB with key/value pair
function addLevelDBData(key, value) {
    return new Promise((resolve, reject) => {
        db.put(key, value, function (err) {
            if (err) {
                reject(err.message);
            } else {
                resolve(`data with key:${key} and value:${value} added`);
            }
        });
    });
}

// Get data from levelDB with key
function getLevelDBData(key) {
    return new Promise((resolve, reject) => {
        db.get(key, function (err, value) {
            if (err) {
                reject(err.message);
            } else {
                resolve(value);
            }
        });
    });
}

// Add data to levelDB with value and key or Read all data from the DB
function readAllOrWriteToLevelDB(key, value, readFlag = false, tableId, walletaddres) {
    
    return new Promise((resolve, reject) => {
        let dataCounter = 0;
        let dataArray = [];
        
        db.createReadStream().on('data', function (data) {
            // this data var is a JSON object with a key property
            //which is a string and a value property also a string
            if (tableId.toString() !== '2') {
                // if table id not '2' means not doing a hash to
                // wallet address query
                if (data.key[0] === tableId.toString()) {
                    dataCounter++;
                    dataArray.push(data);
                }
            } else if (tableId.toString() === '2') {
                // if tableid is 2, means we are doing a block
                // height to wallet address query
                
                if (data.value.toString() === walletaddres) {
                    dataCounter++;
                    dataArray.push(data.key);
                }
            }
            
        }).on('error', function (err) {
            reject(err.message);
        }).on('close', function () {
            if (readFlag) {
                resolve(({
                    chainLength: dataCounter,
                    data: dataArray,
                }));
            } else {
                // this is yet another async function that returns
                // a promise
                addLevelDBData(key, value)
                    .then((res) => {
                        resolve(res);
                    })
                    .catch((err) => {
                        reject(err);
                    });
            }
        });
    });
}

module.exports = {
    getLevelDBData,
    readAllOrWriteToLevelDB,
    addLevelDBData
};
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
function getLevelDBData(blockHeight) {
    
    return new Promise((resolve, reject) => {
        db.get(blockHeight, function (err, value) {
            if (err) {
                reject(err.message);
            } else {
                resolve(value);
            }
        });
    });
    
}

// Add data to levelDB with value and key or Read all data from the DB
function readAllOrWriteToLevelDB(key, value, readFlag = false) {
    
    return new Promise((resolve, reject) => {
        let dataCounter = 0;
        let dataArray = [];
        
        db.createReadStream().on('data', function (data) {
            dataCounter++;
            dataArray.push(data);
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
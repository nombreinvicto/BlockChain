const btc = require("bitcoinjs-lib");
const btcMessage = require("bitcoinjs-message");

function verifySignature(message, address, signature) {
    return btcMessage.verify(message, address, signature);
}

module.exports = verifySignature;
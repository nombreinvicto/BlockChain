const Web3 = require("web3");
const Tx = require("ethereumjs-tx").Transaction;

const abiObject = require("./abi");
const scAddress = abiObject.scAddress;
const abi = abiObject.abi;
let rinkebyInfura = "https://rinkeby.infura.io/v3/d176758e64fb47eb8ba5a1d58933bf9a";

// initiating metamask environment
const web3 = new Web3(new Web3.providers.HttpProvider(rinkebyInfura));

// creating a smart contract
let sc_contract = new web3.eth.Contract(abi, scAddress);
let consumerAddress = '0x97698Ae226bE1573c5940dE64F50D12919826e54';
let pvtKey = "AC5B111E22685194F5A999FC34BBE2E7347BE0D51810933F0CDD98FD701FA446";
const privateKey = Buffer.from(pvtKey, 'hex');

let encodedABI = sc_contract.methods.initiatePurchaseOrder("mahmud", "raleigh", 1, 1).encodeABI();

web3.eth.getTransactionCount(consumerAddress).then(txCount => {
    const txData = {
        nonce: web3.utils.toHex(txCount),
        gasLimit: web3.utils.toHex(250000),
        gasPrice: web3.utils.toHex(10e9), // 10 Gwei
        from: consumerAddress,
        to: scAddress,
        data: encodedABI
    };
    
    const transaction = new Tx(txData,{'chain':'rinkeby'});
    transaction.sign(privateKey);
    const serialisedTx = transaction.serialize().toString('hex');
    
    web3.eth.sendSignedTransaction('0x' + serialisedTx,)
        .on("receipt", (receipt) => {
            console.log(receipt);
        })
        .on("error", (err) => {
            console.log("Error occured");
            console.log(err);
        })
});
























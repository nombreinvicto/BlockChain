// do all the necessary imports
const express = require("express");
const router = express.Router();
const {
    requestValidationSchema,
    validateBody
} = require('../utility/joi');
const walletAddrValidator = require('wallet-address-validator');

// create the global requester cache
let requestCache = {};

// POST request to request validate - initiates
// the notarisation process
router.post('/', async (req, res) => {
    
    try {
        const validationResult = validateBody(req.body, requestValidationSchema);
        if (validationResult.error) {
            return res.status(404)
                      .send(`${validationResult.error.details[0].message}`);
        }
        
        // validate the wallet address first
        let walletAddress = req.body.address;
        let validAddrStatus = walletAddrValidator
            .validate(walletAddress, 'BTC');
        
        // throw error in case of non bitcoin address
        if (!validAddrStatus) {
            throw new Error('Invalid Bitcoin Wallet Address Sent.');
        }
        
        // if validation passes, check if requester already in cache
        let requesterObject = requestCache[walletAddress];
        if (requesterObject) {
            // if requester exists, first check he is not already
            // in message signature process
            if (requesterObject.registerStar) {
                throw new Error('Requestor already in post' +
                                    ' message signature' +
                                    ' validation phase.' +
                                    ' Additional request' +
                                    ' initiation not possible.');
            }
            
            // if thats not the case, then reduce his validation
            // window. first get the current time
            let currentTimeStamp = new Date().getTime().toString().slice(0, -3);
            let timeElapsed = currentTimeStamp - requesterObject.requestTimeStamp;
            requesterObject.validationWindow = 300 - timeElapsed;
        } else {
            // if requester doesnt exist, then add him to cache
            let requestTimeStamp = new Date().getTime().toString().slice(0, -3);
            requesterObject = {
                walletAddress: walletAddress,
                requestTimeStamp: requestTimeStamp,
                message: walletAddress + ':' + requestTimeStamp + ':starRegistry',
                validationWindow: 300
            };
            
            // add new requester to cache
            requestCache[walletAddress] = requesterObject;
            
            // set to delete the requestor after validation window
            // expires
            setTimeout(() => {
                delete requestCache[walletAddress];
            }, requesterObject.validationWindow * 1000);
        }
        // otherwise proceed with the request and reply to the user
        return res.status(202).send(requesterObject);
    } catch (e) {
        return res.status(404).send(e.message);
    }
});

module.exports = {
    router,
    requestCache
};
const express = require("express");
const router = express.Router();
const {requestCache, validationWindowTime} = require('./requestValidation');
const {messageValidationSchema, validateBody} = require('../utility/joi');
const verifySignature = require('../utility/btc');

// POST request to request validate message signature
router.post('/validate', async (req, res) => {
    
    try {
        const validationResult = validateBody(req.body, messageValidationSchema);
        if (validationResult.error) {
            return res.status(404)
                      .send(`${validationResult.error.details[0].message}`);
        }
        
        let walletAddress = req.body.address;
        // if address is valid BTC, check if request has been made
        // within valid window or not
        let requesttorObject = requestCache[walletAddress];
        if (!requesttorObject) {
            throw new Error('Signature Validation Request made' +
                                ' past valid window period or the' +
                                ' wallet address has not yet gone' +
                                ' through request validation phase.');
        }
        
        // if requestor still in cache then verify signature
        if (requesttorObject) {
            let message = requestCache[walletAddress].message;
            // if message is undefined means user is resending
            // request for message signature validation - then
            // reduce his validation window
            if (!message) {
                let requestTimeStamp = requestCache[walletAddress].status.requestTimeStamp;
                let currentTime = new Date().getTime().toString().slice(0, -3);
                let timeElapased = currentTime - requestTimeStamp;
                requesttorObject.status.validationWindow = validationWindowTime - timeElapased;
                return res.status(202).send(requesttorObject);
            }
            
            if (!verifySignature(message, walletAddress, req.body.signature)) {
                throw new Error('Given Wallet Address and Signature do' +
                                    ' not combine to form valid' +
                                    ' message signature');
                
            }
            
            // if sign is valid then return right response
            let requestTimeStamp = requestCache[walletAddress].requestTimeStamp;
            let currentTime = new Date().getTime().toString().slice(0, -3);
            let timeElapased = currentTime - requestTimeStamp;
            let response = {
                registerStar: true,
                status: {
                    address: walletAddress,
                    requestTimeStamp: requestTimeStamp,
                    message: message,
                    validationWindow: validationWindowTime - timeElapased,
                    messageSignature: true
                }
            };
            
            // update the cache object for the wallet address to
            // indicate it can now regiter a star
            requestCache[walletAddress] = response;
            return res.status(202).send(response);
        }
        
    } catch (e) {
        return res.status(404).send(e.message);
    }
});

module.exports = router;

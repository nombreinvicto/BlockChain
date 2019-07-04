
### Project 3: Design of a NodeJS based "no-consensus" Private BlockChain with REST API Interface

<p align="center">
    <img width="300" height="150"
         src="https://dzone.com/storage/temp/4801535-rest-api.jpg">
</p>

Description:

In this project, the NodeJS implementation of a private blockchain 
from [Project 2](https://github.com/nombreinvicto/BlockChain/tree/master/Project2_DesignPrivateBlockChain) 
has been re-implemented, but this time with a top layer
REST API web service to allow clients to easily interact with the 
blockchain backend using a REST client. The entry point of the 
project is the file named `app.js`. Any NodeJS interpreter can be 
used to run the file, which will spawn a local server in the `PORT: 
8000`. A user can make use of any REST Client like [Postman](https://www.getpostman.com/). 

The endpoint for GET-ting a block with a specific blockheight is:

`
http://localhost:8000/block/<blockHeight>
`

The endpoint for POST-ing a block with a specific blockheight is:

`
http://localhost:8000/block/
`

In case of POST requests like above, the request body of the POST 
should be a JSON object with a mandatory `body` field.
  
  
  Technology Used:
  * Javascript
  * NodeJS
  
  Libraries Used:
  * [crypto-js](https://www.npmjs.com/package/crypto-js)
  * [levelDB](https://github.com/Level/leveldown)
  * [Joi](https://www.npmjs.com/package/joi)
  * [Express.js](https://expressjs.com/)

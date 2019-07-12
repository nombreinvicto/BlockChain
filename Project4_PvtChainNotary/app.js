// import necessary files,libs and routers
const {router: blockRouter} = require("./routers/block");
const {router: reqValidRouter} = require("./routers/requestValidation");
const messageRouter = require("./routers/message");
const starRouter = require('./routers/stars');

// express related imports and initialisations
const express = require("express");
const app = express();
const PORT = 8000;

// register middlewares and routers
app.use(express.json()); // needed to parse request body as json
app.use('/block', blockRouter);
app.use('/requestValidation', reqValidRouter);
app.use('/message-signature', messageRouter);
app.use('/stars', starRouter);

// listen to the port and start the server
app.listen(PORT, () => {
    console.log(`visit: http://localhost:${PORT}`);
});
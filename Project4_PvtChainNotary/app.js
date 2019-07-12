// import necessary files,libs and routers
const blockRouter = require("./routers/block");
const {
    router: reqValidRouter,
    requestCache
} = require("./routers/requestValidation");
const messageRouter = require("./routers/message");

// express related imports and initialisations
const express = require("express");
const app = express();
const PORT = 8000;

// register middlewares and routers
app.use(express.json()); // needed to parse request body as json
app.use('/block', blockRouter);
app.use('/requestValidation', reqValidRouter);
app.use('/message-signature', messageRouter);

// listen to the port and start the server
app.listen(PORT, () => {
    console.log(`visit: http://localhost:${PORT}`);
});

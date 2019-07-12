const Joi = require("joi");

// Joi schema to validate POST request body for blocks
const bodySchema = {
    body: Joi.string().min(3).required()
};

// request validation POST request body
const requestValidationSchema = {
    address: Joi.string().min(10).required()
};

// message verification POST request body
const messageValidationSchema = {
    address: Joi.string().min(10).required(),
    signature: Joi.string().min(10).required()
};

// register star as block POST request body
const starRegisterSchema = {
    address: Joi.string().min(10).required(),
    star: Joi.object().keys({
                                dec: Joi.string().min(10).required(),
                                ra: Joi.string().min(10).required(),
                                story: Joi.string().min(10).required()
                            })
};

// universal validation function
function validateBody(req, schema) {
    return Joi.validate(req, schema);
}

module.exports = {
    bodySchema,
    requestValidationSchema,
    validateBody,
    messageValidationSchema,
    starRegisterSchema
};
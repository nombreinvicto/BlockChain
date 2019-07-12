function ASCII2Hexa(str) {
    let outArray = [];
    for (let char of str) {
        outArray.push(char.charCodeAt(0).toString(16));
    }
    return outArray.join("");
}

function Hexa2ASCII(str) {
    let hex = str.toString();
    let str_ = '';
    for (let n = 0; n < hex.length; n += 2) {
        str_ += String.fromCharCode(parseInt(hex.substr(n, 2), 16));
    }
    return str_;
}

module.exports = {
    ASCII2Hexa,
    Hexa2ASCII
};
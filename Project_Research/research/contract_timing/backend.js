const abiObject = require("./abi");
const scAddress = abiObject.scAddress;
const abi = abiObject.abi;
const Web3 = require("web3");
let consumerAddress = '0x97698Ae226bE1573c5940dE64F50D12919826e54';
let globalCounter = 0;

// initiating metamask environment
if (window.ethereum) {
    console.log("Connecting to Metamask");
    window.web3 = new Web3(ethereum);
    
    // Request account access if needed
    ethereum.enable().then((res) => {
        alert("User granted access to Metamask");
    }).catch((err) => {
        alert("User denied access to account");
        console.log(err);
        return;
    });
    
} else {
    // set the provider you want from Web3.providers
    alert("Metamask Wallet not available. Page Load Aborted. Please" +
              " install Metamask Plugin or use Brave Browser.");
    return;
}

// creating a smart contract
let sc_contract = new web3.eth.Contract(abi, scAddress);
let purchaseButton = document.getElementById("purchase");
let poText = document.getElementById('po');
let makeOrderButton = document.getElementById("makeOrder");

purchaseButton.addEventListener('click', () => {
    let now = null;
    globalCounter ++;
    sc_contract
        .methods
        .initiatePurchaseOrder("mahmud", "raleigh", 1, 1)
        .send({from: consumerAddress}, () => {
            now = new Date().getTime() / 1000;
        })
        .on("receipt", (receipt) => {
            let po = receipt.events.CreateQuoteForCustomer.returnValues[0];
            console.log("Global Counter is: ", globalCounter);
            console.log("PO is: ");
            console.log(po);
            let gasUsed = receipt.gasUsed;
            //console.log(receipt);
            console.log("Purchase Order Time: ", (new Date().getTime() / 1000) - now);
            console.log("Purchase Order gas: ", gasUsed);
            
            // now call make order
            let po_bn = web3.utils.toHex(po);
            let make_value = web3.utils.toHex('2000000000000000');
            sc_contract.methods.makeOrder(po_bn)
                       .send({
                                 from: consumerAddress,
                                 value: make_value
                             }, () => {
                           now = new Date().getTime() / 1000;
                       })
                       .on("receipt", (receipt) => {
                           //console.log(receipt);
                           let gasUsed = receipt.gasUsed;
                           console.log("Make Order Time: ", (new Date().getTime() / 1000) - now);
                           console.log("Make Order gas: ", gasUsed);
                
                           // now source the material
                           sc_contract.methods.sourceMaterial(po_bn)
                                      .send({
                                                from: consumerAddress
                                            }, () => {
                                          now = new Date().getTime() / 1000;
                                      })
                                      .on("receipt", (receipt) => {
                                          //console.log(receipt);
                                          let upc = receipt.events.Sourced.returnValues[0];
                                          let gasUsed = receipt.gasUsed;
                                          console.log("Sourcing Time: ", (new Date().getTime() / 1000) - now);
                                          console.log("Sourcing gas: ", gasUsed);
                    
                                          // now ship part to CNC
                                          let upc_bn = web3.utils.toHex(upc);
                                          sc_contract.methods.shipPartToCNC(upc_bn)
                                                     .send({from: consumerAddress}, () => {
                                                         now = new Date().getTime() / 1000;
                                                     })
                                                     .on("receipt", (receipt) => {
                                                         // not interested in
                                                         // gas calc
                        
                                                         // generatepart
                                                         sc_contract.methods.generatePart(upc_bn)
                                                                    .send({from: consumerAddress}, () => {
                                                                        now = new Date().getTime() / 1000;
                                                                    })
                                                                    .on("receipt", (receipt) => {
                                                                        let gasUsed = receipt.gasUsed;
                                                                        console.log("Gen Time: ", (new Date().getTime() / 1000) - now);
                                                                        console.log("Gen gas: ", gasUsed);
                                                                        console.log("=".repeat(50));
                                                                    });
                        
                                                     });
                    
                                      });
                       });
            
        });
    
});

// makeOrderButton.addEventListener('click', () => {
//     let po_value = document.getElementById('po').value;
//
//     // now call make order
//     let po_bn = web3.utils.toHex(po_value);
//     let make_value = web3.utils.toHex('2000000000000000');
//     sc_contract.methods.makeOrder(po_bn)
//                .send({
//                          from: consumerAddress,
//                          value: make_value
//                      }, () => {
//                    now = new Date().getTime() / 1000;
//                })
//                .on("receipt", (receipt) => {
//                    console.log(receipt);
//                });
//
// });





























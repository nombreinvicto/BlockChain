let sc_address= "0x45834a515DB452af7701d5C1C7Fd8b6C463289ab";
let sc_abi = [
    {
        "constant": true,
        "inputs": [
            {
                "name": "interfaceId",
                "type": "bytes4"
            }
        ],
        "name": "supportsInterface",
        "outputs": [
            {
                "name": "",
                "type": "bool"
            }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
    },
    {
        "constant": true,
        "inputs": [
            {
                "name": "tokenId",
                "type": "uint256"
            }
        ],
        "name": "getApproved",
        "outputs": [
            {
                "name": "",
                "type": "address"
            }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [
            {
                "name": "class",
                "type": "uint256"
            },
            {
                "name": "factor",
                "type": "uint256"
            }
        ],
        "name": "updateVolumeClassToFactorMapping",
        "outputs": [],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [
            {
                "name": "to",
                "type": "address"
            },
            {
                "name": "tokenId",
                "type": "uint256"
            }
        ],
        "name": "approve",
        "outputs": [],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [
            {
                "name": "purchaseOrder",
                "type": "uint256"
            }
        ],
        "name": "sourceMaterial",
        "outputs": [],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [
            {
                "name": "purchaseOrder",
                "type": "uint256"
            }
        ],
        "name": "makeOrder",
        "outputs": [],
        "payable": true,
        "stateMutability": "payable",
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [
            {
                "name": "from",
                "type": "address"
            },
            {
                "name": "to",
                "type": "address"
            },
            {
                "name": "tokenId",
                "type": "uint256"
            }
        ],
        "name": "transferFrom",
        "outputs": [],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "constant": true,
        "inputs": [
            {
                "name": "",
                "type": "uint256"
            }
        ],
        "name": "purchaseOrderToConsumerAddressMapping",
        "outputs": [
            {
                "name": "",
                "type": "address"
            }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [
            {
                "name": "upc",
                "type": "uint256"
            }
        ],
        "name": "receivePart",
        "outputs": [],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [
            {
                "name": "upc",
                "type": "uint256"
            }
        ],
        "name": "shipPartToCNC",
        "outputs": [],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [
            {
                "name": "class",
                "type": "uint256"
            }
        ],
        "name": "deleteVolumeClassToFactorMappingEntry",
        "outputs": [
            {
                "name": "",
                "type": "bool"
            }
        ],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "constant": true,
        "inputs": [
            {
                "name": "",
                "type": "uint256"
            }
        ],
        "name": "volumeClassToDaysMapping",
        "outputs": [
            {
                "name": "",
                "type": "uint256"
            }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [
            {
                "name": "from",
                "type": "address"
            },
            {
                "name": "to",
                "type": "address"
            },
            {
                "name": "tokenId",
                "type": "uint256"
            }
        ],
        "name": "safeTransferFrom",
        "outputs": [],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [
            {
                "name": "upc",
                "type": "uint256"
            }
        ],
        "name": "verifyPart",
        "outputs": [],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [
            {
                "name": "upc",
                "type": "uint256"
            }
        ],
        "name": "shipPartToDistributor",
        "outputs": [],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "constant": true,
        "inputs": [
            {
                "name": "tokenId",
                "type": "uint256"
            }
        ],
        "name": "ownerOf",
        "outputs": [
            {
                "name": "",
                "type": "address"
            }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
    },
    {
        "constant": true,
        "inputs": [
            {
                "name": "owner",
                "type": "address"
            }
        ],
        "name": "balanceOf",
        "outputs": [
            {
                "name": "",
                "type": "uint256"
            }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
    },
    {
        "constant": true,
        "inputs": [
            {
                "name": "cncOwnerAddress",
                "type": "address"
            }
        ],
        "name": "getOrderSucessHistory",
        "outputs": [
            {
                "name": "",
                "type": "uint256"
            },
            {
                "name": "",
                "type": "uint256"
            }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [
            {
                "name": "upc",
                "type": "uint256"
            }
        ],
        "name": "rejectPart",
        "outputs": [],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [
            {
                "name": "upc",
                "type": "uint256"
            }
        ],
        "name": "verificationRejection",
        "outputs": [],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "constant": true,
        "inputs": [
            {
                "name": "",
                "type": "uint256"
            }
        ],
        "name": "purchaseOrdersSendingMakeOrders",
        "outputs": [
            {
                "name": "",
                "type": "bool"
            }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
    },
    {
        "constant": true,
        "inputs": [
            {
                "name": "",
                "type": "uint256"
            }
        ],
        "name": "purchaseOrderToTimeStampMapping",
        "outputs": [
            {
                "name": "",
                "type": "uint256"
            }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [
            {
                "name": "class",
                "type": "uint256"
            },
            {
                "name": "unitprice",
                "type": "uint256"
            }
        ],
        "name": "updateMaterialClassToUnitPriceMapping",
        "outputs": [],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [
            {
                "name": "upc",
                "type": "uint256"
            }
        ],
        "name": "generatePart",
        "outputs": [],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [
            {
                "name": "to",
                "type": "address"
            },
            {
                "name": "approved",
                "type": "bool"
            }
        ],
        "name": "setApprovalForAll",
        "outputs": [],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [
            {
                "name": "_sourcer",
                "type": "address"
            },
            {
                "name": "_cncowner",
                "type": "address"
            },
            {
                "name": "_verifier",
                "type": "address"
            },
            {
                "name": "_distributor",
                "type": "address"
            },
            {
                "name": "_consumer",
                "type": "address"
            }
        ],
        "name": "updateActorAddresses",
        "outputs": [],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [
            {
                "name": "class",
                "type": "uint256"
            }
        ],
        "name": "deleteMaterialClassToUnitPriceMappingEntry",
        "outputs": [
            {
                "name": "",
                "type": "bool"
            }
        ],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [
            {
                "name": "upc",
                "type": "uint256"
            }
        ],
        "name": "shipPartToTheConsumer",
        "outputs": [],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [
            {
                "name": "from",
                "type": "address"
            },
            {
                "name": "to",
                "type": "address"
            },
            {
                "name": "tokenId",
                "type": "uint256"
            },
            {
                "name": "_data",
                "type": "bytes"
            }
        ],
        "name": "safeTransferFrom",
        "outputs": [],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [],
        "name": "registerCncOwner",
        "outputs": [],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [
            {
                "name": "custName",
                "type": "string"
            },
            {
                "name": "custLoc",
                "type": "string"
            },
            {
                "name": "volumeClass",
                "type": "uint256"
            },
            {
                "name": "materialClass",
                "type": "uint256"
            }
        ],
        "name": "initiatePurchaseOrder",
        "outputs": [],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [
            {
                "name": "upc",
                "type": "uint256"
            }
        ],
        "name": "acceptPart",
        "outputs": [],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "constant": true,
        "inputs": [
            {
                "name": "owner",
                "type": "address"
            },
            {
                "name": "operator",
                "type": "address"
            }
        ],
        "name": "isApprovedForAll",
        "outputs": [
            {
                "name": "",
                "type": "bool"
            }
        ],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [
            {
                "name": "upc",
                "type": "uint256"
            }
        ],
        "name": "shipPartToVerifier",
        "outputs": [],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "constructor"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "name": "purchaseOrder",
                "type": "uint256"
            }
        ],
        "name": "InitiatedPurchaseOrder",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "name": "purchaseOrder",
                "type": "uint256"
            },
            {
                "indexed": false,
                "name": "price",
                "type": "uint256"
            },
            {
                "indexed": false,
                "name": "completionTime",
                "type": "uint256"
            },
            {
                "indexed": false,
                "name": "cncOwnerAddressDelegated",
                "type": "address"
            }
        ],
        "name": "CreateQuoteForCustomer",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "name": "purchaseOrder",
                "type": "uint256"
            }
        ],
        "name": "SendMakeOrderToCncOwner",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "name": "upc",
                "type": "uint256"
            }
        ],
        "name": "Sourced",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "name": "upc",
                "type": "uint256"
            }
        ],
        "name": "Processed",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "name": "upc",
                "type": "uint256"
            }
        ],
        "name": "BlankShipped",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "name": "upc",
                "type": "uint256"
            }
        ],
        "name": "PartGenerated",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "name": "upc",
                "type": "uint256"
            }
        ],
        "name": "PartShipped",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "name": "upc",
                "type": "uint256"
            }
        ],
        "name": "Verified",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "name": "upc",
                "type": "uint256"
            }
        ],
        "name": "FailedVerification",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "name": "upc",
                "type": "uint256"
            }
        ],
        "name": "ShippedtoDist",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "name": "upc",
                "type": "uint256"
            }
        ],
        "name": "ShippedtoCons",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "name": "upc",
                "type": "uint256"
            }
        ],
        "name": "ReceivedByCons",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "name": "upc",
                "type": "uint256"
            }
        ],
        "name": "AcceptedByCons",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "name": "upc",
                "type": "uint256"
            }
        ],
        "name": "RejectedByCons",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "name": "from",
                "type": "address"
            },
            {
                "indexed": true,
                "name": "to",
                "type": "address"
            },
            {
                "indexed": true,
                "name": "tokenId",
                "type": "uint256"
            }
        ],
        "name": "Transfer",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "name": "owner",
                "type": "address"
            },
            {
                "indexed": true,
                "name": "approved",
                "type": "address"
            },
            {
                "indexed": true,
                "name": "tokenId",
                "type": "uint256"
            }
        ],
        "name": "Approval",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "name": "owner",
                "type": "address"
            },
            {
                "indexed": true,
                "name": "operator",
                "type": "address"
            },
            {
                "indexed": false,
                "name": "approved",
                "type": "bool"
            }
        ],
        "name": "ApprovalForAll",
        "type": "event"
    }
];

module.exports = {
    sc_abi,
    sc_address,
    
};
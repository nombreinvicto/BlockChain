pragma solidity >=0.4.24;

// get all the external contract signatures
contract Sourcer {
    // define a function to check if an address is a sourcer or not
    function isSourcer (address account) public view returns (bool) {}
}

contract cncOwner {
    // define a function to check if an address is a sourcer or not
    function iscncOwner (address account) public view returns (bool) {}
}

contract Verifier {
    // define a function to check if an address is a sourcer or not
    function isVerifier (address account) public view returns (bool) {}
}

contract Distributor {
    // define a function to check if an address is a Distributor or not
    function isDistributor (address account) public view returns (bool) {}
}

contract Consumer {
    // define a function to check if an address is a Consumer or not
    function isConsumer (address account) public view returns (bool) {}
}

// start with the main supplyChain contract
contract SupplyChain {
    // variable definitions ////////////////////////////////////////////////////////////////////////
    // define owner
    address supplyChainContractOwner;
    
    //define a variable to track product
    uint productID;
    
    // declare all the actor contract addresses
    address private sourcerContractAddress = address(0x692a70d2e424a56d2c6c27aa97d1a86395877b3a);
    address private cncOwnerContractAddress = address(0xbbf289d846208c16edc8474705c748aff07732db);
    address private verfierContractAddress = address(0x0dcd2f752394c41875e259e00bb44fd505297caf);
    address private distributorContractAddress = address(0x5e72914535f202659083db3a02c984188fa26e9f);
    address private consumerContractAddress = address(0x08970fed061e7747cd9a38d680a601510cb659fb);
    
    
    // define a mapping that maps unique product ID to Asset
    mapping(uint => Asset) upcToAssetMapping;
    
    // define a mapping that maps upc to array of txhash
    mapping (uint => string[]) assetHistory;
    
    // define enum state with states from sequence diagram
    enum State {
        Sourced,       //0
        Processed,     //1
        BlankShipped,  //2
        PartGenerated, //3
        PartShipped,   //4
        Verified,      //5
        ShippedtoDist, //6
        ShippedtoCons, //7
        Purchased      //8
        
    }
    
    // define struct asset for asset details
    struct Asset {
        uint upc;
        address currentOwnerAddress;
        address SourcerAddress;
        address cncOwnerAddress;
        address verifierAddress;
        address distributorAddress;
        address consumerAddress;
        uint price;
        string assetDescription;
        State assetState;
    }
    
    
    // event definitions ////////////////////////////////////////////////////////////////////////
    // define 8 events with the same 9 state values and accept upc as argument
    event Sourced(uint upc);
    event Processed(uint upc);
    event BlankShipped(uint upc);
    event PartGenerated(uint upc);
    event PartShipped(uint upc);
    event Verified(uint upc);
    event ShippedtoDist(uint upc);
    event ShippedtoCons(uint upc);
    event Purchased(uint upc);
    
    
    // modifier definitions ////////////////////////////////////////////////////////////////////////
    // modifier to check for owner only
    modifier onlyOwner () {
        require(supplyChainContractOwner == msg.sender);
        _;
    }
    
    //define a modifier that checks if the paid ether is sufficient to cover price
    modifier paidSufficient(uint price) {
        require(msg.value > price, "supplied ether is insufficient in covering cost");
        _;
    }
    
    // define modifier that checks price and issued refund if any
    modifier checkPriceIssueRefund(uint upc) {
        _;
        uint price = upcToAssetMapping[upc].price;
        uint amountToReturn = msg.value - price;
        upcToAssetMapping[upc].consumerAddress.transfer(amountToReturn);
    }
    
    // define a modifier that checks if an asset.state of a upc is Sourced or not
    modifier sourced(uint upc) {
        require(upcToAssetMapping[upc].assetState == State.Sourced, "asset has not been sourced yet by the sourcer");
        _;
    }
    
    // define a modifier that checks if an asset.state of a upc is Processed or not
    modifier processed(uint upc) {
        require(upcToAssetMapping[upc].assetState == State.Processed, "asset has not been processed yet by the sourcer");
        _;
    }
    
    // define a modifier that checks if an asset.state of a upc is BlankShipped or not
    modifier blankShipped(uint upc) {
        require(upcToAssetMapping[upc].assetState == State.BlankShipped, "asset(blank) has not been shipped yet by the sourcer");
        _;
    }
    
    // define a modifier that checks if an asset.state of a upc is PartGenerated or not
    modifier partGenerated(uint upc) {
        require(upcToAssetMapping[upc].assetState == State.PartGenerated, "asset has not been machined yet by the CNC owner");
        _;
    }
    
    // define a modifier that checks if an asset.state of a upc is PartShipped or not
    modifier partShipped(uint upc) {
        require(upcToAssetMapping[upc].assetState == State.PartShipped, "asset(part) has not been shipped yet by the CNC owner");
        _;
    }
    
    // define a modifier that checks if an asset.state of a upc is Verified or not
    modifier verified(uint upc) {
        require(upcToAssetMapping[upc].assetState == State.Verified, "asset(part) has not been verified yet by the QA verifier");
        _;
    }
    
    // define a modifier that checks if an asset.state of a upc is ShippedtoDist or not
    modifier shippedToDist(uint upc) {
        require(upcToAssetMapping[upc].assetState == State.ShippedtoDist, "asset(part) has not been shipped to distributor yet by the verifier");
        _;
    }
    
    // define a modifier that checks if an asset.state of a upc is ShippedtoCons or not
    modifier shippedtoCons(uint upc) {
        require(upcToAssetMapping[upc].assetState == State.ShippedtoCons, "asset(part) has not been shipped to consumer yet by the distributor");
        _;
    }
    
    
    // define a modifier that checks if an asset.state of a upc is Purchased or not
    modifier purchased(uint upc) {
        require(upcToAssetMapping[upc].assetState == State.Purchased, "asset(part) has not been received yet by the consumer");
        _;
    }
    
    // constructor
    
    constructor () public {
        supplyChainContractOwner = msg.sender;
    }
    
    
    // define a function sourceItem to allow sourcer to mark raw material as sourced
    function sourceAsset()public {
        Sourcer s = Sourcer(sourcerContractAddress);
        require(s.isSourcer(msg.sender), "this address does not have permission to source raw material");
        
        productID = productID + 1;
        emit Sourced(productID);
    }
    
}
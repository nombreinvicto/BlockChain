pragma solidity >=0.4.24;

import "./SafeMath.sol";
import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";

// get all the external contract signatures
contract Sourcer {
    // define a function to check if an address is a sourcer or not
    function isSourcer(address account) public view returns (bool) {}
}

contract cncOwner {
    // define a function to check if an address is a sourcer or not
    function iscncOwner(address account) public view returns (bool) {}
}

contract Verifier {
    // define a function to check if an address is a sourcer or not
    function isVerifier(address account) public view returns (bool) {}
}

contract Distributor {
    // define a function to check if an address is a Distributor or not
    function isDistributor(address account) public view returns (bool) {}
}

contract Consumer {
    // define a function to check if an address is a Consumer or not
    function isConsumer(address account) public view returns (bool) {}
}

// start with the main supplyChain contract
contract SupplyChain is ERC721 {
    // import safemath for uint
    using SafeMath for uint;
    
    // variable definitions ////////////////////////////////////////////////////////////////////////
    // define owner
    address supplyChainContractOwner;
    
    // declare all the actor contract addresses
    address private sourcerContractAddress;
    address private cncOwnerContractAddress;
    address private verfierContractAddress;
    address private distributorContractAddress;
    address private consumerContractAddress;
    
    // create instances of all the actor contracts
    Sourcer s_contract = Sourcer(address(0));
    cncOwner co_contract = cncOwner(address(0));
    Verifier v_contract = Verifier(address(0));
    Distributor d_contract = Distributor(address(0));
    Consumer c_contract = Consumer(address(0));
    
    //define a global variable to track product
    uint sku; // var for stock keeping unit- incremental integer
    
    // define a mapping that maps the sku to upc
    mapping(uint => uint) skuToUpcMapping;
    
    // define a mapping that maps upc to Asset
    mapping(uint => Asset) upcToAssetMapping;
    
    // define a mapping that maps upc to array of txhash
    mapping(uint => string[]) upcToAssetTxHistory; // how to implement?
    
    
    
    
    // define a mapping of unique purchase order to consumerAddress
    mapping(uint => address) internal purchaseOrderToConsumerAddressMapping;
    
    // define mapping of unique purchase order to volume and material classes
    mapping(uint => mapping(string => uint)) internal purchaseOrderToVolMatDetails;
    
    //define mapping of unique purchase order to consumer details
    mapping(uint => mapping(string => string)) internal purchaseOrderToCustomerDetails;
    
    //mapping that tracks time stamp of generation of purchase order
    mapping(uint => uint) purchaseOrderToTimeStampMapping;
    
    // mapping that tracks validity of purchase order
    mapping(uint => bool) purchaseOrderToStatusMapping;
    
    // mapping that maps purchase order to upc of asset
    mapping(uint => uint) purchaseOrderToUpcMapping;
    
    
    
    // sample volumeClass to factor mapping
    mapping(uint => uint) internal volumeClassToFactorMapping;
    
    // sample materialClass to unitPrice mapping (per unit volume factor)
    mapping(uint => uint) internal materialClassToUnitPriceMapping;
    
    // sample volumeClassToDaysMapping - to suggest how many days gonna take to machine
    mapping(uint => uint)internal volumeClassToDaysMapping;
    
    // mapping of consumerAddress to deposited amount in escrow
    mapping(address => uint) internal consumerAddressToEscrowDeposit;
    
    
    // define dynamic arrays for storing volumeClass and MaterialClass keys
    uint[] internal volumeClassToFactorMappingKeys;
    uint[] internal materialClassToUnitPriceMappingKeys;
    uint[] public purchaseOrdersSendingMakeOrders;
    uint[] public pendingPurchaseOrders;
    
    
    // define enum state with states from sequence diagram
    enum State {
        InitiatedPurchaseOrder, // 0
        CreateQuoteForCustomer, // 1
        SendMakeOrderToCncOwner, // 2
        Sourced, //3
        Processed, //4
        BlankShipped, //5
        PartGenerated, //6
        PartShipped, //7
        Verified, //8
        ShippedtoDist, //9
        ShippedtoCons, //10
        Purchased, //11
        Invalid        //12
    }
    
    // define struct asset for asset details
    struct Asset {
        uint upc;
        uint price;
        
        address currentOwnerAddress;
        address sourcerAddress;
        address cncOwnerAddress;
        address verifierAddress;
        address distributorAddress;
        address consumerAddress;
        
        string consumerName;
        string consumerLocation;
        
        State assetState;
        
    }
    
    
    // event definitions ////////////////////////////////////////////////////////////////////////
    // define 10 events with the same 10 state values and accept upc as argument
    event InitiatedPurchaseOrder(uint purchaseOrder);
    event CreateQuoteForCustomer(uint purchaseOrder);
    event SendMakeOrderToCncOwner(uint purchaseOrder);
    
    event Sourced(uint upc);
    event Processed(uint upc);
    event BlankShipped(uint upc);
    event PartGenerated(uint upc);
    event PartShipped(uint upc);
    event Verified(uint upc);
    event ShippedtoDist(uint upc);
    event ShippedtoCons(uint upc);
    event Purchased(uint upc);
    event Invalid(uint upc);
    
    
    /////////////////////////////////////////////////// normal modifier definitions ////////////////////////////////////////////////////////////////////////
    // modifier to check for owner only
    modifier onlyOwner () {
        require(msg.sender == supplyChainContractOwner, "caller is not smart contract owner");
        _;
    }
    
    // define a modifier for functions that can be only called by consumer
    modifier onlyConsumer (address caller) {
        require(c_contract.isConsumer(caller), "calling address doesnt have permission to initiate purchase order. Address has to be approved consumer.");
        _;
    }
    
    // define a modifier for functions that can only be called by the sourcer
    modifier onlySourcer (address caller) {
        require(s_contract.isSourcer(caller), "calling address doesnt have permission to call this function. Address has to be approved sourcer");
        _;
    }
    
    modifier onlyCncOwner(address caller) {
        require(co_contract.iscncOwner(caller), "calling address is not a valid cnc owner");
        _;
    }
    
    modifier onlyVerifier (address caller) {
        require(v_contract.isVerifier(caller), "calling address is not a valid QA verifier");
        _;
    }
    
    modifier onlyDistributor (address caller) {
        require(d_contract.isDistributor(caller), "calling address is not a valid distributor in the chain");
        _;
    }
    
    ///////////////////////////////// modifier below this line are related to events////////////////////////////////////////////////////////////////////////
    
    // define a modifier that checks if an asset.state of a upc is Sourced or not
    modifier sourced(uint upc) {
        require(upcToAssetMapping[upc].assetState == State.Sourced, "asset has not been sourced yet by the sourcer");
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
    
    // define a modifier for functions that can only be called by consumer
    /////////////////////////////////////////////constructor and functions from below /////////////////////////////////////////////////////////////////
    // constructor
    
    constructor () public {
        supplyChainContractOwner = msg.sender;
        
        // populate materialClass to unit price mapping
        materialClassToUnitPriceMapping[1] = 100000000000000;
        materialClassToUnitPriceMapping[2] = 200000000000000;
        materialClassToUnitPriceMapping[3] = 300000000000000;
        
        // populate volumeClass to volumeClassToFactorMapping
        volumeClassToFactorMapping[1] = 10;
        volumeClassToFactorMapping[2] = 100;
        volumeClassToFactorMapping[3] = 1000;
    }
    
    // function to update all actor contract addresses
    function updateActorAddresses
    (address _sourcer,
        address _cncowner,
        address _verifier,
        address _distributor,
        address _consumer) onlyOwner public {
        
        require(_sourcer != address(0) &&
        _cncowner != address(0) &&
        _verifier != address(0) &&
        _distributor != address(0) &&
        _consumer != address(0), "one or many of the addresses supplied were invalid zero addresses");
        
        s_contract = Sourcer(_sourcer);
        co_contract = cncOwner(_cncowner);
        v_contract = Verifier(_verifier);
        d_contract = Distributor(_distributor);
        c_contract = Consumer(_consumer);
        
    }
    
    // function initiatePurchaseOrder from the consumer
    function initiatePurchaseOrder(string custName, string custLoc, uint volumeClass, uint materialClass) public onlyConsumer(msg.sender) returns (uint, uint _price, uint _completionTime){
        //require(c_contract.isConsumer(msg.sender), "calling address doesnt have permission to initiate purchase order. Address has to be approved consumer.");
        require(bytes(custName).length > 0 && bytes(custLoc).length > 0 && volumeClass > 0 && materialClass > 0, "either customer, or location sent as empty string or vol/material classes sent as 0.");
        
        uint purchaseOrder = generatePurchaseOrder(custName, custLoc, volumeClass, materialClass);
        emit InitiatedPurchaseOrder(purchaseOrder);
        purchaseOrderToConsumerAddressMapping[purchaseOrder] = msg.sender;
        purchaseOrderToTimeStampMapping[purchaseOrder] = now;
        purchaseOrderToStatusMapping[purchaseOrder] = true;
        
        (_price, _completionTime) = createQuoteForCustomer(volumeClass, materialClass);
        
        purchaseOrderToCustomerDetails[purchaseOrder]["custName"] = custName;
        purchaseOrderToCustomerDetails[purchaseOrder]["custLoc"] = custLoc;
        
        purchaseOrderToVolMatDetails[purchaseOrder]["volumeClass"] = volumeClass;
        purchaseOrderToVolMatDetails[purchaseOrder]["materialClass"] = materialClass;
        purchaseOrderToVolMatDetails[purchaseOrder]["price"] = _price;
        // also storing price
        
        emit CreateQuoteForCustomer(purchaseOrder);
        return (purchaseOrder, _price, _completionTime);
    }
    
    // function that is automatically called to create the quote
    function createQuoteForCustomer(uint volumeClass, uint materialClass) internal view returns (uint, uint){
        uint materialClassUnitPrice = materialClassToUnitPriceMapping[materialClass];
        uint volumeFactor = volumeClassToFactorMapping[volumeClass];
        
        // making sure consumer is not passing invalid volume or material class
        if (materialClassUnitPrice == 0 || volumeClass == 0) {
            revert("invalid volume and material class meta info passed to smart contract. make sure they are non-zero/non-negative.");
        }
        
        uint price = materialClassUnitPrice.mul(volumeFactor);
        uint completionTime = volumeClassToDaysMapping[volumeClass];
        return (price, completionTime);
    }
    
    // function that consumer calls to make order
    function makeOrder(uint purchaseOrder) public payable onlyConsumer(msg.sender) {
        //require(c_contract.isConsumer(msg.sender), "calling address doesnt have permission to initiate make order. Address has to be approved consumer.");
        
        // check if a product already exists for this purchase order
        require(purchaseOrderToUpcMapping[purchaseOrder] == 0, "this purchase order already has an existing asset");
        
        // checking that whosoever is doing the make order, he has already passed the intiate purchase order step
        require(purchaseOrderToConsumerAddressMapping[purchaseOrder] != address(0), "there are no existing records of the given purchase order.");
        
        // checking the whosoever is making the make order is the same person who initiated the purchase order
        require(purchaseOrderToConsumerAddressMapping[purchaseOrder] == msg.sender, "consumer making make order request has no existing purchase order. please start with initiating purchase order.");
        
        // check make order already sent or not
        if (makeOrderAlreadySent(purchaseOrder)) {
            revert("a make order has already been sent against this purchase order");
        }
        
        // check if supplied ether is sufficient or not
        require(purchaseOrderToVolMatDetails[purchaseOrder]["price"] < msg.value, "consumer has sent insufficient funds against the purchase order.");
        
        //check if make order made within time or not
        uint timeDelta = now - purchaseOrderToTimeStampMapping[purchaseOrder];
        if (timeDelta > 2 days) {
            purchaseOrderToStatusMapping[purchaseOrder] = false;
            //
            revert("make order made beyond the stipulated time frame. start with new purchase order.");
        } else if (purchaseOrderToStatusMapping[purchaseOrder] == false) {
            revert("purchase order with given purchase order id is inactive. Please initiate new purchase order");
        } else {
            
            // store the amount of eth sent by consumer in escrow
            consumerAddressToEscrowDeposit[msg.sender] = msg.value;
            
            // record which purchase order has sent make order
            purchaseOrdersSendingMakeOrders.push(purchaseOrder);
            
            
            //emit the send make order event
            emit SendMakeOrderToCncOwner(purchaseOrder);
            
        }
        
        
    }
    
    // source material
    function sourceMaterial(uint purchaseOrder) public onlySourcer(msg.sender) {
        
        // create an asset against the pending purchase order
        uint[] memory pos = getAllPendingOrders();
        //  this reupdates the pending purchase order arrays
        require(isThisPurchaseOrderPending(purchaseOrder), "this purchase order doesnt have a pending make request");
        
        // if it is not pending then create an ERC721 token asset against it
        sku = sku + 1;
        // increment the sku
        address customerAddress = purchaseOrderToConsumerAddressMapping[purchaseOrder];
        string memory customerName = purchaseOrderToCustomerDetails[purchaseOrder]["custName"];
        string memory customerLoc = purchaseOrderToCustomerDetails[purchaseOrder]["custName"];
        
        // generate a upc
        uint upc = generateUPC(customerName, customerLoc, purchaseOrder);
        uint price = purchaseOrderToVolMatDetails[purchaseOrder]["price"];
        
        // now create the asset
        Asset memory newAsset = Asset(upc,
            price,
            msg.sender,
            address(0),
            address(0),
            address(0),
            address(0),
            purchaseOrderToConsumerAddressMapping[purchaseOrder],
            customerName,
            customerLoc,
            State.Sourced);
        
        // update the sku to upc mapping
        skuToUpcMapping[sku] = upc;
        
        // update the upc to asset mapping
        upcToAssetMapping[upc] = newAsset;
        
        //update purchase order to upc mapping
        purchaseOrderToUpcMapping[purchaseOrder] = upc;
        
        // now mint the ERC721 asset in the name of the sourcer
        _mint(msg.sender, upc);
        
        // emit the sourced event
        emit Sourced(upc);
        
    }
    
    // sourcer function to emit ship event to the cnc owner
    function shipPartToCNC(uint upc) public onlySourcer(msg.sender) sourced(upc){
        upcToAssetMapping[upc].assetState = State.BlankShipped;
        emit BlankShipped(upc);
    }
    
    // generate part function by the CNC owner
    function generatePart(uint upc) public onlyCncOwner(msg.sender) blankShipped(upc) {
        upcToAssetMapping[upc].currentOwnerAddress = msg.sender;
        upcToAssetMapping[upc].cncOwnerAddress = msg.sender;
        upcToAssetMapping[upc].assetState = State.PartGenerated;
        emit PartGenerated(upc);
    }
    
    // cnc owner function to emit ship event to verifier
    function shipPartToVerifier (uint upc) public onlyCncOwner(msg.sender) partGenerated(upc){
        upcToAssetMapping[upc].assetState = State.PartShipped;
        emit PartShipped(upc);
    }
    
    // verify part function by the verifier
    function verifyPart (uint upc) public onlyVerifier(msg.sender) partShipped(upc){
        upcToAssetMapping[upc].currentOwnerAddress = msg.sender;
        upcToAssetMapping[upc].verifierAddress = msg.sender;
        upcToAssetMapping[upc].assetState = State.Verified;
        emit Verified(upc);
    }
    
    // verifier function to emit the ship event to the distributor
    function shipPartToDistributor (uint upc) public onlyVerifier(msg.sender) verified(upc){
        upcToAssetMapping[upc].assetState = State.ShippedtoDist;
        emit ShippedtoDist(upc);
    }
    
    //distribute part to the consumer from the verifier
    function shipPartToTheConsumer (uint upc) public onlyDistributor(msg.sender) shippedToDist(upc){
        upcToAssetMapping[upc].currentOwnerAddress = msg.sender;
        upcToAssetMapping[upc].distributorAddress = msg.sender;
        upcToAssetMapping[upc].assetState = State.ShippedtoCons;
        emit ShippedtoCons(upc);
    }
    
    // consumer acknowledges part receiption
    function acceptPart (uint upc) public onlyConsumer(msg.sender) shippedtoCons(upc) {
    
    }
    
    
    
    ///////////////////////////////// helper or utility functions below this line////////////////////////////////////////////////////////////////////////
    function generatePurchaseOrder(string _a, string _b, uint _v, uint _m) internal view returns (uint) {
        uint thisTime = now;
        // keccak of customer name, location, volume, material, current time
        return uint256(keccak256(abi.encodePacked(_a, _b, _v, _m, thisTime)));
    }
    
    function generateUPC(string _customerName, string _customerLoc, uint _purchaseOrder) internal view returns (uint) {
        uint thisTime = now;
        // keccak of customer name, location, purchase order and current time
        return uint256(keccak256(abi.encodePacked(_customerName, _customerLoc, _purchaseOrder, thisTime)));
    }
    
    function updateMaterialClassToUnitPriceMapping(uint class, uint unitprice) public onlyOwner {
        require(unitprice <= 100000000000000000000 && unitprice >= 0, "supplied unitprice is either negative or too unrealistically high of a value");
        materialClassToUnitPriceMapping[class] = unitprice;
        materialClassToUnitPriceMappingKeys.push(class);
    }
    
    function updateVolumeClassToFactorMapping(uint class, uint factor) public onlyOwner {
        require(factor <= 50 && factor > 0, "supplied factor is either negative or too unrealistically high of a value");
        volumeClassToFactorMapping[class] = factor;
        volumeClassToFactorMappingKeys.push(class);
    }
    
    function deleteMaterialClassToUnitPriceMappingEntry(uint class) public onlyOwner returns (bool){
        delete materialClassToUnitPriceMapping[class];
        
        // then delete the key from the key array
        for (uint i = 0; i <= materialClassToUnitPriceMappingKeys.length; i++) {
            if (class == materialClassToUnitPriceMappingKeys[i]) {
                delete materialClassToUnitPriceMappingKeys[i];
            }
        }
        return true;
    }
    
    function deleteVolumeClassToFactorMappingEntry(uint class) public onlyOwner returns (bool){
        delete volumeClassToFactorMapping[class];
        
        // then delete the key from the key array
        for (uint i = 0; i <= volumeClassToFactorMappingKeys.length; i++) {
            if (class == volumeClassToFactorMappingKeys[i]) {
                delete volumeClassToFactorMappingKeys[i];
            }
        }
        return true;
    }
    
    function getAllMaterialClassToUnitPriceMaps() public view onlyOwner returns (uint[], uint[]){
        uint[] memory materialUnitPriceArray = new uint[](materialClassToUnitPriceMappingKeys.length);
        for (uint i = 0; i <= materialClassToUnitPriceMappingKeys.length; i++) {
            uint key = materialClassToUnitPriceMappingKeys[i];
            materialUnitPriceArray[i] = materialClassToUnitPriceMapping[key];
        }
        return (materialClassToUnitPriceMappingKeys, materialUnitPriceArray);
        // returning via tuple types
    }
    
    function getAllVolumeClassToFactorMaps() public view onlyOwner returns (uint[], uint[]){
        uint[] memory volumeClassFactorArray = new uint[](volumeClassToFactorMappingKeys.length);
        for (uint i = 0; i <= volumeClassToFactorMappingKeys.length; i++) {
            uint key = volumeClassToFactorMappingKeys[i];
            volumeClassFactorArray[i] = volumeClassToFactorMapping[key];
        }
        return (volumeClassToFactorMappingKeys, volumeClassFactorArray);
        // returning via tuple types
    }
    
    function makeOrderAlreadySent(uint _purchaseOrder) internal view returns (bool) {
        for (uint i = 0; i <= purchaseOrdersSendingMakeOrders.length; i++) {
            if (purchaseOrdersSendingMakeOrders[i] == _purchaseOrder) {
                return true;
            }
        }
        return false;
    }
    
    // function that sourcer calls to get a list of pending purchase orders
    function getAllPendingOrders() public returns (uint []) {
        // first reset global array to zero
        pendingPurchaseOrders.length = 0;
        
        for (uint i = 0; i <= purchaseOrdersSendingMakeOrders.length; i++) {
            uint purchaseOrder = purchaseOrdersSendingMakeOrders[i];
            if (purchaseOrderToStatusMapping[purchaseOrder]) {
                pendingPurchaseOrders.push(purchaseOrder);
            }
        }
        return pendingPurchaseOrders;
    }
    
    function isThisPurchaseOrderPending(uint purchaseOrder) internal view returns (bool){
        
        for (uint i = 0; i <= pendingPurchaseOrders.length; i++) {
            uint po = pendingPurchaseOrders[i];
            if (po == purchaseOrder) {
                return true;
            }
        }
        return false;
    }
    
    function killContract() public {
        if (msg.sender == supplyChainContractOwner) {
            selfdestruct(supplyChainContractOwner);
        }
    }
    
    
}
pragma solidity >=0.5.0;
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


// start with the main supplyChain contract that inherits from ERC 721
contract SupplyChain is ERC721 {
    // import safemath for uint
  
    
    // variable definitions ////////////////////////////////////////////////////////////////////////
    // define owner
    address payable supplyChainContractOwner;
    
    // create instances of all the actor contracts
    Sourcer s_contract = Sourcer(address(0xeEF585BfB8b00BA5463a1ff2607c36862160357e));
    cncOwner co_contract = cncOwner(address(0x70C07EaFaa3fDc3EaB7C7E5B931D8d9294Cb9474));
    Verifier v_contract = Verifier(address(0x5cea2DeF4Df0a8cABF9e02C931A86A511E30f16e));
    Distributor d_contract = Distributor(address(0xC1b57f18265bbca436F5DE191dbB460D477F689E));
    Consumer c_contract = Consumer(address(0xe5cD46577ad6607AddDE5040a1cF28B3D9Fb3181));
    
    // define an array and mapping for cncOwner so that consumers can see if this  cncOwner has a history
    address [] cncOwnerAddressRegistered;
    mapping(address => bool) cncOwnerAddressRegisteredAvailableMapping;
    
    
    // upc based mappings //////////////////////////////////////////////////////////////////////////
    //define a global variable to track product
    uint sku; // var for stock keeping unit- incremental integer
    
    // define a mapping that maps the sku to upc
    mapping(uint => uint) skuToUpcMapping;
    
    // define a mapping that maps upc to Asset
    mapping(uint => Asset) upcToAssetMapping;
    
    // define a mapping that maps upc to array of txhash
    mapping(uint => string[]) upcToAssetTxHistory; // how to implement?
    
    // define a mapping that connects upc to purchase order
    mapping(uint => uint) upcToPurchaseOrderMapping;
    
    
    // PO based mappings //////////////////////////////////////////////////////////////////////////
    // define a mapping of unique purchase order to consumerAddress
    mapping(uint => address payable) public purchaseOrderToConsumerAddressMapping;
    
    // define mapping of unique purchase order to volume and material classes
    mapping(uint => mapping(string => uint)) internal purchaseOrderToVolMatDetails;
    
    //define mapping of unique purchase order to consumer details
    mapping(uint => mapping(string => string)) internal purchaseOrderToCustomerDetails;
    
    //mapping that tracks time stamp of generation of purchase order
    mapping(uint => uint) public purchaseOrderToTimeStampMapping;
    
    // mapping that tracks validity of purchase order
    mapping(uint => bool) purchaseOrderToStatusMapping;
    
    // mapping that maps purchase order to upc of asset
    mapping(uint => uint) purchaseOrderToUpcMapping;
    
     // define mapping to store purchase orders sending make orders and to store pending purchase orders
    mapping(uint => bool)  public purchaseOrdersSendingMakeOrders;
    
    
    // volume/material based mappings //////////////////////////////////////////////////////////////////////////
    // sample volumeClass to factor mapping
    mapping(uint => uint) internal volumeClassToFactorMapping;
    
    // sample materialClass to unitPrice mapping (per unit volume factor)
    mapping(uint => uint) internal materialClassToUnitPriceMapping;
    
    // sample volumeClassToDaysMapping - to suggest how many days gonna take to machine
    mapping(uint => uint)public volumeClassToDaysMapping;
    
    // mapping of consumerAddress to deposited amount in escrow
    mapping(address => uint) internal consumerAddressToEscrowDeposit;
    
    
    // miscellaneous mappings //////////////////////////////////////////////////////////////////////////
    // mapping that maps cncOwnerAddress to total orders taken and order completed
    // "orderTaken" in PartGenerated function and "ordersCompleted" incremented in acceptPart() by consumer
    mapping(address => mapping(string => uint)) cncOwnerAddressToOrderCompletedHistory;
    
    
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
        FailedVerification, //9
        ShippedtoDist,   //10
        ShippedtoCons,  //11
        ReceivedByCons, //12
        AcceptedByCons, //13
        RejectedByCons // 14
    }
    
    // define struct asset for asset details
    struct Asset {
        uint upc;
        uint price;
        
        address currentOwnerAddress;
        address sourcerAddress;
        address payable cncOwnerAddress;
        address verifierAddress;
        address distributorAddress;
        address payable consumerAddress;
        
        string consumerName;
        string consumerLocation;
        
        State assetState;
        
    }
    
    
    // event definitions ////////////////////////////////////////////////////////////////////////
    // define 10 events with the same 10 state values and accept upc as argument
    event InitiatedPurchaseOrder(uint purchaseOrder);
    event CreateQuoteForCustomer(uint purchaseOrder, uint price, uint completionTime, address cncOwnerAddressDelegated);
    event SendMakeOrderToCncOwner(uint purchaseOrder);
    
    event Sourced(uint upc);
    event Processed(uint upc);
    event BlankShipped(uint upc);
    event PartGenerated(uint upc);
    event PartShipped(uint upc);
    event Verified(uint upc);
    event FailedVerification(uint upc);
    event ShippedtoDist(uint upc);
    event ShippedtoCons(uint upc);
    event ReceivedByCons(uint upc);
    event AcceptedByCons(uint upc);
    event RejectedByCons(uint upc);
    
    
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
        require((upcToAssetMapping[upc].assetState == State.BlankShipped) || (upcToAssetMapping[upc].assetState == State.FailedVerification), "asset(blank) has not been shipped yet by the sourcer or this is not a reject verified part");
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
    
    
    // define a modifier that checks if an asset.state of a upc is Received by consumer or not
    modifier received(uint upc) {
        require(upcToAssetMapping[upc].assetState == State.ReceivedByCons, "asset(part) has not been received yet by the consumer");
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
        
        // populate volumeClassToDaysMapping
        volumeClassToDaysMapping[1] = 10 days;
        volumeClassToDaysMapping[2] = 20 days;
        volumeClassToDaysMapping[3] = 30 days;
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
    // transaction functions do not return values - use events
    function initiatePurchaseOrder(string memory custName, 
                                    string memory custLoc, 
                                    uint volumeClass, 
                                    uint materialClass) public onlyConsumer(msg.sender){
        
        require(bytes(custName).length > 0 && bytes(custLoc).length > 0 && volumeClass > 0 && materialClass > 0, "either customer, or location sent as empty string or vol/material classes sent as 0.");
        
        
        uint purchaseOrder = uint256(keccak256(abi.encodePacked(custName, custLoc, volumeClass, materialClass, now)));
        emit InitiatedPurchaseOrder(purchaseOrder);
        
        purchaseOrderToConsumerAddressMapping[purchaseOrder] = msg.sender;
        purchaseOrderToTimeStampMapping[purchaseOrder] = now;
        purchaseOrderToStatusMapping[purchaseOrder] = true;
        
        // get material and volume class to calculate price
        uint materialClassUnitPrice = materialClassToUnitPriceMapping[materialClass];
        uint volumeFactor = volumeClassToFactorMapping[volumeClass];
        
        // making sure consumer is not passing invalid volume or material class
        if (materialClassUnitPrice == 0 || volumeFactor == 0) {
            revert("invalid volume and material class meta info passed to smart contract. make sure they are non-zero/non-negative.");
        }
        
        uint price = materialClassUnitPrice*volumeFactor;
        uint completionTime = volumeClassToDaysMapping[volumeClass];
        
        purchaseOrderToCustomerDetails[purchaseOrder]["custName"] = custName;
        purchaseOrderToCustomerDetails[purchaseOrder]["custLoc"] = custLoc;
        
        purchaseOrderToVolMatDetails[purchaseOrder]["volumeClass"] = volumeClass;
        purchaseOrderToVolMatDetails[purchaseOrder]["materialClass"] = materialClass;
        purchaseOrderToVolMatDetails[purchaseOrder]["price"] = price; // also storing price
        
        // choose a cncOwnerAddress
        address cncOwnerDelegated = address(0);
        for(uint i=0; i < cncOwnerAddressRegistered.length; i++) {
            address cncOwner_ = cncOwnerAddressRegistered[i];
            if (cncOwnerAddressRegisteredAvailableMapping[cncOwner_] == true) {
                cncOwnerDelegated = cncOwner_;
            }
        }
        
        
        emit CreateQuoteForCustomer(purchaseOrder, price, completionTime, cncOwnerDelegated);
        
    }
    
    // function that consumer calls to make order
    // transaction functions do not return values
    function makeOrder(uint purchaseOrder) public payable onlyConsumer(msg.sender){
        
        // check if a product already exists for this purchase order
        require(purchaseOrderToUpcMapping[purchaseOrder] == 0, "this purchase order already has an existing asset");
        
        // checking that whosoever is doing the make order, he has already passed the intiate purchase order step
        require(purchaseOrderToConsumerAddressMapping[purchaseOrder] != address(0), "there are no existing records of the given purchase order.");
        
        // checking the whosoever is making the make order is the same person who initiated the purchase order
        require(purchaseOrderToConsumerAddressMapping[purchaseOrder] == msg.sender, "consumer making make order request has no existing purchase order. please start with initiating purchase order.");
        
         // check make order already sent or not
        if (purchaseOrdersSendingMakeOrders[purchaseOrder]) {
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
            revert("make order with given purchase order id is inactive. Please initiate new purchase order");
        } else {
            // if everything passes, we are about to make a valid makeorder
            
            // store the amount of eth sent by consumer in escrow
            consumerAddressToEscrowDeposit[msg.sender] = msg.value;
            
            // record which purchase order has sent make order
            purchaseOrdersSendingMakeOrders[purchaseOrder] = true;
            
            //emit the send make order event
            emit SendMakeOrderToCncOwner(purchaseOrder);
            
            
        }
    }
    
    // source material
    // also transaction functions do not return values
    function sourceMaterial(uint purchaseOrder) public onlySourcer(msg.sender){
        // make sure this purchase order already hasnt gone for an Asset creation
        require(purchaseOrderToUpcMapping[purchaseOrder] == 0, "this purchase order already has an existing asset");

        require(purchaseOrderToStatusMapping[purchaseOrder] == true && purchaseOrdersSendingMakeOrders[purchaseOrder] == true, "this purchase order doesnt have a pending make request");
        
        // if it is not pending then create an ERC721 token asset against it
        sku = sku + 1;// increment the sku
        
        address payable customerAddress = purchaseOrderToConsumerAddressMapping[purchaseOrder];
        string memory customerName = purchaseOrderToCustomerDetails[purchaseOrder]["custName"];
        string memory customerLoc = purchaseOrderToCustomerDetails[purchaseOrder]["custName"];
        
        // generate a upc
        uint upc = uint256(keccak256(abi.encodePacked(customerName, customerLoc, purchaseOrder, now)));
        
        // also track which purchase order relates to which upc
        upcToPurchaseOrderMapping[upc] = purchaseOrder;
        
        // calculate the price of the asset
        uint price = purchaseOrderToVolMatDetails[purchaseOrder]["price"];
        
        // now create the asset
        Asset memory newAsset = Asset(
            upc,
            price,
            
            msg.sender,
            msg.sender,
            address(0),
            address(0),
            address(0),
            customerAddress,
            
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
    function generatePart(uint upc) public onlyCncOwner(msg.sender) blankShipped(upc){
        
        // mae this cncowner busy
        cncOwnerAddressRegisteredAvailableMapping[msg.sender] = false;
        
        // make an ERC 721 transfer to the CNC owner
        _transferFrom(upcToAssetMapping[upc].currentOwnerAddress, msg.sender, upc);
        
        // now make the necessary Asset attribute changes
        upcToAssetMapping[upc].currentOwnerAddress = msg.sender;
        upcToAssetMapping[upc].cncOwnerAddress = msg.sender;
        upcToAssetMapping[upc].assetState = State.PartGenerated;
        
        // register an order against the cncowner address
        cncOwnerAddressToOrderCompletedHistory[msg.sender]["ordersTaken"] = cncOwnerAddressToOrderCompletedHistory[msg.sender]["ordersTaken"] + 1;
        emit PartGenerated(upc);
        
        // mae this cncowner free
        cncOwnerAddressRegisteredAvailableMapping[msg.sender] = true;
    }
    
    // cnc owner function to emit ship event to verifier
    function shipPartToVerifier (uint upc) public onlyCncOwner(msg.sender) partGenerated(upc){
        upcToAssetMapping[upc].assetState = State.PartShipped;
        emit PartShipped(upc);
    }
    
    // verify part function by the verifier
    function verifyPart (uint upc) public onlyVerifier(msg.sender) partShipped(upc){
        
        // make an ERC 721 transfer to the CNC owner
        _transferFrom(upcToAssetMapping[upc].currentOwnerAddress, msg.sender, upc);
        
        upcToAssetMapping[upc].currentOwnerAddress = msg.sender;
        upcToAssetMapping[upc].verifierAddress = msg.sender;
        upcToAssetMapping[upc].assetState = State.Verified;
        emit Verified(upc);
    }
    
    // if verification not passed then reject part
    function verificationRejection(uint upc) public onlyVerifier(msg.sender) partShipped(upc){
        upcToAssetMapping[upc].currentOwnerAddress = msg.sender;
        upcToAssetMapping[upc].verifierAddress = msg.sender;
        upcToAssetMapping[upc].assetState = State.FailedVerification;
        emit FailedVerification(upc);
    }
    
    // verifier function to emit the ship event to the distributor
    function shipPartToDistributor (uint upc) public onlyVerifier(msg.sender) verified(upc){
        upcToAssetMapping[upc].assetState = State.ShippedtoDist;
        emit ShippedtoDist(upc);
    }
    
    //distribute part to the consumer from the distributor
    function shipPartToTheConsumer (uint upc) public onlyDistributor(msg.sender) shippedToDist(upc){
        
        // first check if shipping within alowwed days
        uint _purchaseOrder = upcToPurchaseOrderMapping[upc];
        uint _volumeClass = purchaseOrderToVolMatDetails[_purchaseOrder]["volumeClass"];
        uint _completionTime = volumeClassToDaysMapping[_volumeClass];
        uint _purchaseOrderTimeStamp = purchaseOrderToTimeStampMapping[_purchaseOrder];
        
        Asset memory newAsset = upcToAssetMapping[upc];
        address payable customerAddress = newAsset.consumerAddress;
        uint consumerPaid = consumerAddressToEscrowDeposit[customerAddress];
    
        if((now - _purchaseOrderTimeStamp) > _completionTime) {
            purchaseOrderToStatusMapping[_purchaseOrder] = false;
            customerAddress.transfer(consumerPaid);
            consumerAddressToEscrowDeposit[customerAddress] = 0;
            revert("shipped part beyond the allowable days. refunded customer");
        }
        
        // oterwise go ahead with shipping
        // make an ERC 721 transfer to the distributor
        _transferFrom(upcToAssetMapping[upc].currentOwnerAddress, msg.sender, upc);
        
        upcToAssetMapping[upc].currentOwnerAddress = msg.sender;
        upcToAssetMapping[upc].distributorAddress = msg.sender;
        upcToAssetMapping[upc].assetState = State.ShippedtoCons;
        emit ShippedtoCons(upc);
    }
    
    // consumer receives part
    function receivePart (uint upc) public onlyConsumer(msg.sender) shippedtoCons(upc){
        
        Asset memory newAsset = upcToAssetMapping[upc];
        address payable customerAddress = newAsset.consumerAddress;
        require(msg.sender == customerAddress, "current customer is not authentic owner of this asset");
        
        // make an ERC 721 transfer to the consumer
        _transferFrom(upcToAssetMapping[upc].currentOwnerAddress, msg.sender, upc);
        
        upcToAssetMapping[upc].currentOwnerAddress = msg.sender;
        upcToAssetMapping[upc].consumerAddress = msg.sender;
        upcToAssetMapping[upc].assetState = State.ReceivedByCons;
        emit ReceivedByCons(upc);
    }
    
    // consumer accepts part
    function acceptPart (uint upc) public onlyConsumer(msg.sender) received(upc){
        Asset memory newAsset = upcToAssetMapping[upc];
        address payable customerAddress = newAsset.consumerAddress;
        require(msg.sender == customerAddress, "current customer is not authentic owner of this asset");
        address payable cncOwnerAddress = newAsset.cncOwnerAddress;
        
        
        upcToAssetMapping[upc].assetState = State.AcceptedByCons;
        emit AcceptedByCons(upc);
    
    // if accept then transfer money
    uint assetPrice = newAsset.price;
    uint consumerPaid = consumerAddressToEscrowDeposit[customerAddress];
    
    if(consumerPaid > assetPrice) {
        
        // this is where we settle payment
        uint refund = consumerPaid - assetPrice;
        customerAddress.transfer(refund);
        cncOwnerAddress.transfer(assetPrice);
    }else {
        // just equal amount paid by customer so no refund
        cncOwnerAddress.transfer(assetPrice);
    }
    
    // then zero the escrow deposit amount
    consumerAddressToEscrowDeposit[customerAddress] = 0;
    
    // register an order completed against the cncowner address
    cncOwnerAddressToOrderCompletedHistory[cncOwnerAddress]["ordersCompleted"] = cncOwnerAddressToOrderCompletedHistory[cncOwnerAddress]["ordersCompleted"] + 1;

    }
    
    // consumer rejects part
    function rejectPart (uint upc) public onlyConsumer(msg.sender) received(upc){
        Asset memory newAsset = upcToAssetMapping[upc];
        address payable customerAddress = newAsset.consumerAddress;
        require(msg.sender == customerAddress, "current customer is not authentic owner of this asset");
        
        // if reject then transfer all money to consumer
        uint consumerPaid = consumerAddressToEscrowDeposit[customerAddress];
        customerAddress.transfer(consumerPaid);
    
        upcToAssetMapping[upc].assetState = State.RejectedByCons;
        emit RejectedByCons(upc);

    }
    
    
    ///////////////////////////////// helper or utility functions below this line////////////////////////////////////////////////////////////////////////
    function updateMaterialClassToUnitPriceMapping(uint class, uint unitprice) public onlyOwner {
        require(unitprice <= 100000000000000000000 && unitprice >= 0, "supplied unitprice is either negative or too unrealistically high of a value");
        materialClassToUnitPriceMapping[class] = unitprice;
    }
    
    function updateVolumeClassToFactorMapping(uint class, uint factor) public onlyOwner {
        require(factor <= 50 && factor > 0, "supplied factor is either negative or too unrealistically high of a value");
        volumeClassToFactorMapping[class] = factor;
    }
    
    function deleteMaterialClassToUnitPriceMappingEntry(uint class) public onlyOwner returns (bool){
        delete materialClassToUnitPriceMapping[class];
        return true;
    }
    
    function deleteVolumeClassToFactorMappingEntry(uint class) public onlyOwner returns (bool){
        delete volumeClassToFactorMapping[class];
        return true;
    }
    
    function getOrderSucessHistory(address cncOwnerAddress) public view onlyConsumer(msg.sender) returns(uint, uint){
        return (cncOwnerAddressToOrderCompletedHistory[cncOwnerAddress]["ordersTaken"],cncOwnerAddressToOrderCompletedHistory[cncOwnerAddress]["ordersCompleted"]); 
    }
    
    function registerCncOwner() public onlyCncOwner(msg.sender) {
        
        for(uint i=0; i < cncOwnerAddressRegistered.length; i++) {
            address cncOwner_ = cncOwnerAddressRegistered[i];
            if (cncOwner_ == msg.sender) {
                revert("address is already registred");
            }
        }
        
        cncOwnerAddressRegistered.push(msg.sender);
        cncOwnerAddressRegisteredAvailableMapping[msg.sender] = true;
    }
    

    
}
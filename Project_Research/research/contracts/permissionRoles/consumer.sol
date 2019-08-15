pragma solidity >=0.4.24;
import "./basePermission.sol";

contract Consumer {
    
    // import the base permission library
    using basePermission for basePermission.Role;
    
    // register events for adding and removing Consumer
    event ConsumerAdded(address indexed account);
    event ConsumerRemoved(address indexed account);
    
    // inherit the Role struct for Consumers
    basePermission.Role private consumers;
    
    // create an owner address variable for this contract
    address private consumerContractOwner;
    
    // make the deployer of the contract the owner
    constructor () public {
        consumerContractOwner= msg.sender;
    }
    
    //allow contract owner only to add and revoke roles
    modifier onlyContractOwner (address account) {
        require( account == consumerContractOwner,"caller has no permission to call this function");
        _;
    }
    
    // define a function to check if an address is a Consumer or not
    function isConsumer (address account) public view returns (bool) {
        return consumers.alreadyMember(account);
    }
    
    // define a function addConsumer to add this Consumer
    function addConsumer (address account) public onlyContractOwner(msg.sender) {
        consumers.addMember(account);
        emit ConsumerAdded(account);
    }
    
    // define a function removeConsumer to remove this Consumer
    function removeConsumer (address account) public onlyContractOwner(msg.sender) {
        consumers.removeMember(account);
        emit ConsumerRemoved(account);
    }
  
}

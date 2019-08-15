pragma solidity >=0.4.24;
import "./basePermission.sol";

contract cncOwner {
    
    // import the base permission library
    using basePermission for basePermission.Role;
    
    // register events for adding and removing cncOwner
    event cncOwnerAdded(address indexed account);
    event cncOwnerRemoved(address indexed account);
    
    // inherit the Role struct for Sourcers
    basePermission.Role private cncOwners;
    
    // create an owner address variable for this contract
    address private cncOwnerContractOwner;
    
    // make the deployer of the contract the owner
    constructor () public {
        cncOwnerContractOwner = msg.sender;
    }
    
    //allow contract owner only to add and revoke roles
    modifier onlyContractOwner (address account) {
        require( account == cncOwnerContractOwner, "caller has no permission to call this function");
        _;
    }
    
    // define a function to check if an address is a sourcer or not
    function iscncOwner (address account) public view returns (bool) {
        return cncOwners.alreadyMember(account);
        
    }
    
    // define a function addcncOwner to add this cncOwner
    function addcncOwner (address account) public onlyContractOwner(msg.sender) {
        cncOwners.addMember(account);
        emit cncOwnerAdded(account);
    }
    
    // define a function removecncOwner to remove this cncOwner
    function removecncOwner (address account) public onlyContractOwner(msg.sender) {
        cncOwners.removeMember(account);
        emit cncOwnerRemoved(account);
    }
  
}

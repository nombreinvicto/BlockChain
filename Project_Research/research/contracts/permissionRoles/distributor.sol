pragma solidity >=0.4.24;
import "./basePermission.sol";

contract Distributor {
    
    // import the base permission library
    using basePermission for basePermission.Role;
    
    // register events for adding and removing Distributor
    event DistributorAdded(address indexed account);
    event DistributorRemoved(address indexed account);
    
    // inherit the Role struct for Distributors
    basePermission.Role private distributors;
    
    // create an owner address variable for this contract
    address private distributorContractOwner;
    
    // make the deployer of the contract the owner
    constructor () public {
        distributorContractOwner= msg.sender;
    }
    
    //allow contract owner only to add and revoke roles
    modifier onlyContractOwner (address account) {
        require( account == distributorContractOwner,"caller has no permission to call this function");
        _;
    }
    
    // define a function to check if an address is a Distributor or not
    function isDistributor (address account) public view returns (bool) {
        return distributors.alreadyMember(account);
    }
    
    // define a function addDistributor to add this Distributor
    function addDistributor (address account) public onlyContractOwner(msg.sender) {
        distributors.addMember(account);
        emit DistributorAdded(account);
    }
    
    // define a function removeDistributor to remove this Distributor
    function removeDistributor (address account) public onlyContractOwner(msg.sender) {
        distributors.removeMember(account);
        emit DistributorRemoved(account);
    }
  
}

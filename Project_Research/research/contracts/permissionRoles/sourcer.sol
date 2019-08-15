pragma solidity >=0.4.24;
import "./basePermission.sol";

contract Sourcer {
    
    // import the base permission library
    using basePermission for basePermission.Role;
    
    // register events for adding and removing sourcer
    event SourcerAdded(address indexed account);
    event SourcerRemoved(address indexed account);
    
    // inherit the Role struct for Sourcers
    basePermission.Role private sourcers;
    
    // create an owner address variable for this contract
    address private sourcerContractOwner;
    
    // make the deployer of the contract the owner
    constructor () public {
        sourcerContractOwner = msg.sender;
    }
    
    //allow contract owner only to add and revoke roles
    modifier onlyContractOwner (address account) {
        require( account == sourcerContractOwner, "caller has no permission to call this function");
        _;
    }
    
    // define a function to check if an address is a sourcer or not
    function isSourcer (address account) public view returns (bool) {
        return sourcers.alreadyMember(account);
    }
    
    // define a function addSourcer to add this sourcer
    function addSourcer (address account) public onlyContractOwner(msg.sender) {
        sourcers.addMember(account);
        emit SourcerAdded(account);
    }
    
    // define a function removeSourcer to remove this sourcer
    function removeSourcer (address account) public onlyContractOwner(msg.sender) {
        sourcers.removeMember(account);
        emit SourcerRemoved(account);
    }
  
}

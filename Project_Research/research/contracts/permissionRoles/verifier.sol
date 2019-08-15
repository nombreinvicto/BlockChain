pragma solidity >=0.4.24;
import "./basePermission.sol";

contract Verifier {
    
    // import the base permission library
    using basePermission for basePermission.Role;
    
    // register events for adding and removing verifier
    event VerifierAdded(address indexed account);
    event VerifierRemoved(address indexed account);
    
    // inherit the Role struct for verifiers
    basePermission.Role private verifiers;
    
    // create an owner address variable for this contract
    address private verifierContractOwner;
    
    // make the deployer of the contract the owner
    constructor () public {
        verifierContractOwner = msg.sender;
    }
    
    //allow contract owner only to add and revoke roles
    modifier onlyContractOwner (address account) {
        require( account == verifierContractOwner,"caller has no permission to call this function");
        _;
    }
    
    // define a function to check if an address is a verifier or not
    function isVerifier (address account) public view returns (bool) {
        return verifiers.alreadyMember(account);
    }
    
    // define a function addSourcer to add this sourcer
    function addVerifier (address account) public onlyContractOwner(msg.sender) {
        verifiers.addMember(account);
        emit VerifierAdded(account);
    }
    
    // define a function removeSourcer to remove this sourcer
    function removeVerifier (address account) public onlyContractOwner(msg.sender) {
        verifiers.removeMember(account);
        emit VerifierRemoved(account);
    }
  
}

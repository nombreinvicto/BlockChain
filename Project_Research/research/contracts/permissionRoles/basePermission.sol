pragma solidity >= 0.4.24;

library basePermission {
    
    struct Role {
        mapping(address => bool) members;
    }
    
    // provide an account address and give it access to this role
    function addMember (Role storage role, address account) internal {
        require(account != address (0),"zero address cannot assume Role");
        require(!alreadyMember(role, account));
        role.members[account] = true;
    }
    
    // provide an account address to remove from the current role
    function removeMember (Role storage role, address account) internal {
        require(account != address (0),"zero address cannot be removed from Role");
        require(alreadyMember(role, account), "given address is not a member of this role hence cant be removed");
        role.members[account] = false;
    }
    
    // check if a member is already a member or not
    function alreadyMember (Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "checking permission of zero address not allowed");
        return role.members[account];
    }
    
}

pragma solidity >=0.4.0;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";

contract StarNotary is ERC721{
    
    struct Star {
        string name;
    }
    
    
    mapping(uint256 => Star) public tokenIdToStarInfo;
    
    // tokenId to price
    mapping(uint256 => uint256) public starsForSale_IdToPrice;
    
    function createStar(string memory name, uint256 _tokenId) public {
        Star memory newStar = Star(name);
        tokenIdToStarInfo[_tokenId] = newStar;
        _mint(msg.sender, _tokenId);
    }
    
    function putStarUpForSale(uint256 _tokenId, uint256 _price)
    public{
        require(msg.sender == ownerOf(_tokenId), "Non owner tryingto put star for sale");
        starsForSale_IdToPrice[_tokenId] = _price;
    }
    
    function buyStar(uint256 _tokenId) public payable {
        
        // first check if it is put up for sale
        require(starsForSale_IdToPrice[_tokenId] != 0, "star withgiven id not for sale");
        
        
        uint256 starCost = starsForSale_IdToPrice[_tokenId];
        address currentOwner = ownerOf(_tokenId);
        
        require(msg.value >= starCost, "not enough ether to buy");
        
        // transfer the _tokenId from owner to new owner
        _transferFrom(currentOwner, msg.sender, _tokenId);
        
        address payable currentOwnerPayableAddress =
        address(uint160(currentOwner));
        
        currentOwnerPayableAddress.transfer(starCost);
        if (msg.value > starCost) {
            msg.sender.transfer(msg.value - starCost);
        }
        
        starsForSale_IdToPrice[_tokenId] = 0;
    }
    
}

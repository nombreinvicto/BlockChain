pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";

contract StarNotary is ERC721 {
    
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
    
    // mapping of starFingerPrint to star struct
    // starFingerPrint is considered to be the unique
    // tokenId identifier here
    mapping(uint256 => Star) public tokenIdToStarInfo;
    
    // maps star tokenId to sale price
    mapping(uint256 => uint256) public starsForSale;
    
    // tokenId to starFingerPrints
    mapping(uint256 => uint256) public tokenIdToFingerPrint;
    
    // create a star with provided info
    function createStar(string _name, string _starStory,
        string _ra, string _dec, string _mag,
        uint256 _tokenId) public {
        // Create a `Star memory newStar` variable
        
        // Before creating a star, check if it already exists or not
        // according to its coordinate fingerprint. Here we store the
        // keccak256(_ra, _dec, _mag) as the tokenId for a star which is
        // bound to be unique for a certain combination of coordinates.
        // we dont have to consider uniqueness on the basis of the supplied
        // tokenId as it is taken care of via the _mint function of ERC721
        require(checkIfStarExist(_ra, _dec, _mag) == false);
        
        // if the star doesnt already exist, make a new star
        Star memory newStar = Star(_name, _starStory, _ra, _dec, _mag, true);
        uint256 fingerprint = generateFingerprint(_ra, _dec, _mag);
        tokenIdToStarInfo[fingerprint] = newStar;
        tokenIdToFingerPrint[_tokenId] = fingerprint;
        // duplicate tokenId is taken care of via the _mint function
        _mint(msg.sender, _tokenId);
    }
    
    function putStarUpForSale(uint256 _tokenId, uint256 _price) public {
        require(this.ownerOf(_tokenId) == msg.sender);
        starsForSale[_tokenId] = _price;
    }
    
    function buyStar(uint256 _tokenId) public payable {
        require(starsForSale[_tokenId] > 0);
        
        uint256 starCost = starsForSale[_tokenId];
        address starOwner = this.ownerOf(_tokenId);
        require(msg.value >= starCost);
        
        _removeTokenFrom(starOwner, _tokenId);
        _addTokenTo(msg.sender, _tokenId);
        
        if (msg.value > starCost) {
            // transfer overpay difference back to buyer
            msg.sender.transfer(msg.value - starCost);
        }
        // transfer cost to the owner
        starOwner.transfer(starCost);
    }
    
    // helper function that checks if a star already exists or not
    function checkIfStarExist(string _ra, string _dec, string _mag) public view returns (bool){
        
        uint starFingerprint = generateFingerprint(_ra, _dec, _mag);
        if (tokenIdToStarInfo[starFingerprint].starSaved == true) {
            return true;
        } else {
            return false;
        }
    }
    
    // helper function that generates a keccak256 hash against supplied star coordinates
    function generateFingerprint(string _r, string _d, string _m) public view returns (uint256){
        return uint256(keccak256(abi.encodePacked(_r, _d, _m)));
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access//Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract BoomerSquad is ERC721Enumerable, Ownable {
  using Strings for uint256;
  
  
  uint256 public mintPrice;
  uint256 public WLmintPrice;
  string public baseURI;
  bool internal presaleState = false;
  bool internal saleState = false;
  uint256 public maxSupply;

  mapping(address => bool) _allowList;
  mapping(address => uint256) _allowListClaimed;

  constructor(
    uint256 _mintPrice, 
    uint256 _WLmintPrice, 
    string memory _baseURIValue, 
    uint256 _maxSupply
     ) ERC721(
    "BoomerSquad",
    "BOOMER"
  ) {
    mintPrice = _mintPrice;
    WLmintPrice = _WLmintPrice;
    baseURI = _baseURIValue;
    maxSupply = _maxSupply;
  }
  function setBaseURI(string memory baseURI_) external onlyOwner {
    baseURI = baseURI_;
  }
  function _baseURI() internal view override returns (string memory) {
   return baseURI;
  }
  function updateMintPrice(uint256 _mintPrice) public onlyOwner {
    mintPrice = _mintPrice;
   }

  function getMintPrice(uint256 amount) external view returns (uint256) {
    return SafeMath.mul(amount,mintPrice);
  }
  
  function updateWLMintPrice(uint256 _WLmintPrice) public onlyOwner {
    WLmintPrice = _WLmintPrice;
   }

  function getWLMintPrice(uint256 amount) external view returns (uint256) {
    return SafeMath.mul(amount,WLmintPrice);
  }



  function withdraw() public payable onlyOwner {
    (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
    require(success);
  }


  function adminMint(uint numberOfTokens) public onlyOwner {
        require(numberOfTokens > 0, ">0");
        uint256 supply = super.totalSupply();        
        require(SafeMath.add(supply,numberOfTokens) <= maxSupply, "X");

        

        for (uint i = 0; i < numberOfTokens; i++) {
            _safeMint(msg.sender, SafeMath.add(super.totalSupply(),1));
        }

 }    



  function mintBoomer(uint numberOfTokens) public payable {
        require(saleState, "No Sale");
        require(numberOfTokens > 0, ">0");
        uint256 supply = super.totalSupply();        
        require(SafeMath.add(supply,numberOfTokens) <= maxSupply, "X");
        require(numberOfTokens <= 10,"Lmt10");
        require(SafeMath.mul(mintPrice, numberOfTokens) <= msg.value, "Pymt MM");

        

        for (uint i = 0; i < numberOfTokens; i++) {
            _safeMint(msg.sender, SafeMath.add(super.totalSupply(),1));
        }

 } 

        
  function WLmintBoomer(uint numberOfTokens) public payable {
        require(presaleState, "No Sale");
        require(_allowList[msg.sender] == true,"WL err");
        uint256 supply = super.totalSupply();  
        require(SafeMath.add(supply,numberOfTokens) <= maxSupply, "X");
        require(_allowListClaimed[msg.sender] + numberOfTokens <= 5,"Lmt5");
        require(numberOfTokens > 0, ">0");
        require(SafeMath.mul(WLmintPrice, numberOfTokens) <= msg.value, "Pymt MM");
        
        

        for (uint i = 0; i < numberOfTokens; i++) {
            _safeMint(msg.sender,  SafeMath.add(super.totalSupply(),1));
        }


           _allowListClaimed[msg.sender] += numberOfTokens;
       
  }
    
  function setPresaleState(bool state) external onlyOwner {
        presaleState = state;
  }
    
  function setSaleState(bool state) external onlyOwner {
        saleState = state;
  }
  
   
  function addToWhitelist(address[] memory addresses) public onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
          require(addresses[i] != address(0), "Null Adrs");
        
          _allowList[addresses[i]] = true;
          _allowListClaimed[addresses[i]] > 0 ? _allowListClaimed[addresses[i]] : 0;
        }
  }
    
  function isWhitelisted (address addr) public view returns (bool) {
        return _allowList[addr];  
  }    
    
  function removeFromAllowList(address[] calldata addresses) external onlyOwner {
       
      for (uint256 i = 0; i < addresses.length; i++) {
          require(addresses[i] != address(0), "Null Adrs");
          _allowList[addresses[i]] = false;
      }
  }     
}

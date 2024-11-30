// SPDX-License-Identifier: MIT


/*
  /$$$$$$  /$$$$$$$$ /$$$$$$$$ /$$    /$$ /$$$$$$ /$$$$$$$$ /$$$$$$$
 /$$__  $$|__  $$__/| $$_____/| $$   | $$|_  $$_/| $$_____/| $$__  $$
| $$  \__/   | $$   | $$      | $$   | $$  | $$  | $$      | $$  \ $$
|  $$$$$$    | $$   | $$$$$   |  $$ / $$/  | $$  | $$$$$   | $$$$$$$/
 \____  $$   | $$   | $$__/    \  $$ $$/   | $$  | $$__/   | $$____/
 /$$  \ $$   | $$   | $$        \  $$$/    | $$  | $$      | $$
|  $$$$$$/   | $$   | $$$$$$$$   \  $/    /$$$$$$| $$$$$$$$| $$
 \______/    |__/   |________/    \_/    |______/|________/|__/


                    contract by steviep.eth
*/


import "./Dependencies.sol";
import "./ERC721A.sol";
import "./SVGRenderer.sol";



pragma solidity ^0.8.28;


contract OneMillionTrees is ERC721A, Ownable {
  SVGRenderer public tokenURIContract;

  address public mintingAddress;
  bool transient isReplanting;

  event MetadataUpdate(uint256 _tokenId);
  event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);

  constructor() ERC721A('One Million Trees', 'TREE') {
    tokenURIContract = new SVGRenderer(block.prevrandao);
  }

  function plant(uint256 quantity) external {
    require(_totalMinted() + quantity <= 1000000, 'Can only plant 1 million trees');
    _mint(address(this), quantity);
  }


  function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
    return isReplanting
      ? owner == address(this)
      : super.isApprovedForAll(owner, operator);
  }

  function replant(uint256 tokenId) external {
    isReplanting = true;
    require(ownerOf(tokenId) == address(this), 'Tree has already been replanted');
    safeTransferFrom(address(this), msg.sender, tokenId);
    isReplanting = false;
  }


  function exists(uint256 tokenId) external view returns (bool) {
    return _exists(tokenId);
  }



  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    return tokenURIContract.tokenURI(tokenId);
  }

  function setTokenURI(address c) external onlyOwner {
    tokenURIContract = SVGRenderer(c);
  }

  function burn(uint256 tokenId) external {
    _burn(tokenId, true);
    emit MetadataUpdate(tokenId);
  }

  function isBurnt(uint256 tokenId) public view returns (bool) {
    return !_exists(tokenId) && tokenId < _totalMinted();
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721A) returns (bool) {
    return interfaceId == bytes4(0x49064906) || super.supportsInterface(interfaceId);
  }
}


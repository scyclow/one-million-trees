// SPDX-License-Identifier: MIT


import "./Dependencies.sol";
import "./OneMillionTrees.sol";


pragma solidity ^0.8.11;


contract SVGRenderer {

  uint256 immutable initHash;
  OneMillionTrees public nftContract;

  struct Coords {
    int x;
    int y;
  }


  struct Token {
    uint256 tokenId;
    uint256 baseSeed;
    bool burnt;
  }

  constructor(uint256 _initHash) {
    initHash = _initHash;
    nftContract = OneMillionTrees(msg.sender);
  }

  // function isBurnt(uint256 tokenId) public view returns (bool) {
  //   return true;
  //   // return !nftContract.exists(tokenId) && tokenId < nftContract.totalMinted();
  // }

  function tokenURI(uint256 tokenId) external view returns (string memory) {
    string memory tokenString = Strings.toString(tokenId);

    bytes memory encodedSVG = abi.encodePacked(
      'data:image/svg+xml;base64,',
      Base64.encode(abi.encodePacked(render(tokenId, nftContract.isBurnt(tokenId))))
    );

    return string(abi.encodePacked(
      'data:application/json;utf8,'
      '{"name": "ONE MILLION TREES: Tree #', tokenString,
      '", "description": "Pursuant to the terms and conditions outlined in Smart Burn Contract #7 (deployed at 0x4febe040d13dbddcca8aa675481314264339e857 on Ethereum L1), the owner has successfully planted one million trees within 2 years of the initial purchase date (12/29/22), thus satisfying his contractual obligation.'
      '", "license": "CC0'
      '", "image": "', encodedSVG,
      '", "external_url": "https://steviep.xyz/one-million-trees'
      '"}'
    ));
  }


  function render(uint256 tokenId, bool burnt) view public returns (string memory svg) {
    uint256 seed = uint256(keccak256(abi.encodePacked(
      initHash, tokenId
    )));

    return string(abi.encodePacked(
      '<svg id="svg" viewBox="0 0 1000 1000" version="1.1" xmlns="http://www.w3.org/2000/svg">'
      '<rect x="0" y="0" width="1000" height="1000" fill="', burnt ? '#ba1500' : '#fff','"></rect>',
      drawTree(Coords(500, 800), Token(tokenId, seed, burnt), Trig.PI, 256, seed, 0),
      '</svg>'
    ));
  }


  function drawTree(Coords memory cStart, Token memory token, uint256 deg, int len, uint256 seed, uint8 level) view public returns (string memory) {
    // uint256 levelSeed = ;



    deg = uint(Trig.TWO_PI + deg + (
      rnd(seed, 19, 1) / (
        level == 0
          ? 50
          : 38 - 2*level)
    ) - 100000000000000000);
    len = len * (800 + 2*int(rnd(seed, 2, 20))) / 1000;

    Coords memory cEnd = getXYRotation(deg, len, cStart);


    string memory s;

    if ((token.baseSeed % 10) < 1) {
      s = string(abi.encodePacked(
        'S',
        Strings.toString(uint(cStart.x + cEnd.x)*(token.baseSeed/10 % 2 == 0 ? 550 : 400) /1000),
        ' ',
        Strings.toString(uint(cStart.y + cEnd.y)*(token.baseSeed/10 % 2 == 0 ? 550 : 400) /1000)
      ));
    }

    else if ((token.baseSeed % 10) < 2) {
      s = '';
    } else {
      s = string(abi.encodePacked(
        'S',
        Strings.toString(uint(cStart.x + cEnd.x)*(seed % 2 == 0 ? 475 : 525 + rnd(seed, 2, 30)/80)/1000),
        ' ',
        Strings.toString(uint(cStart.y + cEnd.y)*(seed % 2 == 0 ? 475 : 525 + rnd(seed, 2, 33)/80)/1000)
      ));
    }


    // } else if ((seed % 10) < 5) {
      // s = string(abi.encodePacked(
      //   'S',
      //   Strings.toString(uint(cStart.x + cEnd.x)*400 /1000),
      //   ' ',
      //   Strings.toString(uint(cStart.y + cEnd.y)*400/1000)
      // ));
    // } else


    // // } else if ((seed % 6) == 1) {
    // } else if ((seed % 10) < 8) {






    // } else {
      // s = string(abi.encodePacked(
      //   'S',
      //   Strings.toString(uint(cStart.x + cEnd.x)*(400 + rnd(uint256(keccak256(abi.encodePacked(seed, level))), 3, 30)/5)/1000),
      //   ' ',
      //   Strings.toString(uint(cStart.y + cEnd.y)*(400 + rnd(uint256(keccak256(abi.encodePacked(seed, level))), 3, 33)/5)/1000)
      // ));
    // }

    // } else if (seed % 6 == 3) {

    // } else {
    // if (seed % 6 == 4) {
      // s = '';
    // } else if (seed % 6 == 5) {
      // s = level > 6 ? string(abi.encodePacked(
      //   'S',
      //   Strings.toString(uint(cStart.x + cEnd.x)*(550 + rnd(uint256(keccak256(abi.encodePacked(seed, level))), 2, 30)/5)/1000),
      //   ' ',
      //   Strings.toString(uint(cStart.y + cEnd.y)*(550 + rnd(uint256(keccak256(abi.encodePacked(seed, level))), 2, 33)/5)/1000)
      // )) : '' ;
    // }


    string memory markup = path(cStart, cEnd, s, 8 - level, level > 6, token.burnt);

    if (level <= 7) {

      // uint256 branchLen = len*(20+level) /30;

      uint d;
      if ((token.baseSeed / 100000) % 20 == 0) {
        d = 5;
      } else if ((token.baseSeed / 100000) % 20 == 1) {
        d = 12;
      } else if ((token.baseSeed / 100000) % 20 < 5) {
        d = 14 - (seed%10);

      } else {
        d = 7;
      }

      if ((seed / 1000) % 50 != 0) {
        markup = string(abi.encodePacked(markup, drawTree(
          cEnd,
          token,
          deg + Trig.PI / d,
          len*int8(20+level) / 30,
          rnd(uint256(keccak256(abi.encodePacked(seed, level, '1'))), 10, 50),
          level + 1
        )));
      }

      if ((seed / 1000) % 50 != 1) {
        markup = string(abi.encodePacked(markup, drawTree(
          cEnd,
          token,
          deg + Trig.TWO_PI - Trig.PI / d,
          len*int8(20+level) / 30,
          rnd(uint256(keccak256(abi.encodePacked(seed, level))), 10, 60),
          level + 1
        )));
      }
    }

    return markup;

  }

  function path(Coords memory c1, Coords memory c2, string memory s, uint256 strokeWidth, bool isLeaf, bool burnt) pure public returns (string memory) {

    string memory d = string(abi.encodePacked(
      Strings.toString(c1.x), ' ', Strings.toString(c1.y),
      s,
      ',', Strings.toString(c2.x), ' ', Strings.toString(c2.y)
    ));
    return string(abi.encodePacked(
      '<path stroke="', burnt ? '#000' : isLeaf ? '#007409' : '#5b3400','" fill="none" stroke-linecap="round" stroke-width="', Strings.toString(strokeWidth),'" d="M', d, '"/>'
    ));
  }

  function rnd(uint256 seed, uint8 digits, uint256 place) pure public returns (uint256) {
    return (seed / place) % (10 ** digits);
  }


  function getXYRotation(uint256 deg, int radius, Coords memory cStart) pure public returns (Coords memory) {
    Coords memory r;
    r.x = (Trig.sin(deg) * radius / 1000000000000000000) + cStart.x;
    r.y = (Trig.cos(deg) * radius / 1000000000000000000) + cStart.y;
    return r;
  }
}


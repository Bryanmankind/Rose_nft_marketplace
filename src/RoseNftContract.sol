// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract RoseNft is ERC721, Ownable{

    // @notice Counter used for generating unique token ids.
    uint256 private _currentTokenId;

    // keep track of the part of the bird
    struct BirdColors {
        string Body;
        string wings;
        string eyes;
        string tail;
        string legs;
        string beak;
    }

    // svg image of the first Bird 

    string Bird_default = 
       '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="1024" height="1024" viewBox="0 0 1024 1024">';

    constructor () ERC721 ("BirdNft", "Brd") Ownable(msg.sender){}

    function mint () public returns (bool) {
    }
}

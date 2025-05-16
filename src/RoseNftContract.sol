// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract RoseNft is IERC721 {

    constructor () is IERC721 ("Birdnft", "Brd") {
        
    }
}

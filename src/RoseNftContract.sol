// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract RoseNft is ERC721, Ownable{

    // @notice Counter used for generating unique token ids.
    uint256 private _currentBirdId;
    uint256 public BirdId;
    uint256 public currentNumOfBirdGenBreed;

    mapping(address => uint256) public userBirdIdBalance; 
    mapping(uint256 => address) public ownerOfBirdNft;

    uint256 constant MAX_BIRD_GEN_BREED = 10;


    error birdGenBreedExceeded();

    // keep track of the bird gen structure 
    struct Bird {
        uint genes;
        uint64 birthTime;
        uint32 mumId;
        uint32 dadId;
        uint32 readyTime;
        uint16 generation;
    }

    Bird[] public birdList;

    event Birth(address owner, uint256 kittenId, uint256 mumId, uint256 dadId, uint256 genes);

    constructor () ERC721 ("BirdNft", "Brd") Ownable(msg.sender){}

    function mint () public returns (bool) {
    }

    // This function returns the number of Bird Nft owned by an address
    function balanceOf(address _owner) public view override returns (uint256 balance) {
        balance = userBirdIdBalance[_owner];
    }

    // This function returns the owner of the Bird nft 
    function ownerOf(uint256 _birdId) public view override returns (address owner) {
        owner = ownerOfBirdNft[_birdId];
    }

    function createBirdNftOrigin (uint256 _birdGenes) public onlyOwner returns (uint256) {
        if (currentNumOfBirdGenBreed > MAX_BIRD_GEN_BREED) {
            revert birdGenBreedExceeded();
        }

        currentNumOfBirdGenBreed++;

        return _createBirdNft (0, 0, 0, _birdGenes, msg.sender);
    }

    function _createBirdNft (uint256 dadBirdId, uint256 mumBirdId, uint256 generation, uint256 genes, address owner) internal returns (uint256) {
         Bird memory _birdGen01 = Bird ({
            genes: genes,
            birthTime: uint64(block.timestamp),
            mumId: uint32(mumBirdId),
            dadId: uint32(dadBirdId),
            readyTime: uint32(block.timestamp),
            generation: uint16(generation)
        });
             birdList.push(_birdGen01);

            uint newBirdNftId = birdList.length-1;
            ownerOfBirdNft[newBirdNftId]= owner;
             _transfer(address(0), owner, newBirdNftId);
            emit Birth(owner, newBirdNftId, mumBirdId, dadBirdId, genes);
            return newBirdNftId;
    }   
}

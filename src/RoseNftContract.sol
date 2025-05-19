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
    uint256 cooldownTime = 1 days;

    mapping(address => uint256) public userBirdIdBalance; 
    mapping(uint256 => address) public ownerOfBirdNft;      

    uint256 constant MAX_BIRD_GEN_BREED = 10;


    error birdGenBreedExceeded();
    error tokenDoesNotExist();
    error notTheOwner();
    error invalidAddress();
    error onlyAllowedOnceEvery24Hours();

    // keep track of the bird gen structure 
    struct Bird {
        uint256 genes;
        uint256 birthTime;
        uint256 mumId;
        uint256 dadId;
        uint256 readyTime;
        uint256 generation;
    }

    Bird[] public birdList;

    event Birth(address owner, uint256 birdId, uint256 mumId, uint256 dadId, uint256 genes);
    event Transfer(address from, address to, uint256 tokenId)

    constructor () ERC721 ("BirdNft", "Brd") Ownable(msg.sender){}

    // This function returns the number of Bird Nft owned by an address
    function balanceOf(address _owner) public view override returns (uint256 balance) {
        balance = userBirdIdBalance[_owner];
    }

    // This function returns the owner of the Bird nft 
    function ownerOf(uint256 _birdId) public view override returns (address owner) {
        owner = ownerOfBirdNft[_birdId];
    }

    // Function allow user to transfer their tokens to another address 

    function safeTransferFrom(to, tokenId) public override returns (bool) {
        if (to == address(0)) {
            revert invalidAddress();
        }

        if (ownerOfBirdNft[tokenId] != msg.sender) {
            revert notTheOwner();
        }

        safeTransferFrom(msg.sender, to, tokenId);

        emit Transfer(msg.sender, to, tokenId);
        return true;
    };

    // This function creates the first generation of Bird Nft 
    // @param _birdGenes the gene used for breeding new bird nfts
    function createBirdNftOrigin (uint256 _birdGenes) public onlyOwner returns (uint256) {
        if (currentNumOfBirdGenBreed > MAX_BIRD_GEN_BREED) {
            revert birdGenBreedExceeded();
        }

        currentNumOfBirdGenBreed++;

        return _createBirdNft (0, 0, 0, _birdGenes, msg.sender);
    }

    // This function mints the nft and sends to the users 
    function _createBirdNft (uint256 dadBirdId, uint256 mumBirdId, uint256 generation, uint256 genes, address owner) internal returns (uint256) {
         Bird memory _birdGen01 = Bird ({
            genes: genes,
            birthTime: uint256(block.timestamp),
            mumId: uint256(mumBirdId),
            dadId: uint256(dadBirdId),
            readyTime: uint256(block.timestamp),
            generation: uint256(generation)
        });
             birdList.push(_birdGen01);

            uint newBirdNftId = birdList.length-1;

            ownerOfBirdNft[newBirdNftId]= owner;

            _safeMint(owner, newBirdNftId);

            emit Birth(owner, newBirdNftId, mumBirdId, dadBirdId, genes);

            return newBirdNftId;
    }  

    // This function returns the nft of a tokenId 
    function getBird(uint tokenId) public view returns(
        uint256 genes,
        uint256 birthTime,
        uint256 mumId,
        uint256 dadId,
        uint256 generation,
        address owner
    ) {
        Bird storage bird = birdList[tokenId];
        genes = bird.genes;
        birthTime = bird.birthTime;
        mumId = uint(bird.mumId);
        dadId = uint(bird.dadId);
        generation = uint(bird.generation);
        owner = ownerOfBirdNft[tokenId];
    }

    // This function breeds new BirdNft
     function breedNewBirdNft (uint256 dadBirdId, uint256 mumBirdId) public returns (uint256 newNftDna) {
        if (dadBirdId > birdList.length ){
            revert tokenDoesNotExist();
        }

        if (mumBirdId > birdList.length ){
            revert tokenDoesNotExist();
        }
        
        if (ownerOfBirdNft[dadBirdId] != msg.sender){
            revert notTheOwner();
        }

        if (ownerOfBirdNft[mumBirdId] != msg.sender){
            revert notTheOwner();
        }

        if ((birdList[dadBirdId].readyTime) >= uint32(block.timestamp)){
            revert onlyAllowedOnceEvery24Hours();
        }

        if ((birdList[mumBirdId].readyTime) >= uint32(block.timestamp)){
            revert onlyAllowedOnceEvery24Hours();
        }

        ( uint256 dadNftDna,,,,uint256 DadGeneration, ) = getBird(dadBirdId);
        ( uint256 mumNftDna,,,,uint256 MumGeneration,) = getBird(mumBirdId);
        newNftDna = _getNewBirdDna(dadNftDna, mumNftDna);
        uint newGen = 0;
        if (DadGeneration < MumGeneration){
            newGen = MumGeneration + 1;
            newGen /= 2;
        } else if (DadGeneration > MumGeneration){
            newGen = DadGeneration + 1;
            newGen /= 2;
        } else{
            newGen = MumGeneration + 1;
        }
        birdList[dadBirdId].readyTime = uint32(block.timestamp+cooldownTime);
        birdList[mumBirdId].readyTime = uint32(block.timestamp+cooldownTime);

        _createBirdNft(mumNftDna, dadNftDna, newGen, newNftDna, msg.sender);
    } 

    // This function  It takes two parent DNA values and creates a new one  
    // @param _dadDna dna value of the dad bird. 
    // @param _mumDna dnd value of the mum bird.
    function _getNewBirdDna(uint _dadNftDna, uint _mumNftDna) internal view returns(uint) {

       
        uint[8] memory geneArray;      //stores 8 parts of the new DNA (each part = 2 digits).

        uint8 random = uint8(block.timestamp % 255);  // used for randomness in gene selection.

        uint index = 7;

        uint randomPos = uint(block.timestamp % 8);     //selects one gene slot to be randomly mutated.

        for (uint i=1; i<=128; i=i*2){
            if (index == randomPos){
                uint newFeature = block.timestamp % 99;
                if (newFeature < 11){
                    geneArray[index] = 11;
                }else{
                    geneArray[index] = newFeature;
                }
            }else{
                if (random & i != 0){
                    geneArray[index] = _dadNftDna % 100;
                }else{
                    geneArray[index] = _mumNftDna % 100;
                }
            }

            _dadNftDna = _dadNftDna / 100;
            _mumNftDna = _mumNftDna / 100;

            if (index > 0){
                index--;
            }
        }

        uint nftDna;
        for (uint i=0; i<8; i++){
            nftDna = nftDna + geneArray[i];
            if (i != 7){
                nftDna = nftDna * 100;
            }
        }
        return nftDna;
    }
    
}

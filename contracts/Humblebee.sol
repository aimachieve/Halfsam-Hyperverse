// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
import "hardhat/console.sol";

import "./hyperverse/IHyperverseModule.sol";
import "./hyperverse/Initializable.sol";
import "./utils/Counters.sol";
import "./utils/Strings.sol";
import "./utils/Address.sol";
import "./utils/Context.sol";
import "./helper/ERC165.sol";
import "./helper/ReentrancyGuard.sol";

import "./interface/IERC721Metadata.sol";
import "./interface/IERC721.sol";
import "./interface/IERC721Receiver.sol";
import "./interface/IERC20.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Humblebee is
    Context,
    ERC165,
    IERC721,
    IERC721Metadata,
    ReentrancyGuard,
    Initializable,
    IHyperverseModule,
    ERC721Enumerable,
    Ownable
{
    using Counters for Counters.Counter;
    using Strings for uint256;
    using Address for address;

    address busdAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address tbusdAddress = 0xB0D0eDB26B7728b97Ef6726dAc6FB7a43d6043E1;

    IERC20 busd = IERC20(busdAddress);
    IERC20 tbusd = IERC20(tbusdAddress);

    address public creatorAddress = 0xA0B073bE8799A742407aB04eC02b2BfD860a1B71;

    event NewBaseURI(address base_uri);

    // Optional mapping for owner, tokenId, tokenURI
    struct NFT {
        uint256 tokenId;
        string tokenURI;
        uint256 price;
        uint256 pi;
        bool sale;
        string title;
        address owner;
        string medias;
        uint[] history;
        string date; 
        bool status;
    }
    mapping(uint256 => NFT) public NFTs;

    constructor() ERC721("Humblebee", "HB") {}

    function mintNFT(
        address recipient,
        string memory tokenURI,
        uint256 price,
        uint256 pi
    ) public onlyOwner {
        _tokenIds.increment();

				sendFunds(msg.sender);

        uint256 newTokenId = _tokenIds.current();
        _safeMint(recipient, newTokenId);

        NFTs[newTokenId] = NFT({
            tokenId: newTokenId,
            tokenURI: tokenURI,
            price: price,
            pi: pi,
            sale: true
        });
    }

    function sendFunds(address sender) public {
        tbusd.transferFrom(sender, address(this), price * 10**18);
    }

    function modifyStatus(_status) public {
        NFTs[newTokenId].status = _status;
    }

    function generateAddress() public {
        
    }

    function claim() public {
        // 3% fee (3 / 100)
        tbusd.transferFrom( address(this), msg.sender, amount * 3 / 100);

        // 97% to another one
        tbusd.transferFrom(address(this), userB, amount * 97 / 100);
    }
    // Utils
    function tokensOfOwner(address _owner)
        external
        view
        returns (uint256[] memory)
    {
        uint256 tokenCount = balanceOf(_owner);
        uint256[] memory tokensIds = new uint256[](tokenCount);
        for (uint256 i = 0; i < tokenCount; i++) {
            tokensIds[i] = tokenOfOwnerByIndex(_owner, i);
        }

        return tokensIds;
    }

    function buyNFT(uint256 tokenId, uint256 price) public {
        address _owner = ownerOf(tokenId);
        safeTransferFrom(_owner, msg.sender, tokenId);
        // to davide : royalty
        tbusd.transferFrom(
            msg.sender,
            creatorAddress,
            ((price * 3) / 100) * 10**18
        );
        // to buyer : price - royalty
        tbusd.transferFrom(msg.sender, _owner, ((price * 97) / 100) * 10**18);

        // change the price to add P.I
        NFTs[tokenId].price =
            NFTs[tokenId].price *
            (1 + NFTs[tokenId].pi / 100);
        // Sale status : false
        NFTs[tokenId].sale = false;
    }

    function resellNFT(uint256 tokenId) public {
        NFTs[tokenId].sale = true;
    }

    // GETTER
    function _totalSupply() internal view returns (uint256) {
        return _tokenIds.current();
    }

    function totalMint() public view returns (uint256) {
        return _totalSupply();
    }

    function getNFT(uint256 _tokenId)
        external
        view
        returns (bool, string memory)
    {
        return (NFTs[_tokenId].sale, NFTs[_tokenId].tokenURI);
    }

    function newBaseURI(address base_uri) public onlyOwner {
        creatorAddress = base_uri;
        emit NewBaseURI(creatorAddress);
    }

    function withdrawAll() public payable onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0);
        _widthdraw(creatorAddress, address(this).balance);
    }

    function _widthdraw(address _address, uint256 _amount) private {
        (bool success, ) = _address.call{value: _amount}("");
        require(success, "Transfer failed.");
    }
}

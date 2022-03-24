// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract Lotto is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    uint256 public ticketCount = 5;
    uint256 public ticketPrice;
    address private admin;
    bool private minted = false; 
    string[] tickets = ["https://gateway.pinata.cloud/ipfs/QmUhKnkrUmi5y1UXfa3nEyV6rYfp1ejjkeBDMRaS5EbQCK",
                        "https://gateway.pinata.cloud/ipfs/Qmc2vBojiqExYGZY2NVZ8ATbe8haLzdr9sECpXDKq3wi5A",
                        "https://gateway.pinata.cloud/ipfs/QmWRq8jQEBfesDuGGGXEh5rJ8Wea4bADvu7UKrf4uetuwA",
                        "https://gateway.pinata.cloud/ipfs/QmQ4AUd6v16nBDE6e6DWJjmQ2nJ2qRuRt3ywexqDLYBAGu",
                        "https://gateway.pinata.cloud/ipfs/QmXthVu2Q1ZkRDWvc8pVZ6hKYizYLnGQRFaShCGAb4FgGf"];


    constructor(uint256 _ticketPrice) ERC721("Be$tLuck", "B$L") 
    {
        admin = msg.sender;
        ticketPrice = _ticketPrice;
    }

    event Sell(address _buyer);

    function multiply(uint x, uint y) internal pure returns (uint z) 
    {
        require(y == 0 || (z = x * y) / y == x);
    }

    function buyTicket() public payable 
    {
        require(msg.value == ticketPrice, "not enaught ether");
        require(balanceOf(address(this)) >= 1, "some wronge with balance");
        transferFrom(address(this), msg.sender, _tokenIds.current());
        _tokenIds.decrement();
        emit Sell(msg.sender);
    }

    function mintTickets() public onlyOwner 
    {
        require(minted == false);
        for (uint i = 0; i < ticketCount; i++) 
            {
                mintTicket(address(this), tickets[i]);
            }
        minted = true;
    }

    function mintTicket(address recipient, string memory tokenURI)
        private returns (uint256)
    {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(recipient, newItemId);
        _setTokenURI(newItemId, tokenURI);
        return newItemId;
    }
}
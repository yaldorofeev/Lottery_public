// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract Lotto is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    uint256[] public mintedTickets;
    uint256[] soldTicketIds;
    uint256 public ticketCount;
    uint256 public ticketPrice;  
    address private admin;
    address[] public winners;
    uint public startTime;
    uint public limitTimeDay; // in days;
    uint public limitTime;     // in sec;
    uint256 public soldBound;  // in units;
    uint256 public soldCount;  // in units;
    bool public onGame = false; 


    constructor() ERC721("Be$tLuck", "B$L") {
    }

    event Sell(address _buyer, uint256 _tokenId);
    event SomebodyWin(address _winner);

    function buyTicket(uint256 _tokenId) public payable {
        require(msg.value == ticketPrice, "Not enaught or too much ethers");
        require(onGame, "There is no actual lottery now.");
        require(ownerOf(_tokenId) == address(this), "This token already sold");
        bytes memory stringInBytes = bytes(tokenURI(_tokenId));
        _safeTransfer(address(this), msg.sender, _tokenIds.current(), stringInBytes);
        emit Sell(msg.sender, _tokenId);
        soldTicketIds.push(_tokenId);
        uint nowTime = block.timestamp;


        // if (((nowTime >= limitTime) && (soldCount >= soldBound)) || (soldCount == ticketCount)) {
        //     letsPlayTheGame(msg.sender);
        // }
    }

    function mintTickets(uint256 _ticketPrice, string[] memory _tickets,uint _limitTimeDay) public onlyOwner {
        require(!onGame);
        ticketPrice = _ticketPrice;
        limitTimeDay = _limitTimeDay;
        for (uint i = 0; i < _tickets.length; i++) {
                mintedTickets.push(mintTicket(address(this), _tickets[i]));
            }
        onGame = true;
        ticketCount = mintedTickets.length;
        startTime = block.timestamp;
        limitTime = startTime + limitTimeDay * 1 days;
    }

    function mintTicket(address _recipient, string memory tokenURI)
        private returns (uint256) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(_recipient, newItemId);
        _setTokenURI(newItemId, tokenURI);
        return newItemId;
    }

    function endSale() public payable onlyOwner {
        require(!onGame);
        // require(tokenContract.transfer(admin, tokenContract.balanceOf(address(this))));
        // selfdestruct(payable(admin));
        // UPDATE: Let's not destroy the contract here
        // Just transfer the balance to the admin
        payable(owner()).transfer(address(this).balance);
    }

    function letsPlayTheGame(address _sender) private {
        address winner = ownerOf(soldTicketIds[random(soldTicketIds.length, _sender)]);     
        emit SomebodyWin(winner);
        winners.push(winner);
        onGame =false;
    }

    function random(uint256 _playersCount, address _sender) private view returns (uint256) {
        uint256 sender = uint256(uint160(address(_sender)));
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, sender)))%(_playersCount-1);
    }

    function cleanOldTickets() public onlyOwner {
        for (uint i = 0; i < mintedTickets.length; i++) {
            if (ownerOf(mintedTickets[i]) == address(this)) {
                _burn(mintedTickets[i]);
            }
        }
        while (mintedTickets.length > 0) {
           mintedTickets.pop(); 
        }     
    }
}
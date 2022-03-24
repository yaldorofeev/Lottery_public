// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


contract Lottery {

    // <ERC20 vars
    string  public name;
    string  public symbol;
    string  public standard = "Be$t_token v1.0";
    uint256 public totalSupply;
    // ERC20 vars>

    address[] private winners;
    uint256 public ticketPrice;  
    address private admin;
    address[] private players;
    uint public startTime;
    uint public limitTimeDay; // in days;
    uint public limitTime;     // in sec;
    uint256 public soldTicketLimit;
    uint256 public ticketSold;  // in units;
    bool public onGame = false; 
    uint256 public episod = 0;

    constructor(string memory _name, string memory _symbol) {
        admin = msg.sender;
        name = _name;
        symbol = _symbol;
    }

    // <ERC20 events and maps
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    // ERC20 events and maps>

    event Sell(address _buyer, uint256 _ticketCount);

    event WeHaveAWinner(address _winner);

    // mapping(address => uint256) public winners;

    function startGame(uint256 _numberOfTickets, uint256 _ticketPrice, uint _limitTimeDay, uint256 _soldTicketLimit) public {
        require(!onGame);
        require(msg.sender == admin);
        episod++;
        ticketPrice = _ticketPrice;
        limitTimeDay = _limitTimeDay;
        totalSupply = _numberOfTickets;
        soldTicketLimit = _soldTicketLimit;
        balanceOf[address(this)] = _numberOfTickets;
        onGame = true;
        startTime = block.timestamp;
        limitTime = startTime + limitTimeDay * 1 minutes;
    }

    function multiply(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function buyTicket(uint256 _numberOfTickets) public payable {
        require(onGame, "There is no actual lottery now.");
        require(msg.value == multiply(_numberOfTickets, ticketPrice), "Not enaught or too much ethers");     
        allowance[address(this)][msg.sender] = _numberOfTickets;
        require(transferFrom(address(this), msg.sender, _numberOfTickets), "transfer failed");
        ticketSold += _numberOfTickets;
        for (uint i = 0; i < _numberOfTickets; i++) {
            players.push(msg.sender);
        }
        emit Sell(msg.sender, _numberOfTickets);
    }

    function letsPlayTheGame() public {
        uint nowTime = block.timestamp;
        require((ticketSold == totalSupply) || ((ticketSold >= soldTicketLimit) && (nowTime >= limitTime)));      
        address winner = players[random(players.length)]; 
        emit WeHaveAWinner(winner);
        winners.push(winner);
        onGame =false;
        burnOldTickets();
        payable(admin).transfer(address(this).balance);
    }

    function stopTheGame() public payable {
        uint nowTime = block.timestamp;
        require((nowTime > limitTime) && (ticketSold < soldTicketLimit));
        for (uint i = 0; i < players.length; i++) {
            payable(players[i]).transfer(ticketPrice);
            // players[i].call.value(ticketPrice).gas("20317");
        }
        burnOldTickets();
        onGame =false;
    }

    function random(uint256 _playersCount) private view returns (uint256) {
        // uint256 sender = uint256(uint160(address(_sender)));
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty)))%(_playersCount-1);
    }

    function burnOldTickets() private {
        balanceOf[msg.sender] = 0;
        totalSupply = 0;
        ticketSold = 0;
        while (players.length != 0) {
            players.pop()
        } 
    }

    function getWinner(uint256 _episod) public view returns (address) {
        require(_episod <= winners.length);
        return winners[_episod - 1];
    }

    // <ERC20 fucnctions
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from], "not enough tickets");
        require(_value <= allowance[_from][msg.sender], "not enough allowance");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);

        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }
    //ERC20 fucnctions>
}
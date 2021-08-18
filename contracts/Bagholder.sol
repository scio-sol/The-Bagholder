// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.6;

contract Bagholder {
    address public immutable dev;
    uint256 devMoney;

    uint96  public timestamp;
    uint256 public bet;
    address kingOfTheHill;

    uint256 public initialBet;
    uint256 public multiplier;
    uint96 public waitTime;

    constructor(uint256 _initialBet, uint256 _multiplier, uint96 _waitTime) {
        require(_initialBet > 0);
        require(_multiplier > 1);
        require(_waitTime > 0);
        
        dev = msg.sender;
        initialBet = _initialBet;
        multiplier = _multiplier;
        waitTime = _waitTime;
    }

    function adjust(uint256 _initialBet, uint256 _multiplier, uint96 _waitTime) public {
        require (msg.sender == dev);
        require (bet == 0 || timestamp < block.timestamp);
        require(_initialBet > 0);
        require(_multiplier > 1);
        require(_waitTime > 0);

        initialBet = _initialBet;
        multiplier = _multiplier;
        waitTime = _waitTime;
    }

    // The initial bet goes fully to the dev, I think...
    function start() payable public {
        require (bet == 0 || timestamp < block.timestamp);
        require (msg.value == initialBet);

        bet = msg.value;
        kingOfTheHill = msg.sender;
        timestamp = uint96(block.timestamp) + waitTime;
    }

    // Extract a fee of 1% and send the rest to the former king.
    function climbUp() payable public {
        require (bet != 0 && timestamp > block.timestamp);
        require (msg.value == bet * multiplier);

        uint256 toPay = msg.value * 99 / 100;
        address payable to = payable(kingOfTheHill);

        bet = msg.value;
        kingOfTheHill = msg.sender;
        timestamp = uint96(block.timestamp) + waitTime;

        to.transfer(toPay);
    }

    // We don't ever need to save money for payouts, because we always
    // pay with what we're paid
    function getDevMoney() payable public {
        require(msg.sender == dev);
        payable(dev).transfer(address(this).balance);
    }
}
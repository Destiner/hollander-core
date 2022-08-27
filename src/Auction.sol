// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./IERC20.sol";

contract Auction {
    address owner;

    uint256 blockStart;

    address tokenBase;
    address tokenQuote;
    uint256 amountBase;
    uint256 initialPrice;
    uint256 halvingPeriod;
    uint256 swapPeriod;

    modifier whenActive() {
        require(blockStart > 0);
        _;
    }

    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }

    constructor(
        address _tokenBase,
        address _tokenQuote,
        uint256 _amountBase,
        uint256 _initialPrice,
        uint256 _halvingPeriod,
        uint256 _swapPeriod
    ) {
        tokenBase = _tokenBase;
        tokenQuote = _tokenQuote;
        amountBase = _amountBase;
        initialPrice = _initialPrice;
        halvingPeriod = _halvingPeriod;
        swapPeriod = _swapPeriod;
    }

    function init() external onlyOwner {
        IERC20(tokenBase).transferFrom(msg.sender, address(this), amountBase);
        blockStart = block.number;
    }
}

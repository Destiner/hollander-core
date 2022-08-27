// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "prb-math/PRBMathUD60x18.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract Auction {
    using PRBMathUD60x18 for uint256;

    address public owner;

    uint256 public blockStart;

    address public tokenBase;
    address public tokenQuote;
    uint256 public amountBase;
    uint256 public initialPrice;
    uint256 public halvingPeriod;
    uint256 public swapPeriod;

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

    function getPrice(uint256 amountIn) public view returns(uint256 amountOut) {
        uint256 boughtAmount = amountBase - IERC20(tokenBase).balanceOf(address(this)) - amountIn;
        uint256 exponent =
          (block.number - (boughtAmount / amountBase) * swapPeriod) /
          halvingPeriod;
        amountOut = initialPrice / exponent.exp2();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./Auction.sol";

contract Factory {
    function createAuction(
        address tokenBase,
        address tokenQuote,
        uint256 amountBase,
        uint256 initialPrice,
        uint256 halvingPeriod,
        uint256 swapPeriod
    )
        external
        returns (address auction)
    {
        require(tokenBase != tokenQuote);
        auction =
            address(new Auction(msg.sender, tokenBase, tokenQuote, amountBase, initialPrice, halvingPeriod, swapPeriod));
    }
}

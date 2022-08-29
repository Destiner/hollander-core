// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./Auction.sol";

contract Factory {
    event NewAuction(
        address auction,
        address indexed owner,
        address indexed tokenBase,
        address indexed tokenQuote,
        uint256 amountBase,
        uint256 initialPrice,
        uint256 halvingPeriod,
        uint256 swapPeriod
    );

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
        emit NewAuction(
            address(auction), msg.sender, tokenBase, tokenQuote, amountBase, initialPrice, halvingPeriod, swapPeriod
            );
    }
}

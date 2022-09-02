// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "prb-math/PRBMathSD59x18.sol";

// OZ's ERC20 with custom decimals and capped supply
contract ERC20X is ERC20 {
    uint8 storedDecimals;

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _supply) ERC20(_name, _symbol) {
        storedDecimals = _decimals;
        super._mint(msg.sender, _supply);
    }

    function decimals() public view override returns (uint8) {
        return storedDecimals;
    }
}

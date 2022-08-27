// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

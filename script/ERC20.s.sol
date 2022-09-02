// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/ERC20X.sol";

contract MyScript is Script {
    function run() external {
        vm.startBroadcast();

        ERC20X dai = new ERC20X("Dai Stablecoin", "DAI", 18, 100000 ether);
        ERC20X usdc = new ERC20X("USD Coin", "USDC", 6, 200000000000);
        ERC20X mkr = new ERC20X("Maker", "MKR", 18, 70 ether);
        ERC20X uni = new ERC20X("Uniswap", "UNI", 18, 7000 ether);
        ERC20X bal = new ERC20X("Balancer", "BAL", 18, 5000 ether);
        ERC20X weth = new ERC20X("Wrapped Ether", "WETH", 18, 50 ether);

        vm.stopBroadcast();
    }
}

pragma solidity 0.8.13;

import "forge-std/Test.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import "../src/Factory.sol";

contract AuctionTest is Test {
    address alice = 0xaAaAaAaaAaAaAaaAaAAAAAAAAaaaAaAaAaaAaaAa;

    function testCreation() public {
        uint256 AMOUNT = 100 ether;
        uint256 PRICE = 3000 ether;
        uint256 HALVING_PERIOD = 1000;
        uint256 SWAP_PERIOD = 2000;

        IERC20 baseToken = new ERC20('Wrapper Ether', 'WETH');
        IERC20 quoteToken = new ERC20('USD Coin', 'USDC');
        Factory factory = new Factory();
        vm.prank(alice);
        Auction auction = Auction(
            factory.createAuction(address(baseToken), address(quoteToken), AMOUNT, PRICE, HALVING_PERIOD, SWAP_PERIOD)
        );

        assertEq(auction.owner(), alice);
        assertEq(auction.tokenBase(), address(baseToken));
        assertEq(auction.tokenQuote(), address(quoteToken));
        assertEq(auction.amountBase(), AMOUNT);
        assertEq(auction.initialPrice(), PRICE);
        assertEq(auction.halvingPeriod(), HALVING_PERIOD);
        assertEq(auction.swapPeriod(), SWAP_PERIOD);
    }
}
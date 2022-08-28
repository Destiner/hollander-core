pragma solidity 0.8.13;

import "forge-std/Test.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import "../src/Auction.sol";
import "../src/Factory.sol";

contract AuctionTest is Test {
    event Init(uint256 blockStart);
    event Swap(address indexed buyer, uint256 amountBuy, uint256 amountSell);
    event Withdraw(uint256 amount);

    error AlreadyStarted();
    error Unauthorized();

    Auction auction;
    IERC20 baseToken;
    IERC20 quoteToken;

    address alice = 0xaAaAaAaaAaAaAaaAaAAAAAAAAaaaAaAaAaaAaaAa;
    address bob = 0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB;
    address carol = 0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC;
    address dave = 0xDDdDddDdDdddDDddDDddDDDDdDdDDdDDdDDDDDDd;

    function setUp() public {
        uint256 AMOUNT = 100 ether;
        uint256 PRICE = 3000 ether;
        uint256 HALVING_PERIOD = 1000;
        uint256 SWAP_PERIOD = 2000;

        baseToken = new ERC20('Wrapper Ether', 'WETH');
        quoteToken = new ERC20('USD Coin', 'USDC');
        Factory factory = new Factory();
        vm.prank(alice);
        auction = Auction(
            factory.createAuction(address(baseToken), address(quoteToken), AMOUNT, PRICE, HALVING_PERIOD, SWAP_PERIOD)
        );

        deal(address(baseToken), alice, AMOUNT);
        deal(address(baseToken), bob, AMOUNT);
        deal(address(quoteToken), bob, 60000 ether);
        deal(address(quoteToken), carol, 80000 ether);
        deal(address(quoteToken), dave, 20000 ether);

        vm.expectEmit(true, true, true, true);
        emit Init(block.number);

        vm.startPrank(bob);
        baseToken.approve(address(auction), AMOUNT);
        vm.expectRevert(Unauthorized.selector);
        auction.init();
        vm.stopPrank();

        vm.startPrank(alice);
        baseToken.approve(address(auction), AMOUNT);
        auction.init();
        vm.stopPrank();

        vm.startPrank(alice);
        vm.expectRevert(AlreadyStarted.selector);
        auction.init();
        vm.stopPrank();
    }

    function testInitialBalance() public {
        assertEq(baseToken.balanceOf(address(auction)), 100 ether);
        assertEq(quoteToken.balanceOf(address(auction)), 0);
    }

    function testPriceAmountImpact() public {
        assertEq(auction.getPrice(0), 3000 ether);
        vm.roll(block.number + 1000);
        assertEq(auction.getPrice(0), 3000 ether / 2);
        vm.roll(block.number + 1000);
        assertEq(auction.getPrice(0), 3000 ether / 4);
        vm.roll(block.number + 1000);
        assertEq(auction.getPrice(0), 3000 ether / 8);
    }

    function testPriceTimeImpact() public {
        assertEq(auction.getPrice(0), 3000 ether);
        assertEq(auction.getPrice(2 ether), 3084341479968199529696);
        assertEq(auction.getPrice(5 ether), 3215320387608879492574);
        assertEq(auction.getPrice(10 ether), 3446095064991105020935);
        assertEq(auction.getPrice(30 ether), 4547149699531194251776);
    }

    function testPriceTimeAmountImpact() public {
        vm.roll(block.number + 1000);
        assertEq(auction.getPrice(2 ether), 1542170739984099764055);
        vm.roll(block.number + 1000);
        assertEq(auction.getPrice(32 ether), 1168746869490749788699);
        vm.roll(block.number + 1000);
        assertEq(auction.getPrice(92 ether), 1342537606391958643527);
        vm.roll(block.number + 200);
        assertEq(auction.getPrice(100 ether), 1305825844944186209043);
    }

    function testBuy() public {
        vm.prank(bob);
        quoteToken.approve(address(auction), (2 ** 256) - 1);
        vm.prank(carol);
        quoteToken.approve(address(auction), (2 ** 256) - 1);
        vm.prank(dave);
        quoteToken.approve(address(auction), (2 ** 256) - 1);

        buy(bob, block.number + 800, 2 ether, 3542977984288591199678);
        buy(bob, block.number + 250, 5 ether, 7982776368400199161110);
        buy(carol, block.number + 150, 4 ether, 6083756878740174834652);
        buy(carol, block.number + 250, 9 ether, 13040140440485414943756);
        buy(bob, block.number + 250, 15 ether, 22500 ether);
        buy(dave, block.number + 200, 11 ether, 16730331416535480795293);
        buy(bob, block.number + 340, 15 ether, 22190235851100581394570);
        buy(carol, block.number + 540, 25 ether, 35972404474697414645650);
        buy(carol, block.number + 210, 12 ether, 17629565356564683684060);
        buy(dave, block.number + 60, 2 ether, 2897808986774536654168);
    }

    function testWithdraw() public {
        vm.prank(bob);
        quoteToken.approve(address(auction), (2 ** 256) - 1);
        vm.prank(carol);
        quoteToken.approve(address(auction), (2 ** 256) - 1);
        vm.prank(dave);
        quoteToken.approve(address(auction), (2 ** 256) - 1);

        uint256 sellAmountBob = 24148974395964370357370;
        buy(bob, 3000, 38 ether, sellAmountBob);
        vm.expectEmit(true, true, true, true);
        emit Withdraw(sellAmountBob);

        vm.prank(alice);
        uint256 amountA = auction.withdraw();
        assertEq(amountA, sellAmountBob);

        uint256 sellAmountCarol = 63549932620958869374950;
        buy(carol, 3000, 50 ether, sellAmountCarol);
        uint256 sellAmountDave = 18012480974326451393280;
        buy(dave, 3000, 12 ether, sellAmountDave);
        vm.expectEmit(true, true, true, true);
        emit Withdraw(sellAmountCarol + sellAmountDave);

        vm.prank(alice);
        uint256 amountB = auction.withdraw();
        assertEq(amountB, sellAmountCarol + sellAmountDave);

        vm.startPrank(bob);
        vm.expectRevert(Unauthorized.selector);
        auction.withdraw();
        vm.stopPrank();

        assertEq(baseToken.balanceOf(address(auction)), 0);
        assertEq(quoteToken.balanceOf(address(auction)), 0);
        assertEq(baseToken.balanceOf(alice), 0);
        assertEq(quoteToken.balanceOf(alice), sellAmountBob + sellAmountCarol + sellAmountDave);
    }

    function buy(address buyer, uint256 buyBlock, uint256 buyAmount, uint256 expectedSellAmount) internal {
        vm.roll(buyBlock);
        uint256 auctionBaseBalance = baseToken.balanceOf(address(auction));
        uint256 auctionQuoteBalance = quoteToken.balanceOf(address(auction));
        uint256 buyerBaseBalance = baseToken.balanceOf(buyer);
        uint256 buyerQuoteBalance = quoteToken.balanceOf(buyer);

        vm.expectEmit(true, true, true, true);
        emit Swap(buyer, buyAmount, expectedSellAmount);

        vm.prank(buyer);
        uint256 sellAmount = auction.buy(buyAmount);
        assertEq(sellAmount, expectedSellAmount);
        assertEq(baseToken.balanceOf(address(auction)), auctionBaseBalance - buyAmount);
        assertEq(quoteToken.balanceOf(address(auction)), auctionQuoteBalance + sellAmount);
        assertEq(baseToken.balanceOf(buyer), buyerBaseBalance + buyAmount);
        assertEq(quoteToken.balanceOf(buyer), buyerQuoteBalance - sellAmount);
    }
}

# Hollander

![Heading](docs/hero.png)

## Introduction

The repository contains smart contract code for Hollander. Hollander is a contract that allows anyone to create ducth auctions for a pair of ERC20 contracts.

**Status**: the protocol code is complete, has full test coverage, and deployed on Goerli testnet; additionally, subgraph was created and deployed; the UI was created and deployed as well (see "Related repositories").

## Problem

It is frustrating to make large swap orders via DEXs. First, any large order creates significant price impact due to the lack of liquidity. Also, large orders are more vulnerable to sandwich attacks. Traders usually have to split the order into multiple small ones and set near 0 slippage tolerance (which increases the chances of tx being failed). Aggregators alleviate some of that, but they are inherently centralized and sometimes even pocket the positive slippage.

## Previous work

There are some projects trying to solve similar or related problems:

* Peg Stability Module (PSM): a contract to swap stablecoins at 1:1 rate. The major drawback is lack of free-floating price support
* Prime Deals: a platform to execute OTC DAO to DAO deals at the predefined price. Unfortunetely, conducting swaps at the predefined price is not efficient (not equivalent to market price) and open for market manipulation.
* MakerDao Liquidation module: a simple dutch auction implementation for collateral liquidations. The scope is limited to MakerDAO liquidations; also, partial buys are not possible.

## Solution

Hollander solves that via dutch auctions. Any trader can create an custom auction tailored to their needs. The auction will require a single transaction instead of creating multiple smaller trades. It will guarantee near market price execution and lowest price impact possible via economical incentives (no token incentives needed). Order can be fullfilled all at once or partially, and is completely public for all traders. The possibility of sandwich attacks is also eliminated.

## MEV relevance

Hollander utilizes MEV in two ways:

1. Mitigating bad MEV (sandwiching) via mechanism design
2. Taking advantadge of searcher network to do helpful work for the user (selling tokens at near market price)

## Use cases

For the hackathon, I choose to focus on whale token swaps. There are, however, other potential uses of the system.

First, it is possible to use Hollander for trustless . Currently, they are done either using predetermined price based on historical market rates (which is not efficient and open for price manipulation) or . Hollander can do treasure swaps both trustlessly and at market price.

Second, we can use Hollander for protocol liquiditations. By selling the underwater collater via dutch auction, we are guaranteed to receive the best price while reducing reliance on centralized oracles.

Finally, token buybacks (e.g. https://yearn.clinic) can also be conducted via Hollander, eliminating the dependency on oracles.

## Mechanism design

The auction swaps token `A` to token `B`. The auction starts at the given price. As the time goes, the price will decrease. The decrease is exponential — the price will halve in `X` amount of time, then halve again in `X` amount of time, and so forth. Eventually, the current spot price will reach the market price, which will create an arbitrage opportunity. Anyone can sell any amount of tokens (within limit) to this auction, but the price will increase based on the amount sold. Small amount of tokens will increase the price slightly, but the large amount of token increases the price significantly.

### Parameters

Each auction is initialized witha set of problems:

- `tokenBase`: token to be sold via auction by creator
- `tokenQuote`: token to be bought via auction
- `amountBase`: amount of token to be sold
- `initialPrice`: starting spot price
- `halvingPeriod`: amount of blocks for price to halve
- `swapPeriod`: target amount of blocks for auction to be held

## Related repositories

- Smart contracts: https://github.com/Destiner/hollander-app
- Subgraph: https://github.com/Destiner/hollander-subgraph

## Deployed contracts

- Goerli: 0x26704df470f36A45592EcC07E9CAcC7aB795A094 ([etherscan](https://goerli.etherscan.io/address/0x26704df470f36A45592EcC07E9CAcC7aB795A094))

## Further work

There are many interesting ways for Hollander to improve

1. **UX**: offer sensible defaults when creating an auction, show historical price chart
2. **Broader usage**: as noted in "Use cases", explore
3. **Mechanism design**: explore other dutch auction designs (e.g. VRGDA, linear price decay)
4. **Advanced**: toppable auctions (allow to add more liquidity to auction over time), mutual/pooled auctions (allow anyone to add liquidity to a single auction)
5. **Gas optimizations**: use single contract to store all auctions, use router to reduce number of token approvals required
6. **Backstop mechanisms**: allow auction creator to define backstop rules (e.g. max auction duration, min selling price)

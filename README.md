# Idle Finance & Cream Finance DAI Strategy

## Solution

I have used Idle finance interface `ILendingProtocol` to starture for strategy.

Where strategy consumes a `DAI` token and internall it will call `mint` of creamDAI and buy Cream Dai Stablecoin token.

## IdleCurve Strategy Code and test case:

`Strategy:` You can find code in `contracts/wrappers/IdleCreamDAI.sol` path.  
[Clieck here to go strategy code](https://github.com/sunnyRK/idleCreamDai-strategy/blob/master/contracts/wrappers/IdleCreamDAI.sol)


`Test-case:` You can find test case in `test/idleCreamDai.js` path.  
[Click here to go test cases](https://github.com/sunnyRK/idleCreamDai-strategy/blob/master/test/idleCreamDai.js)  

## Run

`Download code`
1). Clone repo

`Install dependency`
2). yarn

`to run on mainnet fork`  
3). npx hardhat test --network hardhat

## Contact

[Twitter](https://twitter.com/RadadiyaSunny)  
`Discord: sunny#3937` 





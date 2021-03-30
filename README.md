# Idle Finance & BarnBridge Tranche Strategy

## Solution

I have used Idle finance interface `ILendingProtocol` to starture for strategy.

Where strategy consumes a `USDC` token and internall it will call `buyTokens` of BarnBridge and buy BarnBridge cUSDC token.

Strategy will get `Senior Tranche APY` from BarnBridge. There are two types of tranches in `BarnBridge like Senior and Junior Tranches`.

`Senior tanches is fixed rate` pool and there is no risk user will get fixed rate on top of their bond.

`Junior Tranches are at higher risk.` It is not fixed rate it is variable rate. It can get a more apy then senior tranche but if price get vrash of token then it could get lower apy then senior.

## IdleBarnBridge Strategy Code and test case:

`Strategy:` You can find code in `contracts/wrappers/IBarnBridge.sol` path.  
[Clieck here to go strategy code](https://github.com/sunnyRK/Tranches-GR9/blob/master/contracts/wrappers/IdleBarnBridge.sol)


`Test-case:` You can find test case in `test/IdleBarnBridge-test.js` path.  
[Click here to go test cases](https://github.com/sunnyRK/Tranches-GR9/blob/master/test/idleBarnBridge-test.js)  

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





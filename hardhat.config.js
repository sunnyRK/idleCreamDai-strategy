/**
 * @type import('hardhat/config').HardhatUserConfig
 */
require("@nomiclabs/hardhat-waffle");

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.5.16"
      },
      {
        version: "0.6.12"
      },
    ]
  },

  networks: {
    hardhat: {
      forking: {
        url: "https://eth-mainnet.alchemyapi.io/v2/EuD-FVgI2gMBGf0aypDghsPHYWHB9nhn",
        // blockNumber: 11966746,
        timeout: 300000
      }
    },

    // Mainnet
    mainnet: {
      url: 'https://mainnet.infura.io/v3/37bd907f93a146679960d54e729cd51a',
      chainId: 1,
      accounts: {
        mnemonic: 'blood depth speak upper carpet rich nation tooth coil cousin jealous antique',
        path: 'm/44\'/60\'/0\'/0',
        initialIndex: 1,
        count: 10,
      },
      gas: 'auto',
      gasPrice: 73000000000, // 1 gwei
      gasMultiplier: 1.5,
      timeout: 300000
    },
  },

  mocha: {
    timeout: 300000
  }
};

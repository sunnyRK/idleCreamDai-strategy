
const { expect } = require("chai");
const { BigNumber, Wallet } = require("ethers");
const { formatEther, parseEther } =require('@ethersproject/units')
const daiAbi = require('../abis/daiAbi.json');
const crDaiAbi = require('../abis/crDaiAbi.json');
const { ethers } = require("hardhat");

// Mainnet Fork and test case for mainnet with hardhat network by impersonate account from mainnet
describe("deployed Contract on Mainnet fork", function() {
  it("hardhat_impersonateAccount and transfer balance to our account", async function() {
    const accounts = await ethers.getSigners();
    
    // Mainnet addresses
    const accountToImpersonate = '0x1759f4f92af1100105e405fca66abba49d5f924e'
    const daiAddress = '0x6B175474E89094C44Da98b954EedeAC495271d0F'
    const creamDAIContractAddress = '0x92B767185fB3B04F881e3aC8e5B0662a027A1D9f'
    await hre.network.provider.request({
        method: "hardhat_impersonateAccount",
        params: [accountToImpersonate]}
    )
    let signer = await ethers.provider.getSigner(accountToImpersonate)
    let daiContract = new ethers.Contract(daiAddress, daiAbi, signer)
    await daiContract.transfer(accounts[0].address, daiContract.balanceOf(accountToImpersonate))
    signer = await ethers.provider.getSigner(accounts[0].address)
    daiContract = new ethers.Contract(daiAddress, daiAbi, signer)
  });

  it("Initialize IDle and CreamDAI startergy", async function() {
    const accounts = await ethers.getSigners();
    const accountToImpersonate = '0x1759f4f92af1100105e405fca66abba49d5f924e'
    const daiAddress = '0x6B175474E89094C44Da98b954EedeAC495271d0F'
    const creamDAIContractAddress = '0x92B767185fB3B04F881e3aC8e5B0662a027A1D9f'
    await hre.network.provider.request({
        method: "hardhat_impersonateAccount",
        params: [accountToImpersonate]}
    )
    let signer = await ethers.provider.getSigner(accountToImpersonate)
    let daiContract = new ethers.Contract(daiAddress, daiAbi, signer)
    await daiContract.transfer(accounts[0].address, daiContract.balanceOf(accountToImpersonate))
    signer = await ethers.provider.getSigner(accounts[0].address)
    daiContract = new ethers.Contract(daiAddress, daiAbi, signer)
    const IdleCreamDAI = await ethers.getContractFactory('IdleCreamDAI', signer);
    const IdleCreamDAI_Instance = await IdleCreamDAI.deploy();
    let creamDaiContract = new ethers.Contract(creamDAIContractAddress, crDaiAbi, signer)
    await IdleCreamDAI_Instance.initialize(
        creamDaiContract.address, 
        accounts[0].address
    )
  });

  it("Mint from CreamDAI through idle startergy", async function() {
    const accounts = await ethers.getSigners();

    const accountToImpersonate = '0x1759f4f92af1100105e405fca66abba49d5f924e'
    const daiAddress = '0x6B175474E89094C44Da98b954EedeAC495271d0F'
    const creamDAIContractAddress = '0x92B767185fB3B04F881e3aC8e5B0662a027A1D9f'

    await hre.network.provider.request({
        method: "hardhat_impersonateAccount",
        params: [accountToImpersonate]}
    )

    let signer = await ethers.provider.getSigner(accountToImpersonate)
    let daiContract = new ethers.Contract(daiAddress, daiAbi, signer)
    await daiContract.transfer(accounts[0].address, daiContract.balanceOf(accountToImpersonate))
    signer = await ethers.provider.getSigner(accounts[0].address)
    daiContract = new ethers.Contract(daiAddress, daiAbi, signer)
    const IdleCreamDAI = await ethers.getContractFactory('IdleCreamDAI', signer);
    const IdleCreamDAI_Instance = await IdleCreamDAI.deploy();
    let creamDaiContract = new ethers.Contract(creamDAIContractAddress, crDaiAbi, signer)
    await IdleCreamDAI_Instance.initialize(
        creamDaiContract.address, 
        accounts[0].address
    )
    await daiContract.approve(creamDaiContract.address, '1000000000000000000000000000000000')
    await daiContract.transfer(IdleCreamDAI_Instance.address, '1000000000000000000')

    const bal0 = await creamDaiContract.balanceOf(accounts[0].address);
    console.log('balanceOf0 crDai before mint: ', bal0.toString());
    await IdleCreamDAI_Instance.mint() //// Mint Tokens or BuyTokens
    const bal1 = await creamDaiContract.balanceOf(accounts[0].address);
    console.log('balanceOf1 crDai after mint: ', bal1.toString());
  });

  it("Mint and Redeem from CreamDAI through idle startergy", async function() {
    const accounts = await ethers.getSigners();
    const accountToImpersonate = '0x1759f4f92af1100105e405fca66abba49d5f924e'
    const daiAddress = '0x6B175474E89094C44Da98b954EedeAC495271d0F'
    const creamDAIContractAddress = '0x92B767185fB3B04F881e3aC8e5B0662a027A1D9f'
    await hre.network.provider.request({
        method: "hardhat_impersonateAccount",
        params: [accountToImpersonate]}
    )
    let signer = await ethers.provider.getSigner(accountToImpersonate)
    let daiContract = new ethers.Contract(daiAddress, daiAbi, signer)
    await daiContract.transfer(accounts[0].address, daiContract.balanceOf(accountToImpersonate))
    signer = await ethers.provider.getSigner(accounts[0].address)
    daiContract = new ethers.Contract(daiAddress, daiAbi, signer)
    const IdleCreamDAI = await ethers.getContractFactory('IdleCreamDAI', signer);
    const IdleCreamDAI_Instance = await IdleCreamDAI.deploy();
    let creamDaiContract = new ethers.Contract(creamDAIContractAddress, crDaiAbi, signer)
    await IdleCreamDAI_Instance.initialize(
        creamDaiContract.address, 
        accounts[0].address
    )
    await daiContract.approve(creamDaiContract.address, '1000000000000000000000000000000000')
    await daiContract.transfer(IdleCreamDAI_Instance.address, '10000000')
    await IdleCreamDAI_Instance.mint() //// Mint Tokens or BuyTokens from CreamDAI
    const balance = await creamDaiContract.balanceOf(accounts[0].address)
    await creamDaiContract.transfer(IdleCreamDAI_Instance.address, balance)
    await IdleCreamDAI_Instance.redeem(IdleCreamDAI_Instance.address) //// Idle Redeem or SellTokens from BarnBeidge 
  });

  
  it("Get NextSupplyRate", async function() {
    const accounts = await ethers.getSigners();
    const accountToImpersonate = '0x1759f4f92af1100105e405fca66abba49d5f924e'
    const daiAddress = '0x6B175474E89094C44Da98b954EedeAC495271d0F'
    const creamDAIContractAddress = '0x92B767185fB3B04F881e3aC8e5B0662a027A1D9f'
    await hre.network.provider.request({
        method: "hardhat_impersonateAccount",
        params: [accountToImpersonate]}
    )
    let signer = await ethers.provider.getSigner(accountToImpersonate)
    let daiContract = new ethers.Contract(daiAddress, daiAbi, signer)
    await daiContract.transfer(accounts[0].address, daiContract.balanceOf(accountToImpersonate))
    signer = await ethers.provider.getSigner(accounts[0].address)
    daiContract = new ethers.Contract(daiAddress, daiAbi, signer)
    const IdleCreamDAI = await ethers.getContractFactory('IdleCreamDAI', signer);
    const IdleCreamDAI_Instance = await IdleCreamDAI.deploy();
    let creamDaiContract = new ethers.Contract(creamDAIContractAddress, crDaiAbi, signer)

    await IdleCreamDAI_Instance.initialize(
        creamDaiContract.address,
        accounts[0].address
    )

    const rate = await IdleCreamDAI_Instance.nextSupplyRate('0') //// Idle Redeem or SellTokens from BarnBeidge 
    console.log('rate: ', rate.toString());
  });

  
  // it("This test case will print all state", async function() {
  //   const accounts = await ethers.getSigners();

  //   const accountToImpersonate = '0x1759f4f92af1100105e405fca66abba49d5f924e'
  //   const daiAddress = '0x6B175474E89094C44Da98b954EedeAC495271d0F'
  //   const creamDAIContractAddress = '0x92B767185fB3B04F881e3aC8e5B0662a027A1D9f'

  //   await hre.network.provider.request({
  //       method: "hardhat_impersonateAccount",
  //       params: [accountToImpersonate]}
  //   )

  //   let signer = await ethers.provider.getSigner(accountToImpersonate)
  //   let daiContract = new ethers.Contract(daiAddress, daiAbi, signer)

  //   await daiContract.transfer(accounts[0].address, daiContract.balanceOf(accountToImpersonate))

  //   signer = await ethers.provider.getSigner(accounts[0].address)
  //   daiContract = new ethers.Contract(daiAddress, daiAbi, signer)
    
  //   const IdleCreamDAI = await ethers.getContractFactory('IdleCreamDAI', signer);
  //   const IdleCreamDAI_Instance = await IdleCreamDAI.deploy();
  //   console.log('IdleCreamDAI_Instance: ', IdleCreamDAI_Instance.address);

  //   const rate = await IdleCreamDAI_Instance.nextSupplyRate('0') //// Idle Redeem or SellTokens from BarnBeidge 
  //   console.log('rate: ', rate.toString());

  //   let creamDaiContract = new ethers.Contract(creamDAIContractAddress, crDaiAbi, signer)
  //   console.log('creamDaiContract.address: ', creamDaiContract.address)

  //   const maxBondDailyRate = await creamDaiContract.callStatic.maxBondDailyRate()
  //   console.log('maxBondDailyRate: ', maxBondDailyRate.toString())

  //   await IdleCreamDAI_Instance.initialize(
  //       creamDaiContract.address, 
  //       accounts[0].address
  //   )

  //   await daiContract.approve(creamDaiContract.address, '1000000000000000000000000000000000')
  //   await daiContract.transfer(IdleCreamDAI_Instance.address, '10000000')

  //   const bal4 = await daiContract.balanceOf(IdleCreamDAI_Instance.address)
  //   console.log('IdleCreamDAI_Instance.address-bal4: ', bal4.toString())

  //   const bal5 = await creamDaiContract.balanceOf(IdleCreamDAI_Instance.address)
  //   console.log('creamDaiContract.address-bal5: ', bal5.toString())

  //   await IdleCreamDAI_Instance.mint() //// Mint Tokens or BuyTokens from CreamDAI
    
  //   const bal6 = await daiContract.balanceOf(IdleCreamDAI_Instance.address)
  //   console.log('IdleCreamDAI_Instance.address-bal6: ', bal6.toString())

  //   const bal61 = await creamDaiContract.balanceOf(accounts[0].address)
  //   console.log('creamDaiContract.address-bal61: ', bal61.toString())

  //   await creamDaiContract.transfer(IdleCreamDAI_Instance.address, bal61)

  //   const bal7 = await creamDaiContract.balanceOf(IdleCreamDAI_Instance.address)
  //   console.log('creamDaiContract.address-bal7: ', bal7.toString())

  //   await IdleCreamDAI_Instance.redeem(IdleCreamDAI_Instance.address) //// Idle Redeem or SellTokens from BarnBeidge 

  //   const bal8 = await daiContract.balanceOf(IdleCreamDAI_Instance.address)
  //   console.log('IdleCreamDAI_Instance.address-bal8: ', bal8.toString())
    
  //   const bal9 = await creamDaiContract.balanceOf(IdleCreamDAI_Instance.address)
  //   console.log('creamDaiContract.address-bal9: ', bal9.toString())

  // });
})
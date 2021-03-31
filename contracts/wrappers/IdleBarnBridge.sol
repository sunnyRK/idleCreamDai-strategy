/**
 * @title: Idle BarnBridge wrapper
 * @summary: Used for interacting with BarnBridge. Has
 *           a common interface with all other protocol wrappers.
 *           This contract holds assets only during a tx, after tx it should be empty
 * @author: Idle Labs Inc., idle.finance
 */
pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "../interfaces/ILendingProtocol.sol";
import "hardhat/console.sol";

interface IBarnBridge {
    function buyTokens(uint256 underlyingAmount_, uint256 minTokens_, uint256 deadline_) external;
    function sellTokens(uint256 tokens_, uint256 minUnderlying_, uint256 deadline_) external;
    function maxBondDailyRate() external returns (uint256);
    function price() external returns (uint256);
    function EXP_SCALE() external view returns (uint);
    function abondDebt() external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function pool() external view returns (uint256);
}

interface IController2 {
  function FEE_BUY_JUNIOR_TOKEN() external view returns (uint);
}

interface ICompoundProvider {
  function uToken() external view returns (uint256);
}

interface ICErc20 {
  function exchangeRateStored() external view returns (uint);
}

contract IdleBarnBridge is ILendingProtocol, Ownable {
  using SafeERC20 for IERC20;
  using SafeMath for uint256;

  // protocol token (BarnBridge junior cUSDC) address
  address public token; // BarnBridger SmartYield:  0x4B8d90D68F26DEF303Dcb6CFc9b63A1aAEC15840

  // underlying token (token eg USDC) address
  address public underlying;
  address public idleToken;
  bool public initialized;

  address public controller = 0x41Ab25709e0C3EDf027F6099963fE9AD3EBaB3A3; // BarnBridge Controller
  address public compoundProvider = 0xDAA037F99d168b552c0c61B7Fb64cF7819D78310; // BarnBridge CompoundProvider
  address public cErc20 = 0x39AA39c021dfbaE8faC545936693aC917d5E7563; // cToken

  /**
   * @param _token : BarnBridge junior cUSDC address
   * @param _idleToken : idleToken address
   */
  function initialize(address _token, address _idleToken) public {
    require(!initialized, "Already initialized");
    require(_token != address(0), 'cUSDC: addr is 0');

    token = _token;
    underlying = address(ICompoundProvider(IBarnBridge(_token).pool()).uToken());
    idleToken = _idleToken;
    IERC20(underlying).safeApprove(compoundProvider, 0);
    IERC20(underlying).safeApprove(compoundProvider, uint256(-1));
    initialized = true;
  }

  /**
   * Throws if called by any account other than IdleToken contract.
   */
  modifier onlyIdle() {
    require(msg.sender == idleToken, "Ownable: caller is not IdleToken");
    _;
  }
  
  function nextSupplyRateWithParams(uint256[] calldata)
    external view
    returns (uint256) {
      // return ICErc20(cErc20).exchangeRateStored();
      return 0;
  }

  /**
   * Calculate next supply rate for cUSDC, given an `_amount` supplied
   *
   * @param _amount : new underlying amount supplied (eg USDC)
   * @return : yearly net rate
   */
  function nextSupplyRate(uint256 _amount)
    external view
    returns (uint256) {
      // return ICErc20(cErc20).exchangeRateStored();
      return 0;
  }

  /**
   * @return current price of cUSDC BarnBridge in underlying, BarnBridge cUSDC price is always 1
   */
  function getPriceInToken()
    external view
    returns (uint256) {
      // return 10**6;
      return ICErc20(cErc20).exchangeRateStored();
  }

  /**
   * @return apr : current yearly net rate
   */
  function getAPR()
    external view
    returns (uint256) {
      return 0;
      // return ICErc20(cErc20).exchangeRateStored();
  }

  /**
   * Gets all underlying tokens in this contract and mints barnBridgeJuniorCusdc Tokens
   * tokens are then transferred to msg.sender
   * NOTE: underlying tokens needs to be sent here before calling this
   * NOTE2: given that barnBridgeJuniorCusdc price is always 1 token -> underlying.balanceOf(this) == token.balanceOf(this)
   *
   * @return barnBridgeJuniorCusdc Tokens minted
   */
  function mint()
    external 
    onlyIdle
    returns (uint256 barnBridgeJuniorCusdc) {
      uint256 balance = IERC20(underlying).balanceOf(address(this));
      if (balance == 0) {
        return barnBridgeJuniorCusdc;
      }

      uint256 minTokens_ = _mintMinUnderlying(balance);

      IBarnBridge(token).buyTokens(
        balance, 
        minTokens_, 
        block.timestamp.add(3600)
      );  // BarnBridge external function call to stake

      barnBridgeJuniorCusdc = IERC20(token).balanceOf(address(this));
      IERC20(token).safeTransfer(msg.sender, barnBridgeJuniorCusdc);
  }

  // It will call when mint() function call to calculate mint amount
  // BarnBridge Calculation from SmartYield contract
  function _mintMinUnderlying(uint256 underlyingAmount_) internal returns(uint256 getsTokens) {
    uint256 fee =  underlyingAmount_.mul(IController2(controller).FEE_BUY_JUNIOR_TOKEN()).div(IBarnBridge(token).EXP_SCALE());
    getsTokens = (underlyingAmount_.sub(fee)).mul(IBarnBridge(token).EXP_SCALE()).div(IBarnBridge(token).price());
  }

  /**
   * Gets all barnBridgeJuniorCusdc in this contract and redeems underlying tokens.
   * underlying tokens are then transferred to `_account`
   * NOTE: barnBridgeJuniorCusdc needs to be sent here before calling this
   *
   * @return underlying tokens redeemd
   */
  function redeem(address _account)
    external 
    onlyIdle
    returns (uint256 tokens) {
    uint256 minUnderlying_ = _redeemMinUnderlying(IERC20(token).balanceOf(address(this)));

    IBarnBridge(token).sellTokens(
      IERC20(token).balanceOf(address(this)), 
      minUnderlying_, 
      block.timestamp.add(3600)
    ); // BarnBridge external function call to redeem

    IERC20 _underlying = IERC20(underlying);
    tokens = _underlying.balanceOf(address(this));
    _underlying.safeTransfer(_account, tokens);
  }

  // It will call when redeem() function call to calculate redeem undelying amount
  // BarnBridge Calculation from SmartYield contract
  function _redeemMinUnderlying(uint256 tokenAmount_) internal returns(uint256 toPay) {
    // share of these tokens in the debt
    uint256 debtShare = tokenAmount_.mul(IBarnBridge(token).EXP_SCALE()).div(IBarnBridge(token).totalSupply());
    uint256 forfeits = IBarnBridge(token).abondDebt().mul(debtShare).div(IBarnBridge(token).EXP_SCALE());
    // debt share is forfeit, and only diff is returned to user
    toPay = tokenAmount_.mul(IBarnBridge(token).price()).div(IBarnBridge(token).EXP_SCALE()).sub(forfeits);
  }

  /**
   * Get the underlying balance on the lending protocol
   *
   * @return underlying tokens available
   */
  function availableLiquidity() external view returns (uint256) {
    return IERC20(underlying).balanceOf(token);
  }
}

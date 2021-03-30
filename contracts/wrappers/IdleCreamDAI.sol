/**
 * @title: Cream DAI wrapper
 * @summary: Used for interacting with Cream Finance. Has
 *           a common interface with all other protocol wrappers.
 *           This contract holds assets only during a tx, after tx it should be empty
 * @author: Idle Labs Inc., idle.finance
 */
pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "../interfaces/ILendingProtocol.sol";

interface ICreamDAI {
  function mint(uint mintAmount) external returns (uint);
  function redeem(uint redeemTokens) external returns (uint);
  function redeemUnderlying(uint redeemAmount) external returns (uint);
  function borrow(uint borrowAmount) external returns (uint);
  function repayBorrow(uint repayAmount) external returns (uint);
  function repayBorrowBehalf(address borrower, uint repayAmount) external returns (uint);
  function getCash() external view returns (uint);
  function reserveFactorMantissa() external view returns (uint);
  function totalBorrows() external view returns (uint);
  function totalReserves() external view returns (uint);
  function underlying() external view returns (uint);
}

interface ICreamJumpRateModelV2 {
  function getBorrowRate(uint cash, uint borrows, uint reserves) external view returns (uint);
  function getSupplyRate(uint cash, uint borrows, uint reserves, uint reserveFactorMantissa) external view returns (uint);
  function utilizationRate(uint cash, uint borrows, uint reserves) external pure returns (uint);
}

contract IdleCreamDAI is ILendingProtocol, Ownable {
  using SafeERC20 for IERC20;
  using SafeMath for uint256;

  // protocol token (crDAI) address
  address public token;
  // underlying token (token eg DAI) address
  address public underlying;
  address public idleToken;
  bool public initialized;

  /**
   * @param _token : crDAI address
   * @param _idleToken : idleToken address
   */
  function initialize(address _token, address _idleToken) public {
    require(!initialized, "Already initialized");
    require(_token != address(0), 'crDAI: addr is 0');

    token = _token;
    underlying = address(ICreamDAI(_token).underlying());
    idleToken = _idleToken;
    IERC20(underlying).safeApprove(_token, uint256(-1));
    initialized = true;
  }

  /**
   * Throws if called by any account other than IdleToken contract.
   */
  modifier onlyIdle() {
    require(msg.sender == idleToken, "Ownable: caller is not IdleToken");
    _;
  }
  
  function nextSupplyRateWithParams(uint256[] memory params)
    public view
    returns (uint256) {     
      uint oneMinusReserveFactor = uint(1e18).sub(params[3]);
      uint borrowRate = ICreamJumpRateModelV2(0x014872728e7D8b1c6781f96ecFbd262Ea4D2e1A6).getBorrowRate(params[0], params[1], params[2]);
      uint rateToPool = borrowRate.mul(oneMinusReserveFactor).div(1e18);
      uint ratePerBlock = ICreamJumpRateModelV2(0x014872728e7D8b1c6781f96ecFbd262Ea4D2e1A6).utilizationRate(params[0], params[1], params[2]).mul(rateToPool).div(1e18);
      uint totalApy = ratePerBlock.div(1e8).mul(2102400).mul(100);
      return totalApy;
  }

  /**
   * Calculate next supply rate for crDAI, given an `_amount` supplied
   *
   * @param _amount : new underlying amount supplied (eg DAI)
   * @return : yearly net rate
   */
  function nextSupplyRate(uint256 _amount)
    external view
    returns (uint256) {
      uint256 cash = ICreamDAI(token).getCash();
      uint256 totalBorrows = ICreamDAI(token).totalBorrows();
      uint256 totalReserves = ICreamDAI(token).totalReserves().add(_amount);
      uint256 reserveFactorMantissa = ICreamDAI(token).reserveFactorMantissa();
      uint256[] memory _params = new uint256[](4);
      _params[0] = cash;
      _params[1] = totalBorrows;
      _params[2] = totalReserves;
      _params[3] = reserveFactorMantissa;
      return nextSupplyRateWithParams(_params);
  }

  /**
   * @return current price of Cream DAI in underlying, crDAI price is always 1
   */
  function getPriceInToken()
    external view
    returns (uint256) {
      return 10**18;
  }

  /**
   * @return apr : current yearly net rate
   */
  function getAPR()
    external view
    returns (uint256) {
        // return nextSupplyRate(0);
        return 0;
  }

  /**
   * Gets all underlying tokens in this contract and mints crDAI Tokens
   * tokens are then transferred to msg.sender
   * NOTE: underlying tokens needs to be sent here before calling this
   * NOTE2: given that crDAI price is always 1 token -> underlying.balanceOf(this) == token.balanceOf(this)
   *
   * @return crDAI Tokens minted
   */
  function mint()
    external onlyIdle
    returns (uint256 crDAITokens) {
      uint256 balance = IERC20(underlying).balanceOf(address(this));
      if (balance == 0) {
        return crDAITokens;
      }
      ICreamDAI(token).mint(balance);
      crDAITokens = IERC20(token).balanceOf(address(this));
      IERC20(token).safeTransfer(msg.sender, crDAITokens); 
  }

  /**
   * Gets all crDAI in this contract and redeems underlying tokens.
   * underlying tokens are then transferred to `_account`
   * NOTE: crDAI needs to be sent here before calling this
   *
   * @return underlying tokens redeemd
   */
  function redeem(address _account)
    external onlyIdle
    returns (uint256 tokens) {
    ICreamDAI(token).redeem(IERC20(token).balanceOf(address(this)));
    IERC20 _underlying = IERC20(underlying);
    tokens = _underlying.balanceOf(address(this));
    _underlying.safeTransfer(_account, tokens);
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

pragma solidity 0.5.16;

// interfaces
import "../interfaces/AaveLendingPoolCore.sol";

contract aaveLendingPoolCoreMock is AaveLendingPoolCore {
  address public reserve;
  uint256 public liquidity;
  uint256 public borrowsStable;
  uint256 public borrowsVariable;
  uint256 public stableBorrowRate;
  uint256 public apr;

  function getReserveInterestRateStrategyAddress(address) external view returns (address) {
    return reserve;
  }
  function _setReserve(address _reserve) external {
    reserve = _reserve;
  }

  function getReserveAvailableLiquidity(address) external view returns (uint256) {
    return liquidity;
  }
  function setReserveAvailableLiquidity(uint256 _newVal) external {
    liquidity = _newVal;
  }

  function getReserveTotalBorrowsStable(address) external view returns (uint256) {
    return borrowsStable;
  }
  function setReserveTotalBorrowsStable(uint256 _newVal) external {
    borrowsStable = _newVal;
  }

  function getReserveTotalBorrowsVariable(address) external view returns (uint256) {
    return borrowsVariable;
  }
  function setReserveTotalBorrowsVariable(uint256 _newVal) external {
    borrowsVariable = _newVal;
  }

  function getReserveCurrentAverageStableBorrowRate(address) external view returns (uint256) {
    return stableBorrowRate;
  }
  function setReserveCurrentAverageStableBorrowRate(uint256 _newVal) external {
    stableBorrowRate = _newVal;
  }

  function getReserveCurrentLiquidityRate(address) external view returns (uint256 liquidityRate) {
    return apr;
  }
  function setReserveCurrentLiquidityRate(uint256 _newVal) external {
    apr = _newVal;
  }
}

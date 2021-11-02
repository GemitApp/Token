/**
  GEMIT maintenance wallet lock.

  Lock number of tokens for specific time and allow to payout the reflection about the defined limit.

  Author telegram: @wojpski
 */

pragma solidity ^0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


contract GemitTimedThresholdLock is Ownable {
    using SafeERC20 for IERC20;
 
     // ERC20 basic token contract being held
    IERC20 private immutable _token;
 
    // timestamp when token release is enabled
    uint256 private _releaseTime;
    
    // decimal value for contract
    uint256 private _decimal;
    
    // amount locked (all reflection above it can be payout anytime)
    uint256 private _lockThreshold;
 
     constructor(
        IERC20 token_,
        uint256 lockThreshold_,
        uint256 decimal_,
        uint256 releaseTime_
    ) {
        require(releaseTime_ > block.timestamp, "Lock: release time is before current time");
        _token = token_;
        _decimal = decimal_;
        _lockThreshold = lockThreshold_ * 10**_decimal;
        _releaseTime = releaseTime_;
    }
 
    function renounceOwnership() public override onlyOwner {
        
    }
 
     /**
     * @return the token being held.
     */
    function token() public view returns (IERC20) {
        return _token;
    }

    /**
     * @return the time when the tokens are released.
     */
    function releaseTime() public view returns (uint256) {
        return _releaseTime;
    }
    
    /**
     * @return is contract locked currently
     */
    function isCurrentlyLocked() public view returns (bool) {
        return block.timestamp < _releaseTime;
    }
    
    /**
     * @return the locked threshold
     */
    function currentLockThreshold() public view returns (uint256) {
        return _lockThreshold / 10**_decimal;
    }
    
    /**
     * @return available balance above threshold
     */
    function currentAvailableBalanceAboveThreshold() public view returns (uint256) {
        return (_token.balanceOf(address(this)) - _lockThreshold) / 10**_decimal;
    }
 
    /**
     * @notice update lock time when previous ended
     */
    function updateLockTime(uint256 newReleaseTime) public onlyOwner{
        require(block.timestamp >= _releaseTime, "Lock: cannot update lock time while locked");
        require(newReleaseTime > block.timestamp, "Lock: new release time is before current time");

        _releaseTime = newReleaseTime;
    }
    
    /**
     * @notice update the threshold value when not in lock state
     */
    function modifyThreshold(uint256 newThreshold) public onlyOwner{
        require(block.timestamp >= _releaseTime, "Lock: cannot modify threshold while locked");

        _lockThreshold = newThreshold * 10**_decimal;
    }
 
     /**
     * @notice get tokens from reflection above declared threshold
     */
    function getTokensAboveThreshold(uint256 tokenAmount) public onlyOwner {
        uint256 amountWithDecimal = tokenAmount * 10**_decimal;
        
        require(_token.balanceOf(address(this)) - amountWithDecimal >= _lockThreshold, "Lock: required amount is above available limit");
        
        _token.transfer(owner(), amountWithDecimal);
    }
 
     /**
     * @notice transfers tokens held by timelock to contract owner.
     */
    function release() public onlyOwner {
        require(block.timestamp >= releaseTime(), "Lock: current time is before release time");

        uint256 amount = token().balanceOf(address(this));
        require(amount > 0, "Lock: no tokens to release");

        token().safeTransfer(owner(), amount);
    }
 
     /**
     * @notice recover any IERC20 token from contract address
     */
    function recoverIERC20(address tokenAddress, uint256 tokenAmount) public onlyOwner {
        require(tokenAddress != address(_token), "Lock: Cannot recover locked token with this method");
        
        IERC20(tokenAddress).safeTransfer(owner(), tokenAmount);
    }

     /**
     * @notice recover BNB from contract balance
     */
    function extractBNB() public onlyOwner {
        address payable _owner = payable(_msgSender());
        _owner.transfer(address(this).balance);
    }   
}
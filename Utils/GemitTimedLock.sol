/**
  GEMIT lp from auto liquify operation lock.

  Create lock contract to lock LP sended to the GEMIT owner

  Author telegram: @wojpski
 */

pragma solidity ^0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract GemitTimedLock is Ownable {
    using SafeERC20 for IERC20;
 
     // ERC20 basic token contract being held
    IERC20 private immutable _token;
 
    // timestamp when token release is enabled
    uint256 private _releaseTime;
    
     constructor(
        IERC20 token_,
        uint256 releaseTime_
    ) {
        require(releaseTime_ > block.timestamp, "Lock: release time is before current time");
        _token = token_;
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
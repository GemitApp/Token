# Gemit.app

The GEMIT.app token was created to work along with gemit.app.
  
Website: [gemit.app]("https://www.gemit.app")  
Twitter: [@gemit_app]("https://twitter.com/Gemit_app")  
Telegram: [@gemit_chat]("https://t.me/gemit_chat")

Author telegram: `@wojpski`

## Purpose

Contract was used to generate gemit tokens which will be consumed by gemit.app application.

Gemit holders by holding some tokens will be able to access more features.

## Technical details

Contract probably as many others was designed and written by rewerse engineering of the existing SafeMoon contracts + custom implementation for AntiWhale system

### Tokenomics

Supply: **100 000 000**    
    
  Taxations:
  - **4%** from each transaction to redistribution
  - **5%** from each transaction sent to liquidity
  
  Token security (Whale protection):
  - **3%** max supply in one Address
  - **1%** max supply in one transaction

  Init contract blockades:
  - **6%** max supply as init maintenance budget 
  - **2%** max supply as init marketing budget
  - **2%** max supply as init aidrop budget
  - **2%** max supply as dev team wallet

**Maintenace wallet** it exists only because during development I was unable to design stable tax for maintenance (Also I believe that having static tax for that purpose makes you to use it less wisely). Because of that I calculated that reflection from 6% should be enough to cover all project maintenance needs and it will be locked with additional custom time lock contract (Available in "Utils" folder)

### Changes to 1st contract version

Add option to retrieve token send directly to the contract

```
    function recoverERC20(address tokenAddress, uint256 tokenAmount) public virtual onlyOwner {
        IERC20(tokenAddress).transfer(owner(), tokenAmount);
    }
```

Add option to retrieve BNB directly send directly to the contract (*Fix for situation when during presale BNB was send directly to the contract instead of presale address*)

```
    function extractBNB() external onlyOwner {
        address payable _owner = payable(_msgSender());
        _owner.transfer(address(this).balance);
    }
```

Functions to cover presale TX / AntiWhale (*Finally it was handled by added DxSale router to the "Excluded From Tax list"*)

```
    function prepareForPreSale() external onlyOwner {
        setSwapAndLiquifyEnabled(false);
        _taxFee = 0;
        _liquidityFee = 0;
    }

    function afterPreSale() external onlyOwner {
        setSwapAndLiquifyEnabled(true);
        _taxFee = 4;
        _liquidityFee = 5;
        setMaxTxPercent(1); 
        setMaxWalletTokenPercent(3);
    }
```

Functions to cover antiwhale system:

```
    function excludeAddressWhaleFrom(address account, bool _exclude) public onlyOwner {
        _antiWhaleExcludedFromAddress[account] = _exclude;
    }

    function excludeAddressWhaleTo(address account, bool _exclude) public onlyOwner {
        _antiWhaleExcludedToAddress[account] = _exclude;
    }

    function isExcludedFromAntiWhaleFrom(address account) public view returns (bool) {
        return _antiWhaleExcludedFromAddress[account];
    }

    function isExcludedFromAntiWhaleTo(address account) public view returns (bool) {
        return _antiWhaleExcludedToAddress[account];
    }

    function setMaxWalletTokenPercent(uint256 maxWalletTokenPercent) public onlyOwner() {
        _maxWalletToken = _tTotal.mul(maxWalletTokenPercent).div(
            10**2
        );
    }
```

## Media

You can find official project assets like logo in assets folder

## Utils

Utils folder contains side contracts / materials / libraries created during working on gemit.app token area

- `GemitTimedLock` - Implementation of timed locked + additional functions to retrieve BNB and other tokens from contract

- `GemitTimedThresholdLock` - Implementation of timed locked with custom logic allows to access reflection above treshold and withdraw it from contract to the owner wallet


## Known issues

- **NEVER USE "includeInReward"** - test shows (on test network) that this function is bugged and after call it instantly modify the existing balances to calculate reward for included address

- **AntiWhale** - Anti whale is not working as expected and it's not preventing anything. Finally it's only allows to keep balanced holders distribution

- **LP from liquify** - This LP is send directly to the contract owner. All LP should be locked and for that purpose it will be locked with custom contract (Available in "Utils" folder)


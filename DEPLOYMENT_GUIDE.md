# JPEGSwap NFT Swap DApp - Deployment Guide

## 🏗️ Architecture Overview

The JPEGSwap dApp consists of 4 main contracts that work cohesively together:

### 1. **StakeReceipt.sol** - Receipt NFT Contract
- **Purpose**: Issues non-transferable receipt NFTs for staked tokens
- **Key Features**:
  - Mints unique receipt tokens when NFTs are staked
  - Maps receipt tokens to original NFT token IDs
  - Non-transferable (except mint/burn)
  - Validation functions for security

### 2. **SwapPool.sol** - Core Swap & Staking Pool
- **Purpose**: Main contract for NFT swapping and staking with rewards
- **Key Features**:
  - NFT swapping with fees
  - Staking with reward distribution
  - Pool token tracking
  - Batch operations for gas efficiency
  - Auto-claim rewards on unstaking
  - Upgradeable (UUPS proxy pattern)

### 3. **StonerFeePool.sol** - Fee Collection Pool
- **Purpose**: Collects and distributes fees from swap operations
- **Key Features**:
  - Separate staking pool for fee distribution
  - Reward calculation and distribution
  - Batch unstaking
  - Auto-claim on unstake
  - Upgradeable (UUPS proxy pattern)

### 4. **SwapPoolFactory.sol** - Pool Factory & Management
- **Purpose**: Creates and manages multiple swap pools
- **Key Features**:
  - Creates new swap pools for different NFT collections
  - Batch reward claiming across pools
  - Pool validation and tracking
  - Admin functions for pool management

## 📋 Pre-Deployment Checklist

### ✅ Contract Fixes Applied
- [x] Added SPDX license identifier to SwapPool.sol
- [x] Replaced deprecated `block.difficulty` with `block.prevrandao`
- [x] Fixed StakeReceipt interface to match SwapPool expectations
- [x] Updated StonerFeePool interface for consistency
- [x] All compilation errors resolved

### ✅ Security Features
- [x] ReentrancyGuard on all external functions
- [x] Access control (onlyOwner, onlyPool modifiers)
- [x] Input validation and error handling
- [x] Emergency functions for admin control
- [x] Pausable functionality

## 🚀 Deployment Steps

### 1. Deploy StakeReceipt Contract (First)
```solidity
constructor(string memory name_, string memory symbol_)
```
**Example:**
```
Name: "JPEGSwap Stake Receipt"
Symbol: "JSR"
```

### 2. Deploy SwapPool Implementation (Second)
```solidity
// Deploy the implementation contract (not proxy)
// This will be used by the factory to create pools
```

### 3. Deploy StonerFeePool Implementation (Third)
```solidity
// Deploy the implementation contract
// This will be used as the fee collection pool
```

### 4. Deploy SwapPoolFactory (Fourth)
```solidity
constructor(address _implementation)
```
**Parameters:**
- `_implementation`: Address of the deployed SwapPool implementation

### 5. Initialize Contracts

#### A. Set Pool Address in StakeReceipt
```solidity
stakeReceipt.setPool(swapPoolAddress)
```

#### B. Create Swap Pool via Factory
```solidity
factory.createPool(
    nftCollection,     // NFT collection address
    receiptContract,   // StakeReceipt contract address
    stonerPool,        // StonerFeePool address
    swapFeeInWei,      // Fee amount (e.g., 0.01 ETH = 10000000000000000)
    stonerShare        // Percentage to stoner pool (0-100)
)
```

#### C. Initialize StonerFeePool
```solidity
stonerFeePool.initialize(
    stonerNFTAddress,  // Address of NFT collection for stoner pool
    receiptContract    // StakeReceipt contract address
)
```

## 🔧 Configuration Parameters

### Recommended Settings

| Parameter | Recommended Value | Description |
|-----------|------------------|-------------|
| `swapFeeInWei` | 10000000000000000 (0.01 ETH) | Swap fee amount |
| `stonerShare` | 20 | 20% of fees go to stoner pool |
| Gas Limits | See below | For batch operations |

### Gas Limit Recommendations
- Single swap: ~200,000 gas
- Single stake/unstake: ~150,000 gas
- Batch operations: 21,000 + (150,000 × num_items)
- Factory batch claims: Depends on number of pools

## 🎯 Usage Flow

### For Users:
1. **Swap NFTs**: Pay fee → Get different NFT from pool
2. **Stake NFTs**: Lock NFT → Get receipt token → Earn rewards from swap fees
3. **Unstake NFTs**: Burn receipt → Get original NFT back (or random if swapped) + auto-claim rewards
4. **Claim Rewards**: Get ETH rewards from accumulated swap fees

### For Admins:
1. **Create Pools**: Use factory to create pools for new NFT collections
2. **Manage Fees**: Adjust swap fees and stoner share percentages
3. **Emergency Functions**: Pause, emergency withdrawals, etc.
4. **Monitor**: Track pool statistics and user activity

## 🔐 Security Considerations

### Multi-Signature Recommendations
- Use multi-sig wallet for factory owner
- Use multi-sig for individual pool owners
- Consider timelock for critical parameter changes

### Monitoring
- Monitor large batch operations for gas usage
- Watch for unusual reward claim patterns
- Track pool token balances vs. staked amounts

### Emergency Procedures
- All contracts have pause functionality
- Emergency withdrawal functions for admins
- Receipt validation prevents cross-pool exploits

## 📊 Post-Deployment Verification

### Test Checklist
- [ ] Swap NFT functionality
- [ ] Stake/unstake with receipt tokens
- [ ] Reward distribution and claiming
- [ ] Batch operations
- [ ] Factory pool creation
- [ ] Emergency functions
- [ ] Fee distribution between pools

### Integration Tests
- [ ] Multi-pool reward claiming
- [ ] Cross-contract interactions
- [ ] Receipt token validation
- [ ] Pool token tracking accuracy

## 🎨 Frontend Integration

### Key Contract Functions to Integrate

#### SwapPool
- `swapNFT(tokenIdIn, tokenIdOut)`
- `stakeNFT(tokenId)`
- `unstakeNFT(receiptTokenId)`
- `claimRewards()`
- `getPoolInfo()`
- `getUserActiveStakeDetails(user)`

#### Factory
- `createPool(...)`
- `batchClaimRewards(pools[])`
- `getUserPendingRewards(user)`
- `getAllPools()`

### Events to Listen For
- `SwapExecuted`
- `Staked` / `Unstaked`
- `RewardsClaimed`
- `PoolCreated`
- `BatchRewardsClaimed`

## 🌐 Network Deployment

### Sonic Network Specific
- All contracts include `registerMe()` for Sonic FeeM integration
- Uses FeeM registration address: `0xDC2B0D2Dd2b7759D97D50db4eabDC36973110830`
- Parameter value: `92`

### Gas Optimization
- Batch operations reduce per-transaction costs
- Auto-claim on unstake eliminates separate claim transactions
- Efficient pool token tracking

## 🚨 Important Notes

1. **Deployment Order Matters**: Deploy in the exact order specified
2. **Interface Compatibility**: All interfaces have been fixed and verified
3. **Upgrade Safety**: Contracts use UUPS proxy pattern for safe upgrades
4. **Receipt Tokens**: Are non-transferable by design for security
5. **Random Selection**: Uses `block.prevrandao` for fair token selection

The contracts are now ready for deployment with all critical issues resolved and interfaces properly aligned for cohesive operation.

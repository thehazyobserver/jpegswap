# Scalability Solutions for NFT Swap Ecosystem

## Issues Identified

### 1. SwapPoolFactory's Unbounded allPools Array
**Problem**: `claimAllRewards` could fail with 100+ pools due to gas limits (~50k gas per call)
**Current Risk**: Contract becomes unusable as ecosystem grows

**Solutions**:

#### A. Implement Pagination for Batch Operations
```solidity
function claimAllRewardsPaginated(uint256 startIndex, uint256 batchSize) external returns (uint256 totalClaimed)
function getAllPoolsPaginated(uint256 startIndex, uint256 batchSize) external view returns (address[] memory)
```

#### B. User-Specific Pool Tracking
```solidity
mapping(address => address[]) userActivePools;
mapping(address => mapping(address => bool)) isUserActiveInPool;
```

#### C. Lazy Cleanup Strategy
```solidity
mapping(address => bool) inactivePools; // Mark pools as inactive instead of removing
uint256 activePoolCount; // Track active pools separately
```

### 2. StonerFeePool's O(n) Array Operations
**Problem**: `_removeFromArray` operations are O(n) with ~10k gas for large stakes
**Current Risk**: Unstaking becomes expensive with many stakers

**Solutions**:

#### A. Replace Arrays with Mappings + EnumerableSet
```solidity
using EnumerableSet for EnumerableSet.AddressSet;
EnumerableSet.AddressSet private stakers;
mapping(address => uint256) public stakes;
```

#### B. Swap-and-Pop Pattern for Removals
```solidity
function _removeFromArray(address[] storage array, address element) private {
    for (uint256 i = 0; i < array.length; i++) {
        if (array[i] == element) {
            array[i] = array[array.length - 1];
            array.pop();
            break;
        }
    }
}
```

## Implementation Priority

### Phase 1: Critical Gas Optimizations
1. Fix StonerFeePool array operations (highest impact)
2. Add pagination to SwapPoolFactory batch operations
3. Implement gas estimation functions

### Phase 2: Advanced Optimizations
1. User-specific pool tracking
2. Lazy cleanup strategies
3. Enhanced analytics with efficient data structures

### Phase 3: Future-Proofing
1. Implement pool archiving system
2. Add governance for gas limit parameters
3. Consider Layer 2 deployment strategies

## Gas Optimization Estimates

### Before Optimizations
- `claimAllRewards` (100 pools): ~5M gas (will fail)
- `unstakeNFT` (1000 stakers): ~10k gas per operation
- Array operations: O(n) complexity

### After Optimizations
- `claimAllRewardsPaginated` (20 pools): ~1M gas (safe)
- `unstakeNFT` (any number stakers): ~5k gas per operation
- Set operations: O(1) complexity

## APY Calculation Redesign

### Current Approach Issues
- Traditional APY doesn't apply to NFT staking (no initial investment cost)
- Percentage returns are misleading without a cost basis

### New Approach: ETH Earnings Focus
```solidity
struct StakingMetrics {
    uint256 totalETHEarned;           // Total ETH earned from staking
    uint256 dailyETHRate;             // Current daily ETH earning rate
    uint256 projectedMonthlyETH;      // Projected monthly earnings
    uint256 stakingDuration;          // Days since first stake
    uint256 averageDailyReturn;       // Average ETH per day historically
}
```

This approach provides meaningful metrics:
- Actual ETH earned (concrete value)
- Earning rates (actionable information)
- Projections based on current activity
- No misleading percentage calculations

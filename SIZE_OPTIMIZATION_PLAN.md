# StonerFeePool Size Optimization Strategy

## Contract Size Issue
- Current: 24,956 bytes
- Limit: 24,576 bytes 
- Excess: 380 bytes (needs reduction)

## Optimization Approach

### Phase 1: Remove Large Frontend Functions (Target: 2000+ bytes)
1. **getPoolHealth()** - Remove verbose health metrics
2. **getRecommendedActions()** - Remove complex recommendation engine
3. **getStakingInterfaceData()** - Remove detailed interface data
4. **getBatchOperationData()** - Remove batch operation analysis
5. **getPoolStatistics()** - Remove complex analytics
6. **getUserDashboard()** - Simplify to essential data only

### Phase 2: Optimize String Messages (Target: 500+ bytes)
1. Shorten error messages
2. Remove verbose event descriptions
3. Optimize function comments

### Phase 3: Code Structure (Target: 200+ bytes)
1. Combine similar functions
2. Use libraries for complex calculations
3. Optimize variable names

## Essential Functions to Keep
- Core staking: stake(), unstake(), claimRewards()
- Basic views: getStakedTokens(), earned()
- Essential pool data: getPoolInfo()
- Safety functions: pause controls, emergency functions

## Total Target Reduction: 2,700+ bytes
This should bring contract well under the 24,576 byte limit.

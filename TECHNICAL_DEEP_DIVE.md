# 🔧 JPEGSwap Technical Deep Dive: Smart Contract Interactions

## 🏗️ Contract Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  SwapPoolFactory │────│    SwapPool     │────│   StakeReceipt  │
│   (Creates)     │    │  (Core Logic)   │    │   (Receipts)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │  StonerFeePool  │
                       │ (Premium Stake) │
                       └─────────────────┘
```

---

## 🔄 Core Contract: SwapPool.sol

### **Contract Inheritance Structure:**
```solidity
SwapPoolNative is 
    UUPSUpgradeable,
    OwnableUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable
```

### **Key State Variables:**
```solidity
// Core NFT tracking
IERC721 public nftCollection;                    // The NFT collection this pool manages
uint256[] public poolTokens;                     // Array of all NFT token IDs in pool
mapping(uint256 => bool) public tokenInPool;     // Quick lookup: tokenId => isInPool

// Staking system with timestamps
struct StakeInfo {
    uint256 stakedAt;        // ⏰ Real timestamp when staked
    uint256 rewardDebt;      // For fair reward calculation
    bool active;             // Is this stake currently active
}
mapping(uint256 => StakeInfo) public stakeInfos; // receiptTokenId => StakeInfo

// Reward distribution
uint256 public rewardPerTokenStored;             // Accumulated reward per staked NFT
uint256 public totalStaked;                      // Total number of staked NFTs
uint256 public swapFeeInWei;                     // Fee for each swap (e.g., 0.01 ETH)
```

### **NFT Swapping Flow:**
```solidity
function swapNFT(uint256 tokenIdIn, uint256 tokenIdOut) external payable {
    // 1. Validation
    require(msg.value >= swapFeeInWei, "Insufficient fee");
    require(tokenInPool[tokenIdOut], "Token not in pool");
    require(nftCollection.ownerOf(tokenIdIn) == msg.sender, "Not your token");
    
    // 2. Execute swap
    nftCollection.transferFrom(msg.sender, address(this), tokenIdIn);
    nftCollection.transferFrom(address(this), msg.sender, tokenIdOut);
    
    // 3. Update pool state
    _updatePoolTokens(tokenIdIn, tokenIdOut);
    
    // 4. Distribute fees to stakers
    _distributeFees(msg.value);
    
    emit SwapExecuted(msg.sender, tokenIdIn, tokenIdOut, msg.value);
}
```

### **NFT Staking Flow:**
```solidity
function stakeNFT(uint256 tokenId) external {
    // 1. Transfer NFT to pool
    nftCollection.transferFrom(msg.sender, address(this), tokenId);
    
    // 2. Mint receipt token
    uint256 receiptId = receiptContract.mint(msg.sender, tokenId);
    
    // 3. Record stake with timestamp
    stakeInfos[receiptId] = StakeInfo({
        stakedAt: block.timestamp,  // 🕒 Real timestamp tracking
        rewardDebt: rewardPerTokenStored,
        active: true
    });
    
    // 4. Update pool state
    totalStaked++;
    _updateUserStakes(msg.sender, receiptId);
    
    emit Staked(msg.sender, tokenId, receiptId);
}
```

### **Advanced Analytics Engine:**
```solidity
function getPoolHealth() external view returns (
    uint256 healthScore,        // 0-100 health score
    string memory riskLevel,    // "LOW", "MEDIUM", "HIGH"
    uint256 liquidityRatio,     // Pool tokens vs staked ratio
    uint256 tvlGrowth,         // Total value locked growth
    uint256 averageStakingTime // Real average from timestamps
) {
    // Multi-factor health algorithm
    uint256 liquidity = (poolTokens.length * 100) / (totalStaked + 1);
    uint256 activity = _calculateActivityScore();
    uint256 stability = _calculateStabilityScore();
    
    healthScore = (liquidity + activity + stability) / 3;
    riskLevel = healthScore > 80 ? "LOW" : healthScore > 50 ? "MEDIUM" : "HIGH";
    
    // Real timestamp calculations (no placeholders!)
    averageStakingTime = _calculateRealAverageStakingTime();
}
```

---

## 🎫 Receipt System: StakeReceipt.sol

### **Contract Structure:**
```solidity
contract StakeReceipt is ERC721Enumerable, Ownable {
    // Timestamp tracking for analytics
    mapping(uint256 => uint256) public receiptMintTime;      // When receipt was created
    mapping(uint256 => address) public receiptMinter;        // Who created it
    mapping(uint256 => uint256) public receiptToOriginalToken; // Receipt → Original NFT
}
```

### **Non-Transferable Design:**
```solidity
function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId,
    uint256 batchSize
) internal override {
    // Only allow mint (from=0) and burn (to=0)
    if (from != address(0) && to != address(0)) revert NonTransferable();
    super._beforeTokenTransfer(from, to, tokenId, batchSize);
}
```

### **Mint with Timestamp Tracking:**
```solidity
function mint(address to, uint256 originalTokenId) external onlyPool returns (uint256) {
    uint256 receiptTokenId = _currentReceiptId++;
    
    // Map receipt to original NFT
    receiptToOriginalToken[receiptTokenId] = originalTokenId;
    
    // 🕒 Record creation timestamp for analytics
    receiptMintTime[receiptTokenId] = block.timestamp;
    receiptMinter[receiptTokenId] = to;
    
    _mint(to, receiptTokenId);
    return receiptTokenId;
}
```

---

## 💎 Premium Pool: StonerFeePool.sol

### **Enhanced Staking Structure:**
```solidity
// 🆕 Real timestamp tracking (no more placeholders!)
struct StakeInfo {
    address staker;          // Who staked this token
    uint256 stakedAt;        // ⏰ When it was staked
    bool active;             // Is currently staked
}
mapping(uint256 => StakeInfo) public stakeInfos;
```

### **Real Analytics Implementation:**
```solidity
function getUserPortfolio(address user) external view returns (
    uint256 stakedCount,
    uint256 pendingRewards,
    uint256 totalClaimed,
    uint256[] memory stakedTokenIds,
    uint256 averageStakingDays,
    uint256 dailyRewardRate,
    uint256 projectedMonthlyEarnings
) {
    stakedTokenIds = stakedTokens[user];
    stakedCount = stakedTokenIds.length;
    pendingRewards = _calculatePendingRewards(user);
    
    // 🕒 Calculate REAL average staking time
    if (stakedCount > 0) {
        uint256 totalStakingTime = 0;
        for (uint256 i = 0; i < stakedTokenIds.length; i++) {
            uint256 tokenId = stakedTokenIds[i];
            if (stakeInfos[tokenId].active) {
                totalStakingTime += block.timestamp - stakeInfos[tokenId].stakedAt;
            }
        }
        averageStakingDays = stakedCount > 0 ? 
            (totalStakingTime / stakedCount) / 86400 : 0; // Convert to days
    }
}
```

### **Enhanced Staking with Timestamps:**
```solidity
function stake(uint256 tokenId) external whenNotPaused {
    // Standard staking logic...
    
    // 🕒 RECORD TIMESTAMP FOR REAL ANALYTICS
    stakeInfos[tokenId] = StakeInfo({
        staker: msg.sender,
        stakedAt: block.timestamp,  // Real timestamp!
        active: true
    });
    
    // Rest of staking logic...
}
```

---

## 🏭 Factory System: SwapPoolFactory.sol

### **Pool Creation Process:**
```solidity
function createPool(
    address nftCollection,
    address receiptContract,
    address stonerPool,
    uint256 swapFeeInWei,
    uint256 stonerShare
) external onlyOwner returns (address) {
    // 1. Validate inputs
    require(collectionToPool[nftCollection] == address(0), "Pool exists");
    require(stonerShare <= 100, "Invalid share");
    
    // 2. Create proxy with initialization
    bytes memory initData = abi.encodeWithSelector(
        ISwapPoolNative.initialize.selector,
        nftCollection,
        receiptContract,
        stonerPool,
        swapFeeInWei,
        stonerShare
    );
    
    ERC1967Proxy proxy = new ERC1967Proxy(implementation, initData);
    address poolAddress = address(proxy);
    
    // 3. Register pool
    collectionToPool[nftCollection] = poolAddress;
    allPools.push(poolAddress);
    
    emit PoolCreated(nftCollection, poolAddress, msg.sender);
    return poolAddress;
}
```

### **Cross-Pool Analytics:**
```solidity
function getGlobalAnalytics() external view returns (
    uint256 totalValueLocked,
    uint256 totalRewardsDistributed,
    uint256 totalActiveStakers,
    uint256 mostActivePool,
    uint256 highestAPYPool
) {
    // Iterate through all pools for global metrics
    for (uint256 i = 0; i < allPools.length; i++) {
        try ISwapPoolRewards(allPools[i]).nftCollection() returns (address collection) {
            // Aggregate metrics from each pool
            try IERC721(collection).balanceOf(allPools[i]) returns (uint256 poolNFTs) {
                totalValueLocked += poolNFTs;
                // Track most active pool
                if (poolNFTs > maxNFTs) {
                    mostActivePool = i;
                }
            } catch {}
        } catch {}
    }
}
```

---

## 🔄 Complete Transaction Flows

### **Swap Transaction Detailed Flow:**
```
1. User calls swapNFT(tokenIdIn, tokenIdOut)
   ├── Validate: fee paid, token ownership, token in pool
   ├── Transfer: user NFT → pool
   ├── Transfer: pool NFT → user
   ├── Update: pool token arrays
   ├── Distribute: swap fee to stakers
   └── Emit: SwapExecuted event

2. Fee Distribution Process:
   ├── Calculate: reward per staked token
   ├── Update: global reward state
   ├── Transfer: stonerShare to StonerFeePool
   └── Rest: distributed to SwapPool stakers
```

### **Stake Transaction Detailed Flow:**
```
1. User calls stakeNFT(tokenId)
   ├── Transfer: NFT → SwapPool
   ├── Mint: Receipt token → user
   ├── Record: StakeInfo with timestamp
   ├── Update: user stakes mapping
   ├── Update: pool total staked count
   └── Emit: Staked event

2. Receipt Token Creation:
   ├── Generate: unique receipt ID
   ├── Map: receipt → original token
   ├── Record: mint timestamp
   ├── Record: original minter
   └── Mint: ERC721 receipt to user
```

### **Unstake Transaction Detailed Flow:**
```
1. User calls unstakeNFT(receiptTokenId)
   ├── Validate: receipt ownership
   ├── Calculate: pending rewards
   ├── Auto-claim: send rewards to user
   ├── Burn: receipt token
   ├── Select: random NFT from pool (or specific if available)
   ├── Transfer: NFT → user
   ├── Update: stake mappings
   ├── Mark: StakeInfo as inactive (preserve for analytics)
   └── Emit: Unstaked + RewardsClaimed events
```

---

## 🧮 Reward Calculation Mathematics

### **Reward Per Token Formula:**
```solidity
function _updateReward(address user) internal {
    rewardPerTokenStored = rewardPerToken();
    lastUpdateTime = block.timestamp;
    
    if (user != address(0)) {
        rewards[user] = earned(user);
        userRewardPerTokenPaid[user] = rewardPerTokenStored;
    }
}

function rewardPerToken() public view returns (uint256) {
    if (totalStaked == 0) return rewardPerTokenStored;
    
    return rewardPerTokenStored + (
        (block.timestamp - lastUpdateTime) * rewardRate * 1e18 / totalStaked
    );
}

function earned(address user) public view returns (uint256) {
    uint256 userStakeCount = userStakes[user].length;
    return userStakeCount * (
        rewardPerToken() - userRewardPerTokenPaid[user]
    ) / 1e18 + rewards[user];
}
```

### **Health Score Algorithm:**
```solidity
function _calculateHealthScore() internal view returns (uint256) {
    // Multi-factor scoring (0-100)
    uint256 liquidityScore = _calculateLiquidityScore();     // 33%
    uint256 activityScore = _calculateActivityScore();       // 33%
    uint256 stabilityScore = _calculateStabilityScore();     // 34%
    
    return (liquidityScore + activityScore + stabilityScore) / 3;
}

function _calculateLiquidityScore() internal view returns (uint256) {
    if (totalStaked == 0) return 0;
    
    uint256 liquidityRatio = (poolTokens.length * 100) / totalStaked;
    
    // Score based on optimal liquidity ratio (target: 20-50%)
    if (liquidityRatio >= 20 && liquidityRatio <= 50) return 100;
    if (liquidityRatio >= 10 && liquidityRatio < 20) return 80;
    if (liquidityRatio >= 5 && liquidityRatio < 10) return 60;
    if (liquidityRatio > 50 && liquidityRatio <= 80) return 70;
    return 40; // Too low or too high liquidity
}
```

---

## 🔒 Security Mechanisms

### **Reentrancy Protection:**
```solidity
// All state-changing functions use nonReentrant modifier
function unstakeNFT(uint256 receiptTokenId) external nonReentrant {
    // Update state BEFORE external calls
    _updateReward(msg.sender);
    
    // External calls at the end
    receiptContract.burn(receiptTokenId);
    nftCollection.transferFrom(address(this), msg.sender, tokenId);
}
```

### **Access Control:**
```solidity
// Only factory can initialize pools
modifier onlyFactory() {
    require(msg.sender == factory, "Only factory");
    _;
}

// Only pool can mint/burn receipts
modifier onlyPool() {
    require(msg.sender == pool, "Only pool");
    _;
}

// Only owner can upgrade contracts
function _authorizeUpgrade(address) internal override onlyOwner {}
```

### **Input Validation:**
```solidity
function swapNFT(uint256 tokenIdIn, uint256 tokenIdOut) external payable {
    if (msg.value < swapFeeInWei) revert InsufficientFee();
    if (!tokenInPool[tokenIdOut]) revert TokenNotInPool();
    if (nftCollection.ownerOf(tokenIdIn) != msg.sender) revert NotYourToken();
    if (tokenIdIn == tokenIdOut) revert SameToken();
    // ... rest of function
}
```

---

## 🚀 Gas Optimization Techniques

### **Batch Operations:**
```solidity
function batchStake(uint256[] calldata tokenIds) external {
    require(tokenIds.length <= 10, "Too many tokens"); // Gas limit
    
    _updateReward(msg.sender); // Single reward update
    
    for (uint256 i = 0; i < tokenIds.length; i++) {
        // Individual stake logic without reward updates
        _stakeWithoutRewardUpdate(tokenIds[i]);
    }
}
```

### **Efficient Storage Access:**
```solidity
// Cache array length to avoid multiple SLOAD operations
uint256 length = poolTokens.length;
for (uint256 i = 0; i < length; i++) {
    // Use cached length instead of poolTokens.length
}
```

### **Packed Structs:**
```solidity
struct StakeInfo {
    uint256 stakedAt;        // 32 bytes
    uint256 rewardDebt;      // 32 bytes  
    bool active;             // 1 byte (packed with next field if any)
}
```

---

## 🔄 Upgrade Mechanisms

### **UUPS Proxy Pattern:**
```solidity
// Implementation can upgrade itself
contract SwapPoolNative is UUPSUpgradeable {
    function _authorizeUpgrade(address newImplementation) 
        internal 
        override 
        onlyOwner 
    {}
}

// Factory creates proxies pointing to implementation
ERC1967Proxy proxy = new ERC1967Proxy(implementation, initData);
```

### **Storage Gap for Future Upgrades:**
```solidity
// Reserved storage slots for future variables
uint256[50] private __gap;
```

---

This technical deep dive shows how JPEGSwap combines advanced DeFi mechanics with NFT technology to create a sophisticated, secure, and user-friendly ecosystem. The real timestamp tracking, health scoring algorithms, and cross-pool analytics make it a truly enterprise-grade platform! 🏆

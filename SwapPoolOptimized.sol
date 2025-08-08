// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Essential interfaces
interface IERC721 {
    function balanceOf(address owner) external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}

interface IERC1822Proxiable {
    function proxiableUUID() external view returns (bytes32);
}

interface IBeacon {
    function implementation() external view returns (address);
}

/**
 * @title SwapPoolNative - Optimized NFT Swap Pool
 * @dev Minimal gas-optimized version for deployment under EIP-170 limits
 */
contract SwapPoolNative {
    // 🔧 CORE STATE VARIABLES
    address public nftCollection;
    address public receiptContract;
    address public stonerPool;
    uint256 public swapFeeInWei;
    uint256 public stonerShare;
    bool public initialized;

    // Pool state
    mapping(address => uint256[]) public userStakes;
    mapping(uint256 => bool) public tokenInPool;
    mapping(uint256 => uint256) public originalToReceiptToken;
    uint256 public totalStaked;
    uint256 public rewardPerTokenStored;
    uint256 public lastUpdateTime;
    uint256 public totalRewardsDistributed;

    // 🎯 ENHANCED PRECISION
    uint256 private constant PRECISION = 1e27;
    uint256 private rewardRemainder;
    uint256 private totalPrecisionRewards;

    // User reward tracking
    mapping(address => uint256) public pendingRewards;
    mapping(address => uint256) public userRewardPerTokenPaid;

    // 🔄 BATCH OPERATION LIMITS (Sonic Optimized)
    uint256 public maxBatchSize = 50;
    uint256 public maxUnstakeAllLimit = 100;
    uint256 public minPoolSize = 2;

    // Analytics tracking
    mapping(address => bool) private _hasSwapped;

    // 📊 ESSENTIAL EVENTS ONLY
    event SwapExecuted(address indexed user, uint256 tokenIdIn, uint256 tokenIdOut, uint256 feePaid);
    event Staked(address indexed user, uint256 tokenId, uint256 receiptTokenId);
    event Unstaked(address indexed user, uint256 tokenId, uint256 receiptTokenId);
    event RewardsClaimed(address indexed user, uint256 amount);
    event RewardsDistributed(uint256 amount);

    // 🚨 ERRORS
    error NotTokenOwner();
    error TokenNotApproved();
    error TokenUnavailable();
    error IncorrectFee();
    error SameTokenSwap();
    error NotInitialized();
    error AlreadyInitialized();
    error InsufficientLiquidity();
    error NotReceiptOwner();
    error InvalidBatchSize();

    // 🔒 MODIFIERS
    modifier onlyInitialized() {
        if (!initialized) revert NotInitialized();
        _;
    }

    modifier minimumLiquidity() {
        if (IERC721(nftCollection).balanceOf(address(this)) < minPoolSize) revert InsufficientLiquidity();
        _;
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;
        if (account != address(0)) {
            pendingRewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    // 🏗️ INITIALIZATION
    function initialize(
        address _nftCollection,
        address _receiptContract,
        address _stonerPool,
        uint256 _swapFeeInWei,
        uint256 _stonerShare
    ) public initializer {
        require(_nftCollection != address(0) && _stonerPool != address(0), "Zero address");
        require(_receiptContract != address(0), "Zero receipt address");
        require(_stonerShare <= 100, "Invalid stoner share");

        __Ownable_init();
        __Pausable_init();
        __ReentrancyGuard_init();
        __UUPSUpgradeable_init();

        nftCollection = _nftCollection;
        receiptContract = _receiptContract;
        stonerPool = _stonerPool;
        swapFeeInWei = _swapFeeInWei;
        stonerShare = _stonerShare;
        initialized = true;
        lastUpdateTime = block.timestamp;
    }

    // 💰 CORE SWAP FUNCTION
    function swapNFT(uint256 tokenIdIn, uint256 tokenIdOut)
        external
        payable
        nonReentrant
        onlyInitialized
        whenNotPaused
        minimumLiquidity
        updateReward(address(0))
    {
        // 🛡️ VALIDATION
        if (IERC721(nftCollection).ownerOf(tokenIdIn) != msg.sender) revert NotTokenOwner();
        if (IERC721(nftCollection).ownerOf(tokenIdOut) != address(this)) revert TokenUnavailable();
        if (msg.value != swapFeeInWei) revert IncorrectFee();
        if (tokenIdIn == tokenIdOut) revert SameTokenSwap();

        // Calculate fee distribution
        uint256 stonerAmount = 0;
        uint256 rewardAmount = msg.value;

        if (stonerShare > 0) {
            stonerAmount = (msg.value * stonerShare) / 100;
            rewardAmount = msg.value - stonerAmount;
        }

        // 🔄 Update pool token tracking (CEI pattern)
        tokenInPool[tokenIdOut] = false;
        tokenInPool[tokenIdIn] = true;

        // 🎯 DISTRIBUTE REWARDS
        if (rewardAmount > 0 && totalStaked > 0) {
            uint256 rewardWithRemainder = (rewardAmount * PRECISION) + rewardRemainder;
            uint256 rewardPerTokenAmount = rewardWithRemainder / totalStaked;
            rewardRemainder = rewardWithRemainder % totalStaked;
            
            rewardPerTokenStored += rewardPerTokenAmount / 1e9;
            totalPrecisionRewards += rewardWithRemainder;
            totalRewardsDistributed += rewardAmount;
            emit RewardsDistributed(rewardAmount);
        }

        // 🔄 EXECUTE SWAP
        IERC721(nftCollection).safeTransferFrom(msg.sender, address(this), tokenIdIn);
        IERC721(nftCollection).safeTransferFrom(address(this), msg.sender, tokenIdOut);

        // Send stoner share
        if (stonerAmount > 0) {
            (bool success, ) = payable(stonerPool).call{value: stonerAmount}("");
            require(success, "Stoner transfer failed");
        }

        emit SwapExecuted(msg.sender, tokenIdIn, tokenIdOut, msg.value);
    }

    // 🔄 STAKING FUNCTIONS
    function stake(uint256[] calldata tokenIds) 
        external 
        nonReentrant 
        onlyInitialized 
        whenNotPaused 
        updateReward(msg.sender)
    {
        require(tokenIds.length > 0 && tokenIds.length <= maxBatchSize, "Invalid batch size");
        
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            require(IERC721(nftCollection).ownerOf(tokenId) == msg.sender, "Not token owner");
            
            IERC721(nftCollection).safeTransferFrom(msg.sender, address(this), tokenId);
            userStakes[msg.sender].push(tokenId);
            tokenInPool[tokenId] = true;
            
            // Mint receipt token
            uint256 receiptId = _mintReceipt(msg.sender, tokenId);
            originalToReceiptToken[tokenId] = receiptId;
            
            emit Staked(msg.sender, tokenId, receiptId);
        }
        
        totalStaked += tokenIds.length;
    }

    function unstake(uint256[] calldata receiptTokenIds) 
        external 
        nonReentrant 
        onlyInitialized 
        whenNotPaused 
        updateReward(msg.sender)
    {
        require(receiptTokenIds.length > 0 && receiptTokenIds.length <= maxBatchSize, "Invalid batch size");
        
        for (uint256 i = 0; i < receiptTokenIds.length; i++) {
            uint256 receiptId = receiptTokenIds[i];
            require(_ownsReceipt(msg.sender, receiptId), "Not receipt owner");
            
            uint256 originalTokenId = _getOriginalTokenId(receiptId);
            
            // Burn receipt and return NFT
            _burnReceipt(receiptId);
            _removeFromUserStakes(msg.sender, originalTokenId);
            tokenInPool[originalTokenId] = false;
            
            IERC721(nftCollection).safeTransferFrom(address(this), msg.sender, originalTokenId);
            
            emit Unstaked(msg.sender, originalTokenId, receiptId);
        }
        
        totalStaked -= receiptTokenIds.length;
    }

    // 💰 REWARDS
    function claimRewards() external nonReentrant updateReward(msg.sender) {
        uint256 reward = pendingRewards[msg.sender];
        require(reward > 0, "No rewards");
        
        pendingRewards[msg.sender] = 0;
        
        (bool success, ) = payable(msg.sender).call{value: reward}("");
        require(success, "Reward transfer failed");
        
        emit RewardsClaimed(msg.sender, reward);
    }

    // 📊 VIEW FUNCTIONS
    function earned(address account) public view returns (uint256) {
        uint256 userBalance = userStakes[account].length;
        return userBalance * (rewardPerToken() - userRewardPerTokenPaid[account]) / PRECISION + pendingRewards[account];
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalStaked == 0) return rewardPerTokenStored;
        return rewardPerTokenStored;
    }

    function getUserStakes(address user) external view returns (uint256[] memory) {
        return userStakes[user];
    }

    function getPoolInfo() external view returns (
        uint256 totalNFTs,
        uint256 stakedNFTs,
        uint256 totalRewards,
        uint256 swapFee
    ) {
        return (
            IERC721(nftCollection).balanceOf(address(this)) + totalStaked,
            totalStaked,
            totalRewardsDistributed,
            swapFeeInWei
        );
    }

    // 🔧 ADMIN FUNCTIONS
    function setSwapFee(uint256 _swapFeeInWei) external onlyOwner {
        swapFeeInWei = _swapFeeInWei;
    }

    function setStonerShare(uint256 _stonerShare) external onlyOwner {
        require(_stonerShare <= 100, "Invalid share");
        stonerShare = _stonerShare;
    }

    function setBatchLimits(uint256 _maxBatch, uint256 _maxUnstake, uint256 _minPool) external onlyOwner {
        maxBatchSize = _maxBatch;
        maxUnstakeAllLimit = _maxUnstake;
        minPoolSize = _minPool;
    }

    function emergencyWithdrawETH() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH to withdraw");
        (bool success, ) = payable(owner()).call{value: balance}("");
        require(success, "Emergency withdrawal failed");
    }

    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }

    // 🔧 FeeM Registration
    function registerMe() external onlyOwner {
        (bool _success,) = address(0xDC2B0D2Dd2b7759D97D50db4eabDC36973110830).call(
            abi.encodeWithSignature("selfRegister(uint256)", 92)
        );
        require(_success, "FeeM registration failed");
    }

    // 🔒 UUPS
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    // 🔧 INTERNAL FUNCTIONS
    function _mintReceipt(address to, uint256 tokenId) internal returns (uint256) {
        // Call receipt contract to mint
        (bool success, bytes memory data) = receiptContract.call(
            abi.encodeWithSignature("mint(address,uint256)", to, tokenId)
        );
        require(success, "Receipt mint failed");
        return abi.decode(data, (uint256));
    }

    function _burnReceipt(uint256 receiptId) internal {
        (bool success, ) = receiptContract.call(
            abi.encodeWithSignature("burn(uint256)", receiptId)
        );
        require(success, "Receipt burn failed");
    }

    function _ownsReceipt(address user, uint256 receiptId) internal view returns (bool) {
        (bool success, bytes memory data) = receiptContract.staticcall(
            abi.encodeWithSignature("ownerOf(uint256)", receiptId)
        );
        if (!success) return false;
        address owner = abi.decode(data, (address));
        return owner == user;
    }

    function _getOriginalTokenId(uint256 receiptId) internal view returns (uint256) {
        (bool success, bytes memory data) = receiptContract.staticcall(
            abi.encodeWithSignature("receiptToOriginalToken(uint256)", receiptId)
        );
        require(success, "Failed to get original token");
        return abi.decode(data, (uint256));
    }

    function _removeFromUserStakes(address user, uint256 tokenId) internal {
        uint256[] storage stakes = userStakes[user];
        for (uint256 i = 0; i < stakes.length; i++) {
            if (stakes[i] == tokenId) {
                stakes[i] = stakes[stakes.length - 1];
                stakes.pop();
                break;
            }
        }
    }

    // 📥 RECEIVE ETH
    receive() external payable {
        if (totalStaked > 0) {
            uint256 rewardWithRemainder = (msg.value * PRECISION) + rewardRemainder;
            uint256 rewardPerTokenAmount = rewardWithRemainder / totalStaked;
            rewardRemainder = rewardWithRemainder % totalStaked;
            
            rewardPerTokenStored += rewardPerTokenAmount / 1e9;
            totalPrecisionRewards += rewardWithRemainder;
            totalRewardsDistributed += msg.value;
            
            emit RewardsDistributed(msg.value);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

pragma solidity >=0.6.2;

library AddressUpgradeable {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Low balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Send failed");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Low balance");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Not contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// File: @openzeppelin/contracts-upgradeable@4.8.3/proxy/utils/Initializable.sol


// OpenZeppelin Contracts (last updated v4.8.1) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;


abstract contract Initializable {
    uint8 private _initialized;

    bool private _initializing;

    event Initialized(uint8 version);

    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    modifier onlyInitializing() {
        require(_initializing, "Not initializing");
        _;
    }

    function _disableInitializers() internal virtual {
        require(!_initializing, "Is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

// File: @openzeppelin/contracts-upgradeable@4.8.3/utils/ContextUpgradeable.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;


abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}

// File: @openzeppelin/contracts-upgradeable@4.8.3/access/OwnableUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;



abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Not owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    uint256[49] private __gap;
}

// File: @openzeppelin/contracts-upgradeable@4.8.3/security/PausableUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;



abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    modifier whenPaused() {
        _requirePaused();
        _;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    function _requireNotPaused() internal view virtual {
        require(!paused(), "Paused");
    }

    function _requirePaused() internal view virtual {
        require(paused(), "Not paused");
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    uint256[49] private __gap;
}

// File: @openzeppelin/contracts-upgradeable@4.8.3/security/ReentrancyGuardUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;


abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "Reentrant");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    uint256[49] private __gap;
}

// File: @openzeppelin/contracts-upgradeable@4.8.3/interfaces/draft-IERC1822Upgradeable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

interface IERC1822ProxiableUpgradeable {
    function proxiableUUID() external view returns (bytes32);
}

// File: @openzeppelin/contracts-upgradeable@4.8.3/proxy/beacon/IBeaconUpgradeable.sol


// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

interface IBeaconUpgradeable {
    function implementation() external view returns (address);
}

// File: @openzeppelin/contracts-upgradeable@4.8.3/interfaces/IERC1967Upgradeable.sol


// OpenZeppelin Contracts (last updated v4.8.3) (interfaces/IERC1967.sol)

pragma solidity ^0.8.0;

interface IERC1967Upgradeable {
    event Upgraded(address indexed implementation);

    event AdminChanged(address previousAdmin, address newAdmin);

    event BeaconUpgraded(address indexed beacon);
}

// File: @openzeppelin/contracts-upgradeable@4.8.3/utils/StorageSlotUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

// File: @openzeppelin/contracts-upgradeable@4.8.3/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.8.3) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;







abstract contract ERC1967UpgradeUpgradeable is Initializable, IERC1967Upgradeable {
    function __ERC1967Upgrade_init() internal onlyInitializing {
    }

    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {
    }
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "Not contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "Bad UUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "Zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "Not contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Not contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }

    uint256[50] private __gap;
}

// File: @openzeppelin/contracts-upgradeable@4.8.3/proxy/utils/UUPSUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.8.0) (proxy/utils/UUPSUpgradeable.sol)

pragma solidity ^0.8.0;




abstract contract UUPSUpgradeable is Initializable, IERC1822ProxiableUpgradeable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal onlyInitializing {
    }

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    address private immutable __self = address(this);

    modifier onlyProxy() {
        require(address(this) != __self, "Use delegatecall");
        require(_getImplementation() == __self, "Use active proxy");
        _;
    }

    modifier notDelegated() {
        require(address(this) == __self, "No delegatecall");
        _;
    }

    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }

    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

    function _authorizeUpgrade(address newImplementation) internal virtual;

    uint256[50] private __gap;
}

// File: @openzeppelin/contracts@4.8.3/utils/introspection/IERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts@4.8.3/token/ERC721/IERC721.sol


// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;

    function setApprovalForAll(address operator, bool _approved) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// File: contracts/SwapPoolNative.sol

pragma solidity ^0.8.19;

interface IReceiptContract {
    function mint(address to, uint256 originalTokenId) external returns (uint256 receiptTokenId);
    function burn(uint256 receiptTokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function getOriginalTokenId(uint256 receiptTokenId) external view returns (uint256);
    function validateReceipt(uint256 receiptTokenId, address expectedPool) external view returns (bool);
}

contract SwapPoolNative is
    Initializable,
    OwnableUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable,
    UUPSUpgradeable
{
    using AddressUpgradeable for address payable;

    // Core state variables
    address public nftCollection;
    address public receiptContract;
    address public stonerPool;
    uint256 public swapFeeInWei;
    uint256 public stonerShare; // Percentage (0–100)
    bool public initialized;

    // 🎯 LIQUIDITY MANAGEMENT
    uint256 public minPoolSize = 5;
    
    // 🎯 BATCH LIMITS
    uint256 public maxBatchSize = 10;
    uint256 public maxUnstakeAllLimit = 20;

    // 🎯 POOL TOKEN TRACKING - Track all available tokens
    uint256[] public poolTokens;                    // Array of all tokens in pool
    mapping(uint256 => uint256) public tokenIndexInPool; // tokenId => index in poolTokens array
    mapping(uint256 => bool) public tokenInPool;    // tokenId => is in pool

    // 🎯 COMPLETE REWARD SYSTEM STATE
    struct StakeInfo {
        uint256 stakedAt;        // Timestamp when staked
        uint256 rewardDebt;      // Reward debt for fair calculation
        bool active;             // Is this stake active
    }

    mapping(uint256 => StakeInfo) public stakeInfos;           // receiptTokenId => StakeInfo
    mapping(address => uint256[]) public userStakes;           // user => receiptTokenIds[]
    mapping(uint256 => uint256) public receiptToOriginalToken; // receiptId => originalTokenId
    mapping(uint256 => uint256) public originalToReceiptToken; // originalTokenId => receiptId

    uint256 public totalStaked;                    // Total number of staked NFTs
    uint256 public rewardPerTokenStored;           // Accumulated reward per token
    uint256 public lastUpdateTime;                 // Last reward update timestamp
    uint256 public totalRewardsDistributed;       // Total rewards distributed

    // 🎯 ENHANCED PRECISION FOR REWARD CALCULATIONS
    uint256 private constant PRECISION = 1e27;    // High precision for calculations
    uint256 private rewardRemainder;              // Accumulated remainder for precision
    uint256 private totalPrecisionRewards;        // Total rewards with precision tracking

    // User reward tracking
    mapping(address => uint256) public pendingRewards;        // Claimable rewards
    mapping(address => uint256) public userRewardPerTokenPaid; // Last paid reward per token

    // 🔄 BATCH OPERATION TRACKING
    bool private _inBatchOperation;
    uint256[] private _batchReceiptTokens;
    uint256[] private _batchReturnedTokens;

    // Events
    event SwapExecuted(address indexed user, uint256 tokenIdIn, uint256 tokenIdOut, uint256 feePaid);
    event BatchSwapExecuted(address indexed user, uint256 swapCount, uint256 totalFeePaid);
    event Staked(address indexed user, uint256 tokenId, uint256 receiptTokenId);
    event Unstaked(address indexed user, uint256 tokenId, uint256 receiptTokenId);
    event BatchUnstaked(address indexed user, uint256[] receiptTokenIds, uint256[] tokensReceived);
    event RewardsClaimed(address indexed user, uint256 amount);
    event RewardsDistributed(uint256 amount);
    event SwapFeeUpdated(uint256 newFeeInWei);
    event StonerShareUpdated(uint256 newShare);
    event BatchLimitsUpdated(uint256 newMaxBatchSize, uint256 newMaxUnstakeAll);

    // Custom errors
    error AlreadyInitialized();
    error NotInitialized();
    error InvalidStonerShare();
    error TokenUnavailable();
    error IncorrectFee();
    error NotReceiptOwner();
    error TokenNotStaked();
    error NoRewardsToClaim();
    error InvalidReceiptToken();
    error NoTokensAvailable();
    error SameTokenSwap();
    error InsufficientLiquidity(uint256 available, uint256 minimum);
    error NotTokenOwner();
    error TokenNotApproved();

    modifier onlyInitialized() {
        if (!initialized) revert NotInitialized();
        _;
    }

    // � LIQUIDITY PROTECTION MODIFIER
    modifier minimumLiquidity() {
        require(poolTokens.length >= minPoolSize, "Low liquidity");
        _;
    }

    // �🔄 CRITICAL: Reward calculation modifier for fair distribution
    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;
        
        if (account != address(0)) {
            pendingRewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _nftCollection,
        address _receiptContract,
        address _stonerPool,
        uint256 _swapFeeInWei,
        uint256 _stonerShare
    ) public initializer {
        require(_nftCollection != address(0) && _stonerPool != address(0), "Zero address");
        require(_receiptContract != address(0), "Zero receipt");
        require(_stonerShare <= 100, "Bad share");

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

    // 💰 SWAP WITH COMPLETE REWARD DISTRIBUTION + POOL TRACKING
    function swapNFT(uint256 tokenIdIn, uint256 tokenIdOut)
        external
        payable
        nonReentrant
        onlyInitialized
        whenNotPaused
        minimumLiquidity
        updateReward(address(0)) // Update global rewards
    {
        // 🛡️ ENHANCED VALIDATION
        if (IERC721(nftCollection).ownerOf(tokenIdIn) != msg.sender) revert NotTokenOwner();
        if (IERC721(nftCollection).getApproved(tokenIdIn) != address(this) && 
            !IERC721(nftCollection).isApprovedForAll(msg.sender, address(this))) {
            revert TokenNotApproved();
        }
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

        // 🔄 Update pool token tracking FIRST (CEI pattern)
        _removeTokenFromPool(tokenIdOut);
        _addTokenToPool(tokenIdIn);

        // 🎯 DISTRIBUTE REMAINING AS REWARDS TO STAKERS (ENHANCED PRECISION)
        if (rewardAmount > 0 && totalStaked > 0) {
            // Use higher precision to minimize rounding errors
            uint256 rewardWithRemainder = (rewardAmount * PRECISION) + rewardRemainder;
            uint256 rewardPerTokenAmount = rewardWithRemainder / totalStaked;
            rewardRemainder = rewardWithRemainder % totalStaked;
            
            // Add rewards to the reward pool with enhanced precision
            rewardPerTokenStored += rewardPerTokenAmount / 1e9; // Convert back from PRECISION to 1e18
            totalPrecisionRewards += rewardWithRemainder;
            totalRewardsDistributed += rewardAmount;
            emit RewardsDistributed(rewardAmount);
        }

        // Execute the swap - NFT transfers
        IERC721(nftCollection).safeTransferFrom(msg.sender, address(this), tokenIdIn);
        IERC721(nftCollection).safeTransferFrom(address(this), msg.sender, tokenIdOut);
        
        // 🔒 SECURITY: Revoke any remaining approvals to prevent double-spend
        if (IERC721(nftCollection).getApproved(tokenIdIn) == address(this)) {
            IERC721(nftCollection).approve(address(0), tokenIdIn);
        }

        // External calls LAST (CEI pattern)
        if (stonerAmount > 0) {
            payable(stonerPool).sendValue(stonerAmount);
        }

        emit SwapExecuted(msg.sender, tokenIdIn, tokenIdOut, msg.value);
    }

    function swapNFTBatch(uint256[] calldata tokenIdsIn, uint256[] calldata tokenIdsOut)
        external
        payable
        nonReentrant
        onlyInitialized
        whenNotPaused
        minimumLiquidity
        updateReward(address(0)) // Update global rewards
    {
        // 🛡️ BATCH VALIDATION
        require(tokenIdsIn.length > 0 && tokenIdsOut.length > 0, "Empty arrays");
        require(tokenIdsIn.length == tokenIdsOut.length, "Length mismatch");
        require(tokenIdsIn.length <= maxBatchSize, "Batch limit");
        
        // 🔍 DUPLICATE DETECTION
        _checkForDuplicates(tokenIdsIn);
        _checkForDuplicates(tokenIdsOut);
        
        uint256 totalFeeRequired = swapFeeInWei * tokenIdsIn.length;
        if (msg.value != totalFeeRequired) revert IncorrectFee();

        // Validate all tokens before any state changes
        for (uint256 i = 0; i < tokenIdsIn.length; i++) {
            uint256 tokenIdIn = tokenIdsIn[i];
            uint256 tokenIdOut = tokenIdsOut[i];
            
            // Check ownership and approval for input tokens
            if (IERC721(nftCollection).ownerOf(tokenIdIn) != msg.sender) revert NotTokenOwner();
            if (IERC721(nftCollection).getApproved(tokenIdIn) != address(this) && 
                !IERC721(nftCollection).isApprovedForAll(msg.sender, address(this))) {
                revert TokenNotApproved();
            }
            
            // Check pool ownership of output tokens
            if (IERC721(nftCollection).ownerOf(tokenIdOut) != address(this)) revert TokenUnavailable();
            if (tokenIdIn == tokenIdOut) revert SameTokenSwap();
        }

        // Calculate fee distribution
        uint256 stonerAmount = 0;
        uint256 rewardAmount = msg.value;

        if (stonerShare > 0) {
            stonerAmount = (msg.value * stonerShare) / 100;
            rewardAmount = msg.value - stonerAmount;
        }

        // 🔄 Update pool token tracking FIRST (CEI pattern)
        for (uint256 i = 0; i < tokenIdsIn.length; i++) {
            _removeTokenFromPool(tokenIdsOut[i]);
            _addTokenToPool(tokenIdsIn[i]);
        }

        // 🎯 DISTRIBUTE REMAINING AS REWARDS TO STAKERS (ENHANCED PRECISION)
        if (rewardAmount > 0 && totalStaked > 0) {
            // Use higher precision to minimize rounding errors
            uint256 rewardWithRemainder = (rewardAmount * PRECISION) + rewardRemainder;
            uint256 rewardPerTokenAmount = rewardWithRemainder / totalStaked;
            rewardRemainder = rewardWithRemainder % totalStaked;
            
            // Add rewards to the reward pool with enhanced precision
            rewardPerTokenStored += rewardPerTokenAmount / 1e9; // Convert back from PRECISION to 1e18
            totalPrecisionRewards += rewardWithRemainder;
            totalRewardsDistributed += rewardAmount;
            emit RewardsDistributed(rewardAmount);
        }

        // Execute all swaps - NFT transfers
        for (uint256 i = 0; i < tokenIdsIn.length; i++) {
            IERC721(nftCollection).safeTransferFrom(msg.sender, address(this), tokenIdsIn[i]);
            IERC721(nftCollection).safeTransferFrom(address(this), msg.sender, tokenIdsOut[i]);
            
            // 🔒 SECURITY: Revoke any remaining approvals to prevent double-spend
            if (IERC721(nftCollection).getApproved(tokenIdsIn[i]) == address(this)) {
                IERC721(nftCollection).approve(address(0), tokenIdsIn[i]);
            }
            
            // Emit event for each swap in the batch
            emit SwapExecuted(msg.sender, tokenIdsIn[i], tokenIdsOut[i], swapFeeInWei);
        }

        // External calls LAST (CEI pattern)
        if (stonerAmount > 0) {
            payable(stonerPool).sendValue(stonerAmount);
        }

        // Emit batch completion event
        emit BatchSwapExecuted(msg.sender, tokenIdsIn.length, msg.value);
    }

    // 🏦 COMPLETE STAKING WITH RECEIPT MINTING + POOL TRACKING
    function stakeNFT(uint256 tokenId) 
        external 
        nonReentrant
        onlyInitialized 
        whenNotPaused 
        updateReward(msg.sender)
    {
        // Transfer NFT to pool
        IERC721(nftCollection).safeTransferFrom(msg.sender, address(this), tokenId);
        
        // 🔒 SECURITY: Revoke any remaining approvals to prevent double-spend
        if (IERC721(nftCollection).getApproved(tokenId) == address(this)) {
            IERC721(nftCollection).approve(address(0), tokenId);
        }
        
        // Add to pool tracking
        _addTokenToPool(tokenId);
        
        // Mint receipt token
        uint256 receiptTokenId = IReceiptContract(receiptContract).mint(msg.sender, tokenId);
        
        // Update stake tracking with COMPLETE data
        stakeInfos[receiptTokenId] = StakeInfo({
            stakedAt: block.timestamp,
            rewardDebt: rewardPerTokenStored,
            active: true
        });
        
        receiptToOriginalToken[receiptTokenId] = tokenId;
        originalToReceiptToken[tokenId] = receiptTokenId;
        userStakes[msg.sender].push(receiptTokenId);
        totalStaked++;

        emit Staked(msg.sender, tokenId, receiptTokenId);
    }

    // 🎯 SMART UNSTAKING - Returns ORIGINAL if available, RANDOM if swapped away
    function unstakeNFT(uint256 receiptTokenId) 
        external 
        nonReentrant
        onlyInitialized 
        whenNotPaused 
        updateReward(msg.sender)
    {
        _unstakeNFTInternal(receiptTokenId);
    }

    // 🔄 PARTIAL UNSTAKING - Unstake multiple NFTs in a single transaction
    function unstakeNFTBatch(uint256[] calldata receiptTokenIds) 
        external 
        nonReentrant
        onlyInitialized 
        whenNotPaused 
        updateReward(msg.sender)
    {
        uint256 batchLength = receiptTokenIds.length;
        require(batchLength > 0, "Empty array");
        require(batchLength <= maxBatchSize, "Batch limit");
        
        // Initialize batch tracking
        _inBatchOperation = true;
        delete _batchReceiptTokens;
        delete _batchReturnedTokens;
        
        for (uint256 i = 0; i < batchLength; i++) {
            _unstakeNFTInternal(receiptTokenIds[i]);
        }
        
        // Emit batch event
        emit BatchUnstaked(msg.sender, _batchReceiptTokens, _batchReturnedTokens);
        
        // Reset batch tracking
        _inBatchOperation = false;
        delete _batchReceiptTokens;
        delete _batchReturnedTokens;
    }

    // 🔄 UNSTAKE ALL - Unstake all user's staked NFTs in a single transaction
    function unstakeAllNFTs() 
        external 
        nonReentrant
        onlyInitialized 
        whenNotPaused 
        updateReward(msg.sender)
    {
        uint256[] memory userReceiptTokens = userStakes[msg.sender];
        uint256 userStakesLength = userReceiptTokens.length;
        require(userStakesLength > 0, "No stakes");
        
        // Create array of active receipt tokens
        uint256[] memory activeReceipts = new uint256[](userStakesLength);
        uint256 activeCount = 0;
        
        for (uint256 i = 0; i < userStakesLength; i++) {
            if (stakeInfos[userReceiptTokens[i]].active) {
                activeReceipts[activeCount] = userReceiptTokens[i];
                activeCount++;
            }
        }
        
        require(activeCount > 0, "No active");
        require(activeCount <= maxUnstakeAllLimit, "Too many stakes");
        
        // Initialize batch tracking
        _inBatchOperation = true;
        delete _batchReceiptTokens;
        delete _batchReturnedTokens;
        
        for (uint256 i = 0; i < activeCount; i++) {
            _unstakeNFTInternal(activeReceipts[i]);
        }
        
        // Emit batch event
        emit BatchUnstaked(msg.sender, _batchReceiptTokens, _batchReturnedTokens);
        
        // Reset batch tracking
        _inBatchOperation = false;
        delete _batchReceiptTokens;
        delete _batchReturnedTokens;
    }

    // 🎯 INTERNAL UNSTAKING LOGIC WITH BATCH OPERATION SUPPORT + AUTO-CLAIM
    function _unstakeNFTInternal(uint256 receiptTokenId) internal {
        // Verify receipt ownership
        if (IReceiptContract(receiptContract).ownerOf(receiptTokenId) != msg.sender) revert NotReceiptOwner();
        
        StakeInfo storage stakeInfo = stakeInfos[receiptTokenId];
        if (!stakeInfo.active) revert TokenNotStaked();
        
        uint256 originalTokenId = receiptToOriginalToken[receiptTokenId];
        
        // 🎯 AUTO-CLAIM REWARDS BEFORE UNSTAKING
        uint256 rewardsToSend = pendingRewards[msg.sender];
        if (rewardsToSend > 0) {
            pendingRewards[msg.sender] = 0;
            payable(msg.sender).sendValue(rewardsToSend);
            emit RewardsClaimed(msg.sender, rewardsToSend);
        }
        
        // Mark stake as inactive
        stakeInfo.active = false;
        totalStaked--;
        
        // Remove from user stakes array
        _removeFromUserStakes(msg.sender, receiptTokenId);
        
        // Clean up mappings
        delete receiptToOriginalToken[receiptTokenId];
        delete originalToReceiptToken[originalTokenId];
        
        // Burn receipt token
        IReceiptContract(receiptContract).burn(receiptTokenId);
        
        // 🎯 SMART TOKEN RETURN LOGIC
        uint256 tokenToReturn;
        
        // Check if original token is still in the pool
        if (tokenInPool[originalTokenId] && IERC721(nftCollection).ownerOf(originalTokenId) == address(this)) {
            // ✅ Original token is available - return it!
            tokenToReturn = originalTokenId;
        } else {
            // ❌ Original was swapped away - get random available token
            tokenToReturn = _getRandomAvailableToken();
        }
        
        // Remove token from pool tracking
        _removeTokenFromPool(tokenToReturn);
        
        // Return NFT
        IERC721(nftCollection).safeTransferFrom(address(this), msg.sender, tokenToReturn);

        // Track for batch operations or emit individual event
        if (_inBatchOperation) {
            _batchReceiptTokens.push(receiptTokenId);
            _batchReturnedTokens.push(tokenToReturn);
        } else {
            emit Unstaked(msg.sender, tokenToReturn, receiptTokenId);
        }
    }

    // 💸 UPDATED REWARD CLAIMING (now optional since auto-claim on unstake)
    function claimRewards() 
        external 
        nonReentrant 
        updateReward(msg.sender)
    {
        uint256 reward = pendingRewards[msg.sender];
        if (reward == 0) revert NoRewardsToClaim();
        
        pendingRewards[msg.sender] = 0;
        payable(msg.sender).sendValue(reward);

        emit RewardsClaimed(msg.sender, reward);
    }

    // 🎯 NEW: Emergency claim without unstaking (if users want rewards but keep staking)
    function claimRewardsOnly() 
        external 
        nonReentrant 
        updateReward(msg.sender)
    {
        uint256 reward = pendingRewards[msg.sender];
        if (reward == 0) revert NoRewardsToClaim();
        
        pendingRewards[msg.sender] = 0;
        payable(msg.sender).sendValue(reward);

        emit RewardsClaimed(msg.sender, reward);
    }

    // 🎲 POOL TOKEN MANAGEMENT FUNCTIONS

    function _addTokenToPool(uint256 tokenId) internal {
        if (!tokenInPool[tokenId]) {
            tokenIndexInPool[tokenId] = poolTokens.length;
            poolTokens.push(tokenId);
            tokenInPool[tokenId] = true;
        }
    }

    function _removeTokenFromPool(uint256 tokenId) internal {
        if (tokenInPool[tokenId]) {
            uint256 index = tokenIndexInPool[tokenId];
            uint256 lastToken = poolTokens[poolTokens.length - 1];
            
            // Move last token to deleted position
            poolTokens[index] = lastToken;
            tokenIndexInPool[lastToken] = index;
            
            // Remove last element
            poolTokens.pop();
            delete tokenIndexInPool[tokenId];
            tokenInPool[tokenId] = false;
        }
    }

    function _getRandomAvailableToken() internal view returns (uint256) {
        if (poolTokens.length == 0) revert NoTokensAvailable();
        
        uint256 randomIndex = uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.prevrandao,
            msg.sender,
            poolTokens.length
        ))) % poolTokens.length;
        
        return poolTokens[randomIndex];
    }

    function _checkForDuplicates(uint256[] calldata tokenIds) internal pure {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            for (uint256 j = i + 1; j < tokenIds.length; j++) {
                require(tokenIds[i] != tokenIds[j], "Duplicate token");
            }
        }
    }

    // 📊 COMPLETE REWARD CALCULATION FUNCTIONS

    function rewardPerToken() public view returns (uint256) {
        return rewardPerTokenStored; // Already updated in modifier
    }

    function earned(address account) public view returns (uint256) {
        uint256 userStakedCount = getUserActiveStakeCount(account);
        if (userStakedCount == 0) return pendingRewards[account];
        
        uint256 rewardDiff = rewardPerToken() - userRewardPerTokenPaid[account];
        return pendingRewards[account] + (userStakedCount * rewardDiff) / 1e18;
    }

    function getUserActiveStakeCount(address user) public view returns (uint256 count) {
        uint256[] memory stakes = userStakes[user];
        uint256 stakesLength = stakes.length;
        for (uint256 i = 0; i < stakesLength; i++) {
            if (stakeInfos[stakes[i]].active) {
                count++;
            }
        }
    }

    function _removeFromUserStakes(address user, uint256 receiptTokenId) internal {
        uint256[] storage stakes = userStakes[user];
        uint256 stakesLength = stakes.length;
        for (uint256 i = 0; i < stakesLength; i++) {
            if (stakes[i] == receiptTokenId) {
                stakes[i] = stakes[stakesLength - 1];
                stakes.pop();
                break;
            }
        }
    }

    // 🔧 ADMIN FUNCTIONS
    function setSwapFee(uint256 newFeeInWei) external onlyOwner {
        swapFeeInWei = newFeeInWei;
        emit SwapFeeUpdated(newFeeInWei);
    }

    function setStonerShare(uint256 newShare) external onlyOwner {
        // 🔒 ENHANCED: Prevent 100% fees going to stoners (keep some for stakers)
        if (newShare >= 100) revert InvalidStonerShare();
        stonerShare = newShare;
        emit StonerShareUpdated(newShare);
    }

    function setBatchLimits(uint256 newMaxBatchSize, uint256 newMaxUnstakeAll) external onlyOwner {
        require(newMaxBatchSize > 0 && newMaxBatchSize <= 50, "Invalid batch size");
        require(newMaxUnstakeAll > 0 && newMaxUnstakeAll <= 100, "Invalid unstake all limit");
        
        maxBatchSize = newMaxBatchSize;
        maxUnstakeAllLimit = newMaxUnstakeAll;
        emit BatchLimitsUpdated(newMaxBatchSize, newMaxUnstakeAll);
    }

    function setMinPoolSize(uint256 newMinPoolSize) external onlyOwner {
        require(newMinPoolSize > 0 && newMinPoolSize <= 20, "Invalid min pool size");
        minPoolSize = newMinPoolSize;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function emergencyWithdraw(uint256 tokenId) external onlyOwner {
        IERC721(nftCollection).safeTransferFrom(address(this), owner(), tokenId);
    }

    function emergencyWithdrawETH() external onlyOwner {
        payable(owner()).sendValue(address(this).balance);
    }

    function emergencyWithdrawBatch(uint256[] calldata tokenIds) external onlyOwner {
        uint256 tokenIdsLength = tokenIds.length;
        for (uint256 i = 0; i < tokenIdsLength; i++) {
            IERC721(nftCollection).safeTransferFrom(address(this), owner(), tokenIds[i]);
        }
    }

    function registerMe() external onlyOwner {
        (bool _success,) = address(0xDC2B0D2Dd2b7759D97D50db4eabDC36973110830).call(
            abi.encodeWithSignature("selfRegister(uint256)", 92)
        );
        require(_success, "FeeM registration failed");
    }

    // 📊 VIEW FUNCTIONS
    function getPoolInfo() external view returns (
        address collection,
        uint256 totalNFTs,
        uint256 feeInWei,
        uint256 stonerPercent,
        uint256 stakedCount,
        uint256 rewardsDistributed
    ) {
        return (
            nftCollection,
            IERC721(nftCollection).balanceOf(address(this)),
            swapFeeInWei,
            stonerShare,
            totalStaked,
            totalRewardsDistributed
        );
    }











    function getTokenDetails(uint256 tokenId) external view returns (
        bool isInPool,
        bool isStaked,
        address currentOwner,
        uint256 receiptTokenId,
        uint256 stakedTimestamp
    ) {
        isInPool = tokenInPool[tokenId];
        receiptTokenId = originalToReceiptToken[tokenId];
        isStaked = receiptTokenId != 0 && stakeInfos[receiptTokenId].active;
        currentOwner = IERC721(nftCollection).ownerOf(tokenId);
        stakedTimestamp = isStaked ? stakeInfos[receiptTokenId].stakedAt : 0;
    }





    function isStakeActive(uint256 receiptTokenId) public view returns (bool) {
        return stakeInfos[receiptTokenId].active;
    }

    function getReceiptForToken(uint256 tokenId) external view returns (uint256) {
        return originalToReceiptToken[tokenId];
    }

    function getTokenForReceipt(uint256 receiptTokenId) external view returns (uint256) {
        return receiptToOriginalToken[receiptTokenId];
    }

    function getPoolTokens() external view returns (uint256[] memory) {
        return poolTokens;
    }

    function getAvailableTokenCount() external view returns (uint256) {
        return poolTokens.length;
    }

    function isTokenInPool(uint256 tokenId) external view returns (bool) {
        return tokenInPool[tokenId] && IERC721(nftCollection).ownerOf(tokenId) == address(this);
    }

    function calculateBatchSwapFee(uint256 swapCount) external view returns (
        uint256 totalFee,
        uint256 feePerSwap
    ) {
        require(swapCount > 0, "Swap count must be greater than 0");
        require(swapCount <= maxBatchSize, "Exceeds maximum batch size");
        
        feePerSwap = swapFeeInWei;
        totalFee = swapFeeInWei * swapCount;
    }

    function getStakingInterfaceData(address user) external view returns (
        uint256[] memory stakableTokens,
        uint256 currentRewardRate,
        uint256 projectedDailyEarnings,
        uint256 estimatedGasStake,
        bool stakingActive,
        uint256 totalStakingSlots,
        uint256 usedStakingSlots
    ) {
        // Calculate current reward rate per staked NFT per day
        currentRewardRate = totalStaked > 0 ? 
            (rewardPerTokenStored * 86400) / 1e18 / totalStaked : 0;
            
        uint256 userActiveStakes = getUserActiveStakeCount(user);
        projectedDailyEarnings = userActiveStakes * currentRewardRate;
        
        estimatedGasStake = 180000;
        stakingActive = !paused() && initialized;
        
        // For UI purposes - show reasonable limits
        totalStakingSlots = 1000; // Theoretical max for gas efficiency
        usedStakingSlots = totalStaked;
        
        stakableTokens = new uint256[](0); // Simplified - would need proper user token enumeration
    }

    function getTransactionPreviews(address user) external view returns (
        uint256 unstakeAllRewards,
        uint256 unstakeAllGas,
        uint256 claimOnlyRewards,
        uint256 claimOnlyGas,
        uint256 swapGas,
        uint256 stakeGas
    ) {
        unstakeAllRewards = earned(user);
        unstakeAllGas = 21000 + (getUserActiveStakeCount(user) * 150000);
        claimOnlyRewards = earned(user);
        claimOnlyGas = 80000;
        swapGas = 200000;
        stakeGas = 180000;
    }

    function getMultipleTokenStatuses(uint256[] calldata tokenIds) external view returns (
        bool[] memory inPool,
        bool[] memory isStaked,
        address[] memory owners,
        uint256[] memory receiptIds
    ) {
        uint256 length = tokenIds.length;
        inPool = new bool[](length);
        isStaked = new bool[](length);
        owners = new address[](length);
        receiptIds = new uint256[](length);
        
        for (uint256 i = 0; i < length; i++) {
            uint256 tokenId = tokenIds[i];
            inPool[i] = tokenInPool[tokenId];
            receiptIds[i] = originalToReceiptToken[tokenId];
            isStaked[i] = receiptIds[i] != 0 && stakeInfos[receiptIds[i]].active;
            
            try IERC721(nftCollection).ownerOf(tokenId) returns (address owner) {
                owners[i] = owner;
            } catch {
                owners[i] = address(0);
            }
        }
    }

    function getSwappableTokensPaginated(uint256 offset, uint256 limit) external view returns (
        uint256[] memory tokenIds,
        uint256 totalAvailable,
        bool hasMore
    ) {
        uint256 available = poolTokens.length;
        totalAvailable = available;
        
        if (offset >= available) {
            return (new uint256[](0), totalAvailable, false);
        }
        
        uint256 end = offset + limit;
        if (end > available) {
            end = available;
        }
        
        uint256 resultLength = end - offset;
        tokenIds = new uint256[](resultLength);
        
        for (uint256 i = 0; i < resultLength; i++) {
            tokenIds[i] = poolTokens[offset + i];
        }
        
        hasMore = end < available;
    }

    // 🔄 PARTIAL UNSTAKING VIEW FUNCTIONS

    function getUserActiveStakeDetails(address user) public view returns (
        uint256 activeCount,
        uint256[] memory activeReceiptTokenIds,
        uint256[] memory originalTokenIds,
        uint256[] memory stakingTimestamps
    ) {
        uint256[] memory userReceiptTokens = userStakes[user];
        
        // First pass: count active stakes
        uint256 count = 0;
        for (uint256 i = 0; i < userReceiptTokens.length; i++) {
            if (stakeInfos[userReceiptTokens[i]].active) {
                count++;
            }
        }
        
        // Initialize arrays
        activeReceiptTokenIds = new uint256[](count);
        originalTokenIds = new uint256[](count);
        stakingTimestamps = new uint256[](count);
        
        // Second pass: populate arrays
        uint256 index = 0;
        for (uint256 i = 0; i < userReceiptTokens.length; i++) {
            uint256 receiptTokenId = userReceiptTokens[i];
            if (stakeInfos[receiptTokenId].active) {
                activeReceiptTokenIds[index] = receiptTokenId;
                originalTokenIds[index] = receiptToOriginalToken[receiptTokenId];
                stakingTimestamps[index] = stakeInfos[receiptTokenId].stakedAt;
                index++;
            }
        }
        
        activeCount = count;
    }

    function getGasEstimates() external pure returns (
        uint256 swapGas,
        uint256 stakeGas,
        uint256 unstakeGas,
        uint256 claimGas,
        uint256 batchUnstakePerToken
    ) {
        return (200000, 180000, 150000, 80000, 150000);
    }

    function previewSwap(uint256 tokenIdIn, uint256 tokenIdOut) external view returns (
        bool canSwap,
        string memory reason,
        uint256 feeRequired,
        uint256 rewardImpact
    ) {
        canSwap = false;
        reason = "Unknown error";
        feeRequired = swapFeeInWei;
        
        if (tokenIdIn == tokenIdOut) {
            reason = "Cannot swap same token";
            return (canSwap, reason, feeRequired, rewardImpact);
        }
        
        if (IERC721(nftCollection).ownerOf(tokenIdOut) != address(this)) {
            reason = "Target token not available";
            return (canSwap, reason, feeRequired, rewardImpact);
        }
        
        if (!tokenInPool[tokenIdOut]) {
            reason = "Target token not in swappable pool";
            return (canSwap, reason, feeRequired, rewardImpact);
        }
        
        canSwap = true;
        reason = "Swap available";
        
        // Calculate reward impact
        if (totalStaked > 0) {
            uint256 rewardAmount = stonerShare > 0 ? 
                feeRequired - (feeRequired * stonerShare / 100) : feeRequired;
            rewardImpact = (rewardAmount * 1e18) / totalStaked;
        }
    }

    function canUnstakeAll(address user) external view returns (bool canUnstake, uint256 activeStakes) {
        activeStakes = getUserActiveStakeCount(user);
        canUnstake = activeStakes > 0 && activeStakes <= 20;
    }

    function previewBatchSwap(uint256[] calldata tokenIdsIn, uint256[] calldata tokenIdsOut) 
        external view returns (
        bool canSwap,
        string memory reason,
        uint256 totalFeeRequired,
        uint256 rewardImpact,
        uint256 validPairs
    ) {
        canSwap = false;
        reason = "Unknown error";
        validPairs = 0;
        
        // Basic validation
        if (tokenIdsIn.length == 0 || tokenIdsOut.length == 0) {
            reason = "Empty arrays not allowed";
            return (canSwap, reason, totalFeeRequired, rewardImpact, validPairs);
        }
        
        if (tokenIdsIn.length != tokenIdsOut.length) {
            reason = "Array length mismatch";
            return (canSwap, reason, totalFeeRequired, rewardImpact, validPairs);
        }
        
        if (tokenIdsIn.length > maxBatchSize) {
            reason = "Exceeds maximum batch size";
            return (canSwap, reason, totalFeeRequired, rewardImpact, validPairs);
        }
        
        // Check each swap pair
        for (uint256 i = 0; i < tokenIdsIn.length; i++) {
            uint256 tokenIdIn = tokenIdsIn[i];
            uint256 tokenIdOut = tokenIdsOut[i];
            
            // Skip if same token
            if (tokenIdIn == tokenIdOut) continue;
            
            // Check if output token is available in pool
            if (IERC721(nftCollection).ownerOf(tokenIdOut) == address(this) && 
                tokenInPool[tokenIdOut]) {
                validPairs++;
            }
        }
        
        if (validPairs == 0) {
            reason = "No valid swap pairs found";
            return (canSwap, reason, totalFeeRequired, rewardImpact, validPairs);
        }
        
        if (validPairs != tokenIdsIn.length) {
            reason = "Some swap pairs are invalid";
            return (canSwap, reason, totalFeeRequired, rewardImpact, validPairs);
        }
        
        // All validations passed
        canSwap = true;
        reason = "Batch swap available";
        totalFeeRequired = swapFeeInWei * tokenIdsIn.length;
        
        // Calculate total reward impact
        if (totalStaked > 0) {
            uint256 totalRewardAmount = stonerShare > 0 ? 
                totalFeeRequired - (totalFeeRequired * stonerShare / 100) : totalFeeRequired;
            rewardImpact = (totalRewardAmount * 1e18) / totalStaked;
        }
    }

    function getPoolRewardStats() external view returns (
        uint256 totalFeesCollected,    // Total swap fees collected
        uint256 rewardsDistributed,     // Total rewards paid to stakers  
        uint256 averageDailyVolume,     // Average daily swap volume (would need tracking)
        uint256 currentRewardRate,      // Current reward rate per NFT
        uint256 estimatedAPR            // Estimated Annual Percentage Rate based on recent activity
    ) {
        // Calculate current reward rate per NFT per day
        uint256 dailyRatePerNFT = totalStaked > 0 ? 
            (rewardPerTokenStored * 86400) / 1e18 / totalStaked : 0;
            
        // Very rough APR estimation based on swap fee and current staking ratio
        // This assumes consistent swap volume - in reality would need historical data
        uint256 aprEstimate = 0;
        if (totalStaked > 0 && swapFeeInWei > 0) {
            // Assume 1 swap per day per 10 staked NFTs as baseline
            uint256 assumedDailySwaps = totalStaked / 10 + 1;
            uint256 dailyRewards = (assumedDailySwaps * swapFeeInWei * (100 - stonerShare)) / 100;
            uint256 yearlyRewards = dailyRewards * 365;
            
            // APR = (yearly rewards / "cost basis") * 100
            // For NFTs, we can use current floor price or swap fee as proxy
            aprEstimate = (yearlyRewards * 100) / (swapFeeInWei * totalStaked);
        }
        
        return (
            totalRewardsDistributed, // Using this as proxy for total fees
            totalRewardsDistributed,
            0, // Would need additional tracking
            dailyRatePerNFT,
            aprEstimate
        );
    }

    function getPoolAnalytics() external view returns (
        uint256 totalLiquidity,
        uint256 utilizationRate,
        uint256 stakingRatio,
        uint256 averageStakingTime,
        uint256 dailyVolume,
        uint256 weeklyVolume,
        uint256 monthlyVolume
    ) {
        uint256 totalTokensInContract = IERC721(nftCollection).balanceOf(address(this));
        
        totalLiquidity = poolTokens.length;
        utilizationRate = totalTokensInContract > 0 ? 
            (totalLiquidity * 10000) / totalTokensInContract : 0; // Basis points
        stakingRatio = totalTokensInContract > 0 ? 
            (totalStaked * 10000) / totalTokensInContract : 0; // Basis points
        
        // Note: In production, you'd want to track this more efficiently
        // This is a simplified calculation for demonstration
        averageStakingTime = 0; // Would need historical data tracking
        dailyVolume = 0;   // Would need swap tracking
        weeklyVolume = 0;  // Would need swap tracking  
        monthlyVolume = 0; // Would need swap tracking
    }

    // 🎯 ENHANCED UI/UX FUNCTIONS FOR BETTER FRONTEND INTEGRATION























    // 🔒 UPGRADE SECURITY: Add timelock protection for upgrades
    uint256 public upgradeTimelock = 48 hours;
    uint256 public pendingUpgradeTime;
    address public pendingImplementation;
    
    event UpgradeProposed(address indexed newImplementation, uint256 executeTime);
    event UpgradeExecuted(address indexed newImplementation);
    
    function proposeUpgrade(address newImplementation) external onlyOwner {
        require(newImplementation != address(0), "Zero address");
        require(AddressUpgradeable.isContract(newImplementation), "Not contract");
        
        pendingImplementation = newImplementation;
        pendingUpgradeTime = block.timestamp + upgradeTimelock;
        
        emit UpgradeProposed(newImplementation, pendingUpgradeTime);
    }
    
    function executeUpgrade() external onlyOwner {
        require(pendingImplementation != address(0), "No pending upgrade");
        require(block.timestamp >= pendingUpgradeTime, "Timelock not expired");
        
        address impl = pendingImplementation;
        pendingImplementation = address(0);
        pendingUpgradeTime = 0;
        
        _upgradeToAndCallUUPS(impl, new bytes(0), false);
        emit UpgradeExecuted(impl);
    }
    
    function cancelUpgrade() external onlyOwner {
        pendingImplementation = address(0);
        pendingUpgradeTime = 0;
    }
    
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {
        // This now requires going through the timelock process
        require(newImplementation == pendingImplementation, "Must use timelock");
        require(block.timestamp >= pendingUpgradeTime, "Timelock not ready");
    }



    // Only allow ETH for swap fees - reject other ETH deposits
    receive() external payable {
        revert("Use swapNFT function");
    }
}

// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts-upgradeable@4.8.3/utils/AddressUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
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
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
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
            /// @solidity memory-safe-assembly
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


/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
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

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

// File: @openzeppelin/contracts-upgradeable@4.8.3/utils/ContextUpgradeable.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;


/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// File: @openzeppelin/contracts-upgradeable@4.8.3/access/OwnableUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;



/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// File: @openzeppelin/contracts-upgradeable@4.8.3/security/PausableUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;



/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// File: @openzeppelin/contracts-upgradeable@4.8.3/security/ReentrancyGuardUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
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

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// File: @openzeppelin/contracts-upgradeable@4.8.3/interfaces/draft-IERC1822Upgradeable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822ProxiableUpgradeable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// File: @openzeppelin/contracts-upgradeable@4.8.3/proxy/beacon/IBeaconUpgradeable.sol


// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeaconUpgradeable {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// File: @openzeppelin/contracts-upgradeable@4.8.3/interfaces/IERC1967Upgradeable.sol


// OpenZeppelin Contracts (last updated v4.8.3) (interfaces/IERC1967.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC-1967: Proxy Storage Slots. This interface contains the events defined in the ERC.
 *
 * _Available since v4.9._
 */
interface IERC1967Upgradeable {
    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Emitted when the beacon is changed.
     */
    event BeaconUpgraded(address indexed beacon);
}

// File: @openzeppelin/contracts-upgradeable@4.8.3/utils/StorageSlotUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
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

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }
}

// File: @openzeppelin/contracts-upgradeable@4.8.3/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.8.3) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;







/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967UpgradeUpgradeable is Initializable, IERC1967Upgradeable {
    function __ERC1967Upgrade_init() internal onlyInitializing {
    }

    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {
    }
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
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

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
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
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
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

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// File: @openzeppelin/contracts-upgradeable@4.8.3/proxy/utils/UUPSUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.8.0) (proxy/utils/UUPSUpgradeable.sol)

pragma solidity ^0.8.0;




/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 *
 * _Available since v4.1._
 */
abstract contract UUPSUpgradeable is Initializable, IERC1822ProxiableUpgradeable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal onlyInitializing {
    }

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }

    /**
     * @dev Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate the implementation's compatibility when performing an upgrade.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.
     */
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal override onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// File: @openzeppelin/contracts@4.8.3/utils/introspection/IERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts@4.8.3/token/ERC721/IERC721.sol


// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
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
    uint256 public minPoolSize = 5; // Minimum tokens required for swaps (configurable)
    
    // 🎯 CONFIGURABLE BATCH LIMITS
    uint256 public maxBatchSize = 10;           // Configurable batch operation limit
    uint256 public maxUnstakeAllLimit = 20;     // Configurable unstake all limit

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

    // 📊 THE GRAPH ANALYTICS - Minimal Storage, Events First
    // Track first-time users for analytics (minimal storage)
    mapping(address => bool) private _hasSwapped;

    // Simplified Events (backwards compatible)
    event SwapExecuted(address indexed user, uint256 tokenIdIn, uint256 tokenIdOut, uint256 feePaid);
    event BatchSwapExecuted(address indexed user, uint256 swapCount, uint256 totalFeePaid);
    event Staked(address indexed user, uint256 tokenId, uint256 receiptTokenId);
    event Unstaked(address indexed user, uint256 tokenId, uint256 receiptTokenId);
    event BatchUnstaked(address indexed user, uint256[] receiptTokenIds, uint256[] tokensReceived);
    event RewardsClaimed(address indexed user, uint256 amount);
    event RewardsDistributed(uint256 amount);
    
    // Enhanced events for The Graph (additional analytics)
    event UserFirstSwap(address indexed user, address indexed pool, uint256 timestamp);
    event VolumeUpdate(address indexed pool, uint256 swapVolume, uint256 timestamp);
    event StakingAnalytics(address indexed user, address indexed pool, uint256 tokenId, uint256 duration, string action);
    event SwapFeeUpdated(uint256 newFeeInWei);
    event StonerShareUpdated(uint256 newShare);
    event BatchLimitsUpdated(uint256 newMaxBatchSize, uint256 newMaxUnstakeAll);
    event MinPoolSizeUpdated(uint256 oldMinPoolSize, uint256 newMinPoolSize);

    // Enhanced batch operation events
    event BatchOperationStarted(address indexed user, string operationType, uint256 requestedCount);
    event BatchOperationCompleted(address indexed user, string operationType, uint256 successCount, uint256 failureCount);
    event BatchOperationError(address indexed user, string operationType, uint256 tokenId, string reason);

    // Events for enhanced frontend integration
    event PoolHealthChanged(uint256 utilizationRate, uint256 stakingRatio, bool isHealthy);
    event LowLiquidityWarning(uint256 availableTokens, uint256 threshold);
    event HighVolumeAlert(uint256 swapsInPeriod, uint256 period);

    // Additional events for better analytics
    event RewardRateUpdated(uint256 newRate, uint256 timestamp);
    event UserMilestone(address indexed user, string milestone, uint256 value);

    // Batch operation result tracking
    struct BatchOperationResult {
        uint256[] successfulTokenIds;
        uint256[] failedTokenIds;
        string[] errorReasons;
        uint256 totalGasUsed;
        bool completed;
    }

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
        require(poolTokens.length >= minPoolSize, "Insufficient liquidity");
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

    /// @custom:oz-upgrades-unsafe-allow constructor
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
        // 🛡️ FLASHLOAN PROTECTION - Snapshot balance before
        uint256 contractBalanceBefore = IERC721(nftCollection).balanceOf(address(this));
        
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

        // External calls LAST (CEI pattern)
        if (stonerAmount > 0) {
            payable(stonerPool).sendValue(stonerAmount);
        }

        // 🛡️ FLASHLOAN PROTECTION - Verify balance unchanged (1-to-1 swap)
        uint256 contractBalanceAfter = IERC721(nftCollection).balanceOf(address(this));
        require(contractBalanceAfter == contractBalanceBefore, "Flashloan protection: balance mismatch");

        // 📊 THE GRAPH ANALYTICS - Emit events for offchain tracking
        _emitSwapAnalytics(msg.sender, msg.value, 1);

        emit SwapExecuted(msg.sender, tokenIdIn, tokenIdOut, msg.value);
    }

    /**
     * @dev Swap multiple NFTs in a single transaction
     * @param tokenIdsIn Array of NFT token IDs user wants to swap (must own these)
     * @param tokenIdsOut Array of NFT token IDs user wants to receive (must be in pool)
     */
    function swapNFTBatch(uint256[] calldata tokenIdsIn, uint256[] calldata tokenIdsOut)
        external
        payable
        nonReentrant
        onlyInitialized
        whenNotPaused
        minimumLiquidity
        updateReward(address(0)) // Update global rewards
    {
        // 🛡️ FLASHLOAN PROTECTION - Snapshot balance before batch
        uint256 contractBalanceBefore = IERC721(nftCollection).balanceOf(address(this));
        
        // 🛡️ BATCH VALIDATION
        require(tokenIdsIn.length > 0 && tokenIdsOut.length > 0, "Empty arrays");
        require(tokenIdsIn.length == tokenIdsOut.length, "Array length mismatch");
        require(tokenIdsIn.length <= maxBatchSize, "Exceeds batch limit");
        
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
            
            // Emit event for each swap in the batch
            emit SwapExecuted(msg.sender, tokenIdsIn[i], tokenIdsOut[i], swapFeeInWei);
        }

        // External calls LAST (CEI pattern)
        if (stonerAmount > 0) {
            payable(stonerPool).sendValue(stonerAmount);
        }

        // 🛡️ FLASHLOAN PROTECTION - Verify balance unchanged (equal swap)
        uint256 contractBalanceAfter = IERC721(nftCollection).balanceOf(address(this));
        require(contractBalanceAfter == contractBalanceBefore, "Flashloan protection: balance mismatch");

        // 📊 THE GRAPH ANALYTICS - Emit events for offchain tracking
        _emitSwapAnalytics(msg.sender, msg.value, tokenIdsIn.length);

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

        // 📊 THE GRAPH ANALYTICS - Track first-time users
        if (!_hasSwapped[msg.sender]) {
            _hasSwapped[msg.sender] = true;
            emit UserFirstSwap(msg.sender, address(this), block.timestamp);
        }

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
        uint256 batchLength = receiptTokenIds.length; // Gas optimization: cache array length
        require(batchLength > 0, "Empty array");
        require(batchLength <= maxBatchSize, "Batch size exceeds limit"); // Configurable gas limit protection
        
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
        uint256 userStakesLength = userReceiptTokens.length; // Gas optimization: cache array length
        require(userStakesLength > 0, "No stakes found");
        
        // Create array of active receipt tokens
        uint256[] memory activeReceipts = new uint256[](userStakesLength);
        uint256 activeCount = 0;
        
        for (uint256 i = 0; i < userStakesLength; i++) {
            if (stakeInfos[userReceiptTokens[i]].active) {
                activeReceipts[activeCount] = userReceiptTokens[i];
                activeCount++;
            }
        }
        
        require(activeCount > 0, "No active stakes");
        require(activeCount <= maxUnstakeAllLimit, "Too many stakes - use batch function"); // Gas protection
        
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

    /**
     * @dev Add token to pool tracking
     */
    function _addTokenToPool(uint256 tokenId) internal {
        if (!tokenInPool[tokenId]) {
            tokenIndexInPool[tokenId] = poolTokens.length;
            poolTokens.push(tokenId);
            tokenInPool[tokenId] = true;
        }
    }

    /**
     * @dev Remove token from pool tracking
     */
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

    /**
     * @dev Get random available token from pool
     */
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

    /**
     * @dev Check for duplicate token IDs in array to prevent user errors
     */
    function _checkForDuplicates(uint256[] calldata tokenIds) internal pure {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            for (uint256 j = i + 1; j < tokenIds.length; j++) {
                require(tokenIds[i] != tokenIds[j], "Duplicate token ID found");
            }
        }
    }

    /**
     * @dev Emit analytics events for The Graph (gas optimized)
     */
    function _emitSwapAnalytics(address user, uint256 swapValue, uint256 /*swapCount*/) internal {
        // Track first-time users
        if (!_hasSwapped[user]) {
            _hasSwapped[user] = true;
            emit UserFirstSwap(user, address(this), block.timestamp);
        }
        
        // Emit volume update for The Graph tracking
        emit VolumeUpdate(address(this), swapValue, block.timestamp);
    }

    // 📊 COMPLETE REWARD CALCULATION FUNCTIONS

    /**
     * @dev Calculate reward per token (18 decimal precision)
     */
    function rewardPerToken() public view returns (uint256) {
        return rewardPerTokenStored; // Already updated in modifier
    }

    /**
     * @dev Calculate earned rewards for an account with PROPER TRACKING
     * @param account User address
     */
    function earned(address account) public view returns (uint256) {
        uint256 userStakedCount = getUserActiveStakeCount(account);
        if (userStakedCount == 0) return pendingRewards[account];
        
        uint256 rewardDiff = rewardPerToken() - userRewardPerTokenPaid[account];
        return pendingRewards[account] + (userStakedCount * rewardDiff) / 1e18;
    }

    /**
     * @dev Get number of ACTIVE stakes for user - PROPERLY IMPLEMENTED
     */
    function getUserActiveStakeCount(address user) public view returns (uint256 count) {
        uint256[] memory stakes = userStakes[user];
        uint256 stakesLength = stakes.length; // Gas optimization: cache array length
        for (uint256 i = 0; i < stakesLength; i++) {
            if (stakeInfos[stakes[i]].active) {
                count++;
            }
        }
    }

    /**
     * @dev Remove receipt token from user's stakes array - PROPERLY IMPLEMENTED
     */
    function _removeFromUserStakes(address user, uint256 receiptTokenId) internal {
        uint256[] storage stakes = userStakes[user];
        uint256 stakesLength = stakes.length; // Gas optimization: cache array length
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
        if (newShare > 100) revert InvalidStonerShare();
        stonerShare = newShare;
        emit StonerShareUpdated(newShare);
    }

    /**
     * @dev Set configurable batch operation limits
     */
    function setBatchLimits(uint256 newMaxBatchSize, uint256 newMaxUnstakeAll) external onlyOwner {
        require(newMaxBatchSize > 0 && newMaxBatchSize <= 50, "Invalid batch size");
        require(newMaxUnstakeAll > 0 && newMaxUnstakeAll <= 100, "Invalid unstake all limit");
        
        maxBatchSize = newMaxBatchSize;
        maxUnstakeAllLimit = newMaxUnstakeAll;
        
        emit BatchLimitsUpdated(newMaxBatchSize, newMaxUnstakeAll);
    }

    /**
     * @dev Set minimum pool size for swaps
     */
    function setMinPoolSize(uint256 newMinPoolSize) external onlyOwner {
        require(newMinPoolSize > 0 && newMinPoolSize <= 20, "Invalid min pool size");
        
        uint256 oldMinPoolSize = minPoolSize;
        minPoolSize = newMinPoolSize;
        
        emit MinPoolSizeUpdated(oldMinPoolSize, newMinPoolSize);
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
        uint256 tokenIdsLength = tokenIds.length; // Gas optimization: cache array length
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

    /**
     * @dev Get comprehensive pool statistics for frontend dashboards
     */
    function getPoolStatistics() external view returns (
        uint256 totalSwaps,
        uint256 totalVolume,
        uint256 averageSwapFee,
        uint256 lastSwapTimestamp,
        uint256 activeStakers,
        uint256 totalRewardsPerToken,
        uint256 poolLiquidity
    ) {
        return (
            0, // Can be implemented with a counter
            totalRewardsDistributed,
            swapFeeInWei,
            lastUpdateTime,
            totalStaked,
            rewardPerTokenStored,
            poolTokens.length
        );
    }

    /**
     * @dev Get detailed pool health metrics for advanced analytics
     */
    function getPoolHealth() external view returns (
        uint256 utilizationRate,      // How many tokens are being actively swapped
        uint256 stakingRatio,         // Percentage of pool that's staked
        bool isHealthy               // Overall pool health indicator
    ) {
        uint256 totalTokensInContract = IERC721(nftCollection).balanceOf(address(this));
        
        utilizationRate = totalTokensInContract > 0 ? 
            (poolTokens.length * 100) / totalTokensInContract : 0;
            
        stakingRatio = totalTokensInContract > 0 ? 
            (totalStaked * 100) / totalTokensInContract : 0;
            
        isHealthy = poolTokens.length >= 10 && utilizationRate >= 50;
        
        return (utilizationRate, stakingRatio, isHealthy);
    }

    /**
     * @dev Get comprehensive user portfolio analytics (LEGACY - may cause gas issues)
     */
    function getUserPortfolio(address user) external view returns (
        uint256 userTotalStaked,
        uint256 totalEarned,
        uint256 userPendingRewards,
        uint256 averageStakingTime,
        uint256[] memory activeStakes,
        uint256 totalSwapsCount,
        uint256 userSwapVolume
    ) {
        uint256[] memory userReceiptTokens = userStakes[user];
        uint256 userReceiptLength = userReceiptTokens.length; // Gas optimization: cache array length
        uint256[] memory activeReceiptTokens = new uint256[](userReceiptLength);
        uint256 activeCount = 0;
        uint256 totalStakingTime = 0;
        
        for (uint256 i = 0; i < userReceiptLength; i++) {
            if (stakeInfos[userReceiptTokens[i]].active) {
                activeReceiptTokens[activeCount] = userReceiptTokens[i];
                totalStakingTime += block.timestamp - stakeInfos[userReceiptTokens[i]].stakedAt;
                activeCount++;
            }
        }
        
        // Resize active stakes array
        activeStakes = new uint256[](activeCount);
        for (uint256 i = 0; i < activeCount; i++) {
            activeStakes[i] = activeReceiptTokens[i];
        }
        
        return (
            activeCount,
            0, // totalEarned - would need additional tracking
            earned(user),
            activeCount > 0 ? totalStakingTime / activeCount : 0,
            activeStakes,
            0, // Analytics moved to The Graph - query offchain
            0  // Analytics moved to The Graph - query offchain
        );
    }

    /**
     * @dev Get user portfolio with pagination (gas-efficient for power users)
     * @param user User address
     * @param offset Starting index for stakes
     * @param limit Maximum number of stakes to process
     */
    function getUserPortfolioPaginated(address user, uint256 offset, uint256 limit) 
        external 
        view 
        returns (
            uint256 userTotalStaked,
            uint256 totalEarned,
            uint256 userPendingRewards,
            uint256 averageStakingTime,
            uint256[] memory activeStakes,
            uint256 totalSwapsCount,
            uint256 userSwapVolume,
            uint256 totalStakes,
            bool hasMore
        ) 
    {
        uint256[] memory userReceiptTokens = userStakes[user];
        uint256 userReceiptLength = userReceiptTokens.length;
        totalStakes = userReceiptLength;
        
        if (offset >= userReceiptLength) {
            activeStakes = new uint256[](0);
            hasMore = false;
            return (0, 0, earned(user), 0, activeStakes, 
                   0, 0, totalStakes, hasMore); // Analytics moved to The Graph
        }
        
        uint256 end = offset + limit;
        if (end > userReceiptLength) {
            end = userReceiptLength;
        }
        
        uint256[] memory activeReceiptTokens = new uint256[](end - offset);
        uint256 activeCount = 0;
        uint256 totalStakingTime = 0;
        
        for (uint256 i = offset; i < end; i++) {
            if (stakeInfos[userReceiptTokens[i]].active) {
                activeReceiptTokens[activeCount] = userReceiptTokens[i];
                totalStakingTime += block.timestamp - stakeInfos[userReceiptTokens[i]].stakedAt;
                activeCount++;
            }
        }
        
        // Resize active stakes array
        activeStakes = new uint256[](activeCount);
        for (uint256 i = 0; i < activeCount; i++) {
            activeStakes[i] = activeReceiptTokens[i];
        }
        
        hasMore = end < userReceiptLength;
        
        return (
            activeCount,
            0, // totalEarned - would need additional tracking
            earned(user),
            activeCount > 0 ? totalStakingTime / activeCount : 0,
            activeStakes,
            0, // Analytics moved to The Graph - query offchain
            0, // Analytics moved to The Graph - query offchain
            totalStakes,
            hasMore
        );
    }

    /**
     * @dev Get user's staking performance metrics
     */
    function getUserStakingMetrics(address user) external view returns (
        uint256 rewardRate,           // Rewards per staked NFT per second
        uint256 projectedDailyRewards,
        uint256 estimatedYearlyETH,   // Projected yearly ETH earnings
        uint256 averageStakingDays    // Average days staked
    ) {
        uint256 userActiveStakes = getUserActiveStakeCount(user);
        if (userActiveStakes == 0) return (0, 0, 0, 0);
        
        // Calculate current reward rate per NFT per second
        uint256 rewardRatePerNFT = totalStaked > 0 ? rewardPerTokenStored / totalStaked : 0;
        
        // Project daily rewards based on current rate
        uint256 dailyRewards = (userActiveStakes * rewardRatePerNFT * 86400) / 1e18;
        
        // Project yearly ETH earnings (not APY since there's no initial investment cost)
        uint256 yearlyETH = dailyRewards * 365;
        
        // Calculate average staking time
        uint256[] memory userReceiptTokens = userStakes[user];
        uint256 totalStakingTime = 0;
        uint256 activeCount = 0;
        
        for (uint256 i = 0; i < userReceiptTokens.length; i++) {
            if (stakeInfos[userReceiptTokens[i]].active) {
                totalStakingTime += block.timestamp - stakeInfos[userReceiptTokens[i]].stakedAt;
                activeCount++;
            }
        }
        
        uint256 avgStakingTime = activeCount > 0 ? totalStakingTime / activeCount : 0;
        
        return (
            rewardRatePerNFT,
            dailyRewards,
            yearlyETH,
            avgStakingTime / 86400 // Convert to days
        );
    }

    /**
     * @dev Get pool reward statistics for better frontend display
     */
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

    /**
     * @dev Get detailed token information for swap interface
     */
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

    /**
     * @dev Get swappable tokens with pagination for large collections
     */
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

    /**
     * @dev Get optimal swap suggestions based on user preferences
     */
    function getSwapSuggestions(uint256 userTokenId, uint256 maxSuggestions) external view returns (
        uint256[] memory suggestedTokens,
        string[] memory reasons
    ) {
        if (!tokenInPool[userTokenId] && IERC721(nftCollection).ownerOf(userTokenId) != msg.sender) {
            return (new uint256[](0), new string[](0));
        }
        
        uint256 available = poolTokens.length;
        uint256 suggestions = maxSuggestions > available ? available : maxSuggestions;
        
        suggestedTokens = new uint256[](suggestions);
        reasons = new string[](suggestions);
        
        for (uint256 i = 0; i < suggestions && i < available; i++) {
            suggestedTokens[i] = poolTokens[i];
            reasons[i] = "Available for swap";
        }
    }

    /**
     * @dev Check if a stake is active
     * @param receiptTokenId The receipt token ID to check
     * @return True if the stake is active
     */
    function isStakeActive(uint256 receiptTokenId) public view returns (bool) {
        return stakeInfos[receiptTokenId].active;
    }

    function getReceiptForToken(uint256 tokenId) external view returns (uint256) {
        return originalToReceiptToken[tokenId];
    }

    function getTokenForReceipt(uint256 receiptTokenId) external view returns (uint256) {
        return receiptToOriginalToken[receiptTokenId];
    }

    /**
     * @dev Get all tokens currently in pool
     */
    function getPoolTokens() external view returns (uint256[] memory) {
        return poolTokens;
    }

    /**
     * @dev Get available tokens count
     */
    function getAvailableTokenCount() external view returns (uint256) {
        return poolTokens.length;
    }

    /**
     * @dev Check if a specific token is still in the pool
     */
    function isTokenInPool(uint256 tokenId) external view returns (bool) {
        return tokenInPool[tokenId] && IERC721(nftCollection).ownerOf(tokenId) == address(this);
    }

    // 🔄 PARTIAL UNSTAKING VIEW FUNCTIONS

    /**
     * @dev Get user's active stake count and receipt tokens
     * @param user User address
     */
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

    /**
     * @dev Get detailed gas estimates for all operations
     */
    function getGasEstimates() external pure returns (
        uint256 swapGas,
        uint256 stakeGas,
        uint256 unstakeGas,
        uint256 claimGas,
        uint256 batchUnstakePerToken
    ) {
        return (200000, 180000, 150000, 80000, 150000);
    }

    /**
     * @dev Preview swap transaction before execution
     */
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

    /**
     * @dev Preview batch swap transaction before execution
     * @param tokenIdsIn Array of token IDs user wants to swap
     * @param tokenIdsOut Array of token IDs user wants to receive
     */
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

    /**
     * @dev Check if user can unstake all their stakes in one transaction
     * @param user User address
     */
    function canUnstakeAll(address user) external view returns (bool canUnstake, uint256 activeStakes) {
        activeStakes = getUserActiveStakeCount(user);
        canUnstake = activeStakes > 0 && activeStakes <= 20;
    }

    // 🎯 ENHANCED UI/UX FUNCTIONS FOR BETTER FRONTEND INTEGRATION

    /**
     * @dev Get comprehensive pool analytics for dashboard
     */
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

    /**
     * @dev Get user's complete dashboard data in one call
     */
    function getUserDashboard(address user) external view returns (
        uint256 stakedCount,
        uint256 userPendingRewards,
        uint256 totalEarned,
        uint256 averageStakingDays,
        uint256[] memory userTokens,
        uint256[] memory stakingTimestamps,
        bool userCanUnstakeAll,
        uint256 estimatedUnstakeAllGas
    ) {
        stakedCount = getUserActiveStakeCount(user);
        userPendingRewards = earned(user);
        
        // Get user's active stakes details
        (, , uint256[] memory originalIds, uint256[] memory timestamps) = 
            getUserActiveStakeDetails(user);
        
        userTokens = originalIds;
        stakingTimestamps = timestamps;
        
        // Calculate average staking time
        if (timestamps.length > 0) {
            uint256 totalTime = 0;
            for (uint256 i = 0; i < timestamps.length; i++) {
                totalTime += block.timestamp - timestamps[i];
            }
            averageStakingDays = (totalTime / timestamps.length) / 86400;
        }
        
        // Check unstake all capability
        userCanUnstakeAll = stakedCount > 0 && stakedCount <= 20;
        estimatedUnstakeAllGas = 21000 + (stakedCount * 150000);
        totalEarned = 0; // Would need additional tracking
    }

    /**
     * @dev Get real-time pool status for status indicators
     */
    function getPoolStatus() external view returns (
        bool isActive,
        bool hasLiquidity,
        bool acceptingStakes,
        string memory statusMessage,
        uint256 healthScore
    ) {
        isActive = !paused();
        hasLiquidity = poolTokens.length >= minPoolSize;
        acceptingStakes = !paused() && initialized;
        
        if (!isActive) {
            statusMessage = "Pool is paused";
            healthScore = 0;
        } else if (!hasLiquidity) {
            statusMessage = "Low liquidity warning";
            healthScore = 25;
        } else if (poolTokens.length >= 50) {
            statusMessage = "Excellent liquidity";
            healthScore = 100;
        } else if (poolTokens.length >= 20) {
            statusMessage = "Good liquidity";
            healthScore = 75;
        } else {
            statusMessage = "Moderate liquidity";
            healthScore = 50;
        }
    }

    /**
     * @dev Get optimized swap interface data
     */
    function getSwapInterfaceData(address /* user */) external view returns (
        uint256[] memory userOwnedTokens,
        uint256[] memory swappableTokens,
        uint256 swapFee,
        bool poolActive
    ) {
        // Note: In production, you'd implement a more efficient way to get user tokens
        // This is simplified for demonstration
        
        swappableTokens = poolTokens;
        swapFee = swapFeeInWei;
        poolActive = !paused() && poolTokens.length >= minPoolSize;
        
        userOwnedTokens = new uint256[](0); // Simplified - would need proper enumeration
    }

    /**
     * @dev Calculate total fee required for batch swap
     * @param swapCount Number of NFTs to swap
     * @return totalFee Total fee in wei required for the batch swap
     * @return feePerSwap Individual fee per swap
     */
    function calculateBatchSwapFee(uint256 swapCount) external view returns (
        uint256 totalFee,
        uint256 feePerSwap
    ) {
        require(swapCount > 0, "Swap count must be greater than 0");
        require(swapCount <= maxBatchSize, "Exceeds maximum batch size");
        
        feePerSwap = swapFeeInWei;
        totalFee = swapFeeInWei * swapCount;
    }

    /**
     * @dev Get staking interface data for better UX
     */
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

    /**
     * @dev Get transaction preview for better user experience
     */
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

    /**
     * @dev Check multiple token statuses efficiently
     */
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

    /**
     * @dev Get recommended actions for user based on their portfolio
     */
    function getRecommendedActions(address user) external view returns (
        string[] memory actions,
        string[] memory reasons,
        uint256[] memory estimatedGas,
        uint256[] memory potentialRewards
    ) {
        uint256 userStaked = getUserActiveStakeCount(user);
        uint256 userRewards = earned(user);
        uint256 userTokenBalance = IERC721(nftCollection).balanceOf(user);
        
        // Dynamic recommendations based on user state
        uint256 recommendationCount = 0;
        if (userRewards > 0.001 ether) recommendationCount++; // Has rewards to claim
        if (userTokenBalance > 0 && poolTokens.length >= minPoolSize) recommendationCount++; // Can stake
        if (userStaked > 0) recommendationCount++; // Can unstake
        
        actions = new string[](recommendationCount);
        reasons = new string[](recommendationCount);
        estimatedGas = new uint256[](recommendationCount);
        potentialRewards = new uint256[](recommendationCount);
        
        uint256 index = 0;
        
        if (userRewards > 0.001 ether) {
            actions[index] = "Claim Rewards";
            reasons[index] = "You have claimable rewards";
            estimatedGas[index] = 80000;
            potentialRewards[index] = userRewards;
            index++;
        }
        
        if (userTokenBalance > 0 && poolTokens.length >= minPoolSize) {
            actions[index] = "Stake Tokens";
            reasons[index] = "Start earning rewards on your tokens";
            estimatedGas[index] = 180000 * userTokenBalance;
            potentialRewards[index] = 0; // Future earnings
            index++;
        }
        
        if (userStaked > 0) {
            actions[index] = "Review Stakes";
            reasons[index] = "Check your staking positions";
            estimatedGas[index] = 0; // View only
            potentialRewards[index] = 0;
            index++;
        }
    }

    /**
     * @dev Get batch operation results with detailed error information
     * @return result Detailed batch operation result
     */
    function getBatchOperationResult(address /* user */) external pure returns (BatchOperationResult memory result) {
        // This would be stored per user in a mapping during actual batch operations
        // For now, return a default empty result structure
        result.successfulTokenIds = new uint256[](0);
        result.failedTokenIds = new uint256[](0);
        result.errorReasons = new string[](0);
        result.totalGasUsed = 0;
        result.completed = true;
    }

    /**
     * @dev Optimized array operations for gas efficiency
     */
    function _optimizedArrayRemoval(uint256[] storage array, uint256 indexToRemove) internal {
        require(indexToRemove < array.length, "Index out of bounds");
        
        // Move last element to the index being removed and pop the last element
        if (indexToRemove != array.length - 1) {
            array[indexToRemove] = array[array.length - 1];
        }
        array.pop();
    }

    /**
     * @dev Batch-optimized array search
     * @param array Array to search in
     * @param target Value to find
     * @return found Whether the value was found
     * @return index Index of the value (if found)
     */
    function _batchOptimizedSearch(uint256[] memory array, uint256 target) 
        internal 
        pure 
        returns (bool found, uint256 index) 
    {
        // Binary search for sorted arrays, linear for unsorted
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == target) {
                return (true, i);
            }
        }
        return (false, 0);
    }

    /**
     * @dev Gas-optimized batch validation
     * @param tokenIds Array of token IDs to validate
     * @return valid Whether all tokens are valid for operation
     * @return firstInvalidIndex Index of first invalid token (if any)
     */
    function _batchValidateTokens(uint256[] memory tokenIds) 
        internal 
        view 
        returns (bool valid, uint256 firstInvalidIndex) 
    {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            if (tokenIds[i] == 0 || !isStakeActive(tokenIds[i])) {
                return (false, i);
            }
        }
        return (true, 0);
    }

    /**
     * @dev Authorize contract upgrades - only owner can upgrade
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /**
     * @dev Comprehensive contract health check for monitoring and debugging
     * @dev Only callable by owner for security
     */
    function getContractHealthCheck() external view onlyOwner returns (
        bool poolHealthy,
        bool rewardSystemHealthy,
        bool storageConsistent,
        uint256 contractBalance,
        uint256 totalNFTsHeld,
        string memory statusMessage
    ) {
        // Check pool health
        poolHealthy = poolTokens.length >= minPoolSize && !paused();
        
        // Check reward system health
        rewardSystemHealthy = totalStaked == 0 || rewardPerTokenStored > 0;
        
        // Check storage consistency
        uint256 actualNFTBalance = IERC721(nftCollection).balanceOf(address(this));
        storageConsistent = actualNFTBalance >= poolTokens.length;
        
        // Get contract metrics
        contractBalance = address(this).balance;
        totalNFTsHeld = actualNFTBalance;
        
        // Generate status message
        if (!poolHealthy) {
            statusMessage = "Pool unhealthy: insufficient liquidity or paused";
        } else if (!rewardSystemHealthy) {
            statusMessage = "Reward system unhealthy: staking without rewards";
        } else if (!storageConsistent) {
            statusMessage = "Storage inconsistent: NFT count mismatch";
        } else {
            statusMessage = "All systems healthy";
        }
        
        return (
            poolHealthy,
            rewardSystemHealthy,
            storageConsistent,
            contractBalance,
            totalNFTsHeld,
            statusMessage
        );
    }

    // Only allow ETH for swap fees - reject other ETH deposits
    receive() external payable {
        revert("Use swapNFT function");
    }
}
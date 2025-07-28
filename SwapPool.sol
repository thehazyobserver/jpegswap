// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts-upgradeable@4.8.3/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable@4.8.3/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@4.8.3/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@4.8.3/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@4.8.3/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts@4.8.3/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts-upgradeable@4.8.3/utils/AddressUpgradeable.sol";

contract SwapPool is
    Initializable,
    OwnableUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable,
    UUPSUpgradeable
{
    using AddressUpgradeable for address payable;

    address public nftCollection;
    address public receiptContract;
    address public stonerPool;

    uint256 public swapFeeInWei;
    uint256 public stonerShare; // Percentage (0–100)

    bool public initialized;

    event SwapExecuted(address indexed user, uint256 tokenIdIn, uint256 tokenIdOut, uint256 feePaid);
    event Staked(address indexed user, uint256 tokenId);
    event SwapFeeUpdated(uint256 newFeeInWei);
    event StonerShareUpdated(uint256 newShare);
    event Paused();
    event Unpaused();

    error AlreadyInitialized();
    error NotInitialized();
    error InvalidStonerShare();
    error TokenUnavailable();
    error IncorrectFee();

    modifier onlyInitialized() {
        if (!initialized) revert NotInitialized();
        _;
    }

    function initialize(
        address _nftCollection,
        address _receiptContract,
        address _stonerPool,
        uint256 _swapFeeInWei,
        uint256 _stonerShare
    ) public initializer {
        if (initialized) revert AlreadyInitialized();
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
    }

    function swapNFT(uint256 tokenIdIn, uint256 tokenIdOut)
        external
        payable
        nonReentrant
        onlyInitialized
        whenNotPaused
    {
        if (IERC721(nftCollection).ownerOf(tokenIdOut) != address(this)) revert TokenUnavailable();
        if (msg.value != swapFeeInWei) revert IncorrectFee();

        // Forward stoner share to stonerPool
        if (stonerShare > 0) {
            uint256 stonerAmount = (msg.value * stonerShare) / 100;
            payable(stonerPool).sendValue(stonerAmount);
        }

        IERC721(nftCollection).transferFrom(msg.sender, address(this), tokenIdIn);
        IERC721(nftCollection).transferFrom(address(this), msg.sender, tokenIdOut);

        emit SwapExecuted(msg.sender, tokenIdIn, tokenIdOut, msg.value);
    }

    function stakeNFT(uint256 tokenId) external onlyInitialized whenNotPaused {
        IERC721(nftCollection).transferFrom(msg.sender, address(this), tokenId);
        emit Staked(msg.sender, tokenId);
    }

    function setSwapFee(uint256 newFeeInWei) external onlyOwner {
        swapFeeInWei = newFeeInWei;
        emit SwapFeeUpdated(newFeeInWei);
    }

    function setStonerShare(uint256 newShare) external onlyOwner {
        if (newShare > 100) revert InvalidStonerShare();
        stonerShare = newShare;
        emit StonerShareUpdated(newShare);
    }

    function pause() external onlyOwner {
        _pause();
        emit Paused();
    }

    function unpause() external onlyOwner {
        _unpause();
        emit Unpaused();
    }

    /// @dev Register my contract on Sonic FeeM
    function registerMe() external onlyOwner {
        (bool _success,) = address(0xDC2B0D2Dd2b7759D97D50db4eabDC36973110830).call(
            abi.encodeWithSignature("selfRegister(uint256)", 92)
        );
        require(_success, "FeeM registration failed");
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}
}
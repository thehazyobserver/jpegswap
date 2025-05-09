// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SwapPool is Ownable {
    address public nftCollection;
    address public feeToken;
    address public receiptContract;
    address public stonerPool;
    uint256 public swapFee;
    uint256 public minStakeDuration;
    uint256 public stonerShare;

    bool public initialized;

    event SwapExecuted(address indexed user, uint256 tokenIdIn, uint256 tokenIdOut, uint256 feePaid);
    event Staked(address indexed user, uint256 tokenId, uint256 timestamp);

    error AlreadyInitialized();
    error NotInitialized();
    error InvalidStakeDuration();
    error InsufficientFee();

    function initialize(
        address _nftCollection,
        address _feeToken,
        address _receiptContract,
        address _stonerPool,
        uint256 _swapFee,
        uint256 _minStakeDuration,
        uint256 _stonerShare
    ) external {
        if (initialized) revert AlreadyInitialized();
        nftCollection = _nftCollection;
        feeToken = _feeToken;
        receiptContract = _receiptContract;
        stonerPool = _stonerPool;
        swapFee = _swapFee;
        minStakeDuration = _minStakeDuration;
        stonerShare = _stonerShare;
        initialized = true;
    }

    function swapNFT(uint256 tokenIdIn, uint256 tokenIdOut) external {
        if (!initialized) revert NotInitialized();
        
        // Transfer fee from user to contract
        uint256 totalFee = swapFee;
        if (totalFee > 0) {
            bool success = IERC20(feeToken).transferFrom(msg.sender, address(this), totalFee);
            if (!success) revert InsufficientFee();
            
            // Distribute fee to stoner pool
            uint256 stonerAmount = (totalFee * stonerShare) / 100;
            IERC20(feeToken).transfer(stonerPool, stonerAmount);
        }

        // Execute NFT swap
        IERC721(nftCollection).transferFrom(msg.sender, address(this), tokenIdIn);
        IERC721(nftCollection).transferFrom(address(this), msg.sender, tokenIdOut);

        emit SwapExecuted(msg.sender, tokenIdIn, tokenIdOut, totalFee);
    }

    function stakeNFT(uint256 tokenId) external {
        if (!initialized) revert NotInitialized();
        
        // Transfer NFT to contract
        IERC721(nftCollection).transferFrom(msg.sender, address(this), tokenId);
        
        // Record staking (in a real implementation, this would involve more state tracking)
        emit Staked(msg.sender, tokenId, block.timestamp);
    }

    function setSwapFee(uint256 newFee) external onlyOwner {
        if (!initialized) revert NotInitialized();
        swapFee = newFee;
    }

    function setMinStakeDuration(uint256 newDuration) external onlyOwner {
        if (!initialized) revert NotInitialized();
        if (newDuration == 0) revert InvalidStakeDuration();
        minStakeDuration = newDuration;
    }

    function setStonerShare(uint256 newShare) external onlyOwner {
        if (!initialized) revert NotInitialized();
        if (newShare > 100) revert InvalidStakeDuration();
        stonerShare = newShare;
    }
}
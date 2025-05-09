// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts-upgradeable/v4.8.3/contracts/proxy/utils/Initializable.sol";
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts-upgradeable/v4.8.3/contracts/access/OwnableUpgradeable.sol";
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts-upgradeable/v4.8.3/contracts/proxy/utils/UUPSUpgradeable.sol";
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts-upgradeable/v4.8.3/contracts/token/ERC721/IERC721Upgradeable.sol";
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts-upgradeable/v4.8.3/contracts/token/ERC721/utils/ERC721HolderUpgradeable.sol";
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts-upgradeable/v4.8.3/contracts/token/ERC20/IERC20Upgradeable.sol";

interface IStakeReceipt {
    function mint(address to, uint256 tokenId) external;
    function burn(uint256 tokenId) external;
}

interface IStonerFeePool {
    function notifyReward(uint256 amount) external;
}

contract SwapPool is Initializable, OwnableUpgradeable, ERC721HolderUpgradeable, UUPSUpgradeable {
    IERC721Upgradeable public nftCollection;
    IERC20Upgradeable public feeToken;
    IStakeReceipt public receipt;
    IStonerFeePool public stonerPool;

    uint256 public swapFee;
    uint256 public minStakeDuration;
    uint256 public stonerFeeShare;

    struct StakeInfo {
        address staker;
        uint256 timestamp;
    }

    mapping(uint256 => StakeInfo) public stakedNFTs;
    mapping(address => uint256[]) public stakerToTokenIds;

    uint256[] public poolNFTs;
    mapping(uint256 => bool) public isInPool;

    mapping(address => uint256) public rewards;
    uint256 public totalStaked;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _nft,
        address _feeToken,
        address _receipt,
        address _stonerPool,
        uint256 _swapFee,
        uint256 _minStakeDuration,
        uint256 _stonerFeeShare
    ) public initializer {
        __Ownable_init();
        __ERC721Holder_init();
        __UUPSUpgradeable_init();

        nftCollection = IERC721Upgradeable(_nft);
        feeToken = IERC20Upgradeable(_feeToken);
        receipt = IStakeReceipt(_receipt);
        stonerPool = IStonerFeePool(_stonerPool);

        swapFee = _swapFee;
        minStakeDuration = _minStakeDuration;
        stonerFeeShare = _stonerFeeShare;
    }

    function stake(uint256 tokenId) external {
        nftCollection.safeTransferFrom(msg.sender, address(this), tokenId);
        stakedNFTs[tokenId] = StakeInfo(msg.sender, block.timestamp);
        stakerToTokenIds[msg.sender].push(tokenId);
        receipt.mint(msg.sender, tokenId);
        poolNFTs.push(tokenId);
        isInPool[tokenId] = true;
        totalStaked++;
    }

    function unstake(uint256 tokenId) external {
        StakeInfo memory info = stakedNFTs[tokenId];
        require(info.staker == msg.sender, "Not staker");
        require(block.timestamp >= info.timestamp + minStakeDuration, "Locked");

        delete stakedNFTs[tokenId];
        _removeFromArray(stakerToTokenIds[msg.sender], tokenId);
        if (isInPool[tokenId]) {
            _removeFromArray(poolNFTs, tokenId);
            isInPool[tokenId] = false;
        }
        totalStaked--;
        receipt.burn(tokenId);
        nftCollection.safeTransferFrom(address(this), msg.sender, tokenId);
    }

    function swap(uint256 yourTokenId) external {
        require(poolNFTs.length > 0, "Empty pool");
        require(feeToken.transferFrom(msg.sender, address(this), swapFee), "Fee failed");

        nftCollection.safeTransferFrom(msg.sender, address(this), yourTokenId);
        stakedNFTs[yourTokenId] = StakeInfo(msg.sender, block.timestamp);
        stakerToTokenIds[msg.sender].push(yourTokenId);
        poolNFTs.push(yourTokenId);
        isInPool[yourTokenId] = true;
        receipt.mint(msg.sender, yourTokenId);
        totalStaked++;

        uint256 index = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender, poolNFTs.length))) % poolNFTs.length;
        uint256 tokenIdOut = poolNFTs[index];

        _removeFromArray(poolNFTs, tokenIdOut);
        isInPool[tokenIdOut] = false;

        nftCollection.safeTransferFrom(address(this), msg.sender, tokenIdOut);

        uint256 stonerShare = (swapFee * stonerFeeShare) / 100;
        uint256 stakerShare = swapFee - stonerShare;

        if (stonerShare > 0) {
            feeToken.approve(address(stonerPool), stonerShare);
            stonerPool.notifyReward(stonerShare);
        }

        uint256 perNFT = stakerShare / totalStaked;
        for (uint256 i = 0; i < poolNFTs.length; i++) {
            address staker = stakedNFTs[poolNFTs[i]].staker;
            rewards[staker] += perNFT;
        }
    }

    function claim() external {
        uint256 amt = rewards[msg.sender];
        require(amt > 0, "No rewards");
        rewards[msg.sender] = 0;
        require(feeToken.transfer(msg.sender, amt), "Transfer failed");
    }

    function getPoolLength() external view returns (uint256) {
        return poolNFTs.length;
    }

    function setSwapFee(uint256 fee) external onlyOwner {
        swapFee = fee;
    }

    function setMinStakeDuration(uint256 duration) external onlyOwner {
        minStakeDuration = duration;
    }

    function setStonerFeeShare(uint256 share) external onlyOwner {
        require(share <= 100, "Too high");
        stonerFeeShare = share;
    }

    function _removeFromArray(uint256[] storage array, uint256 tokenId) internal {
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == tokenId) {
                array[i] = array[array.length - 1];
                array.pop();
                break;
            }
        }
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
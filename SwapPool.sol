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
    uint256[] public poolNFTs;

    mapping(address => uint256) public rewards;
    mapping(address => uint256[]) public userStakedNFTs;

    uint256 public totalStaked;

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
        userStakedNFTs[msg.sender].push(tokenId);
        receipt.mint(msg.sender, tokenId);
        poolNFTs.push(tokenId);
        totalStaked++;
    }

    function unstake(uint256 tokenId) external {
        StakeInfo memory info = stakedNFTs[tokenId];
        require(info.staker == msg.sender, "Not staker");
        require(block.timestamp >= info.timestamp + minStakeDuration, "Locked");

        for (uint i = 0; i < poolNFTs.length; i++) {
            if (poolNFTs[i] == tokenId) {
                poolNFTs[i] = poolNFTs[poolNFTs.length - 1];
                poolNFTs.pop();
                break;
            }
        }

        // Remove from userStakedNFTs
        uint256[] storage userTokens = userStakedNFTs[msg.sender];
        for (uint i = 0; i < userTokens.length; i++) {
            if (userTokens[i] == tokenId) {
                userTokens[i] = userTokens[userTokens.length - 1];
                userTokens.pop();
                break;
            }
        }

        delete stakedNFTs[tokenId];
        totalStaked--;
        receipt.burn(tokenId);
        nftCollection.safeTransferFrom(address(this), msg.sender, tokenId);
    }

    function swap(uint256 yourTokenId) external {
        require(poolNFTs.length > 0, "Empty pool");
        require(feeToken.transferFrom(msg.sender, address(this), swapFee), "Fee failed");

        nftCollection.safeTransferFrom(msg.sender, address(this), yourTokenId);
        stakedNFTs[yourTokenId] = StakeInfo(msg.sender, block.timestamp);
        userStakedNFTs[msg.sender].push(yourTokenId);
        poolNFTs.push(yourTokenId);
        receipt.mint(msg.sender, yourTokenId);
        totalStaked++;

        uint256 index = uint256(keccak256(abi.encodePacked(msg.sender, block.timestamp, block.prevrandao))) % poolNFTs.length;
        uint256 tokenIdOut = poolNFTs[index];

        poolNFTs[index] = poolNFTs[poolNFTs.length - 1];
        poolNFTs.pop();

        nftCollection.safeTransferFrom(address(this), msg.sender, tokenIdOut);

        uint256 stonerShare = (swapFee * stonerFeeShare) / 100;
        uint256 stakerShare = swapFee - stonerShare;

        if (stonerShare > 0) {
            feeToken.approve(address(stonerPool), stonerShare);
            stonerPool.notifyReward(stonerShare);
        }

        uint256 perNFT = stakerShare / totalStaked;
        for (uint i = 0; i < poolNFTs.length; i++) {
            rewards[stakedNFTs[poolNFTs[i]].staker] += perNFT;
        }
    }

    function claimAll() external {
        uint256 totalReward = rewards[msg.sender];
        require(totalReward > 0, "No rewards");
        rewards[msg.sender] = 0;
        require(feeToken.transfer(msg.sender, totalReward), "Transfer failed");
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

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}

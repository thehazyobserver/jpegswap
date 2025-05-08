// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

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
    uint256 public totalStaked;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers(); // prevents direct deployment of logic
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
        receipt.mint(msg.sender, tokenId);
        poolNFTs.push(tokenId);
        totalStaked++;
    }

    function unstake(uint256 tokenId) external {
        StakeInfo memory info = stakedNFTs[tokenId];
        require(info.staker == msg.sender, "Not staker");
        require(block.timestamp >= info.timestamp + minStakeDuration, "Locked");

        bool found = false;
        for (uint i = 0; i < poolNFTs.length; i++) {
            if (poolNFTs[i] == tokenId) {
                poolNFTs[i] = poolNFTs[poolNFTs.length - 1];
                poolNFTs.pop();
                found = true;
                break;
            }
        }
        require(found, "Token not in pool");

        delete stakedNFTs[tokenId];
        totalStaked--;
        receipt.burn(tokenId);
        nftCollection.safeTransferFrom(address(this), msg.sender, tokenId);
    }

    function swap(uint256 yourTokenId) external {
        require(poolNFTs.length > 0, "Empty pool");
        require(feeToken.transferFrom(msg.sender, address(this), swapFee), "Fee failed");

        nftCollection.safeTransferFrom(msg.sender, address(this), yourTokenId);
        poolNFTs.push(yourTokenId);

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

        uint256 perStaker = stakerShare / totalStaked;
        for (uint i = 0; i < poolNFTs.length; i++) {
            rewards[stakedNFTs[poolNFTs[i]].staker] += perStaker;
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

    /// @dev required for UUPS upgradeable proxy pattern
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}

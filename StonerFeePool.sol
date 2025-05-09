// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

contract StonerFeePool is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    IERC721Upgradeable public stonerNFT;
    uint256[] public allStakedTokenIds;
    mapping(uint256 => address) public stakerOf;
    mapping(address => uint256[]) public stakedTokens;
    mapping(address => mapping(address => uint256)) public rewardsPerToken;
    mapping(address => bool) public allowedRewardTokens;
    address[] public rewardTokens;
    mapping(address => uint256) public rewardDust;
    uint256 public totalStaked;

    event RewardTokenAdded(address token);
    event Staked(address indexed user, uint256 tokenId);
    event Unstaked(address indexed user, uint256 tokenId);
    event RewardClaimed(address indexed user, address token, uint256 amount);

    error AlreadyInitialized();
    error NotInitialized();
    error TokenNotAllowed();
    error NoRewards();
    error TransferFailed();
    error AlreadyStaked();
    error NotYourToken();
    error NoStakers();

    function initialize(address _stonerNFT) public initializer {
        if (address(stonerNFT) != address(0)) revert AlreadyInitialized();
        __Ownable_init();
        __UUPSUpgradeable_init();
        stonerNFT = IERC721Upgradeable(_stonerNFT);
    }

    function stake(uint256 tokenId) external {
        if (address(stonerNFT) == address(0)) revert NotInitialized();
        if (stakerOf[tokenId] != address(0)) revert AlreadyStaked();
        stonerNFT.transferFrom(msg.sender, address(this), tokenId);
        stakerOf[tokenId] = msg.sender;
        stakedTokens[msg.sender].push(tokenId);
        allStakedTokenIds.push(tokenId);
        totalStaked++;
        emit Staked(msg.sender, tokenId);
    }

    function unstake(uint256 tokenId) external {
        if (address(stonerNFT) == address(0)) revert NotInitialized();
        if (stakerOf[tokenId] != msg.sender) revert NotYourToken();
        stonerNFT.transferFrom(address(this), msg.sender, tokenId);
        delete stakerOf[tokenId];

        uint256[] storage tokens = stakedTokens[msg.sender];
        for (uint i = 0; i < tokens.length; i++) {
            if (tokens[i] == tokenId) {
                tokens[i] = tokens[tokens.length - 1];
                tokens.pop();
                break;
            }
        }

        for (uint i = 0; i < allStakedTokenIds.length; i++) {
            if (allStakedTokenIds[i] == tokenId) {
                allStakedTokenIds[i] = allStakedTokenIds[allStakedTokenIds.length - 1];
                allStakedTokenIds.pop();
                break;
            }
        }
        totalStaked--;
        emit Unstaked(msg.sender, tokenId);
    }

    function notifyReward(address token, uint256 amount) external {
        if (address(stonerNFT) == address(0)) revert NotInitialized();
        if (totalStaked == 0) revert NoStakers();
        if (!IERC20Upgradeable(token).transferFrom(msg.sender, address(this), amount)) revert TransferFailed();

        if (!allowedRewardTokens[token]) {
            allowedRewardTokens[token] = true;
            rewardTokens.push(token);
            emit RewardTokenAdded(token);
        }

        uint256 totalAmount = amount + rewardDust[token];
        uint256 perTokenReward = totalAmount / totalStaked;
        uint256 newDust = totalAmount % totalStaked;
        rewardDust[token] = newDust;

        for (uint i = 0; i < allStakedTokenIds.length; i++) {
            uint256 tokenId = allStakedTokenIds[i];
            address staker = stakerOf[tokenId];
            if (staker != address(0)) {
                rewardsPerToken[staker][token] += perTokenReward;
            }
        }
    }

    function claim(address token) external {
        if (address(stonerNFT) == address(0)) revert NotInitialized();
        if (!allowedRewardTokens[token]) revert TokenNotAllowed();
        uint256 amt = rewardsPerToken[msg.sender][token];
        if (amt == 0) revert NoRewards();
        rewardsPerToken[msg.sender][token] = 0;
        if (!IERC20Upgradeable(token).transfer(msg.sender, amt)) revert TransferFailed();
        emit RewardClaimed(msg.sender, token, amt);
    }

    function claimMultiple(address[] calldata tokens) external {
        if (address(stonerNFT) == address(0)) revert NotInitialized();
        for (uint i = 0; i < tokens.length; i++) {
            address token = tokens[i];
            if (!allowedRewardTokens[token]) continue;
            uint256 amt = rewardsPerToken[msg.sender][token];
            if (amt > 0) {
                rewardsPerToken[msg.sender][token] = 0;
                if (!IERC20Upgradeable(token).transfer(msg.sender, amt)) revert TransferFailed();
                emit RewardClaimed(msg.sender, token, amt);
            }
        }
    }

    function getRewardTokens() external view returns (address[] memory) {
        return rewardTokens;
    }

    function getStakedTokens(address user) external view returns (uint256[] memory) {
        return stakedTokens[user];
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
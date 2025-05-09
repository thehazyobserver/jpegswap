
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts-upgradeable/v4.8.3/contracts/proxy/utils/Initializable.sol";
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts-upgradeable/v4.8.3/contracts/access/OwnableUpgradeable.sol";
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts-upgradeable/v4.8.3/contracts/proxy/utils/UUPSUpgradeable.sol";
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts-upgradeable/v4.8.3/contracts/token/ERC721/IERC721Upgradeable.sol";
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts-upgradeable/v4.8.3/contracts/token/ERC20/IERC20Upgradeable.sol";

contract StonerFeePool is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    IERC721Upgradeable public stonerNFT;

    mapping(uint256 => address) public stakerOf;
    mapping(address => uint256[]) public stakedTokens;
    mapping(address => mapping(address => uint256)) public rewardsPerToken; // user => token => reward

    mapping(address => bool) public allowedRewardTokens;
    address[] public rewardTokens;

    uint256 public totalStaked;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _stonerNFT) public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
        stonerNFT = IERC721Upgradeable(_stonerNFT);
    }

    function stake(uint256 tokenId) external {
        require(stakerOf[tokenId] == address(0), "Already staked");
        stonerNFT.transferFrom(msg.sender, address(this), tokenId);
        stakerOf[tokenId] = msg.sender;
        stakedTokens[msg.sender].push(tokenId);
        totalStaked++;
    }

    function unstake(uint256 tokenId) external {
        require(stakerOf[tokenId] == msg.sender, "Not your token");
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
        totalStaked--;
    }

    function notifyReward(address token, uint256 amount) external {
        require(totalStaked > 0, "No stakers");
        require(IERC20Upgradeable(token).transferFrom(msg.sender, address(this), amount), "Transfer failed");

        if (!allowedRewardTokens[token]) {
            allowedRewardTokens[token] = true;
            rewardTokens.push(token);
        }

        uint256 perTokenReward = amount / totalStaked;

        for (uint256 tokenId = 0; tokenId < 10000; tokenId++) {
            address staker = stakerOf[tokenId];
            if (staker != address(0)) {
                rewardsPerToken[staker][token] += perTokenReward;
            }
        }
    }

    function claim(address token) external {
        uint256 amt = rewardsPerToken[msg.sender][token];
        require(amt > 0, "No rewards");
        rewardsPerToken[msg.sender][token] = 0;
        require(IERC20Upgradeable(token).transfer(msg.sender, amt), "Transfer failed");
    }

    function claimAll() external {
        for (uint i = 0; i < rewardTokens.length; i++) {
            address token = rewardTokens[i];
            uint256 amt = rewardsPerToken[msg.sender][token];
            if (amt > 0) {
                rewardsPerToken[msg.sender][token] = 0;
                IERC20Upgradeable(token).transfer(msg.sender, amt);
            }
        }
    }

    function getClaimableRewards(address user) external view returns (address[] memory tokens, uint256[] memory amounts) {
        uint256 len = rewardTokens.length;
        tokens = new address[](len);
        amounts = new uint256[](len);
        for (uint i = 0; i < len; i++) {
            address token = rewardTokens[i];
            tokens[i] = token;
            amounts[i] = rewardsPerToken[user][token];
        }
    }

    function getStakedTokens(address user) external view returns (uint256[] memory) {
        return stakedTokens[user];
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}

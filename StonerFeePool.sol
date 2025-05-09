// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts-upgradeable/v4.8.3/contracts/proxy/utils/Initializable.sol";
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts-upgradeable/v4.8.3/contracts/access/OwnableUpgradeable.sol";
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts-upgradeable/v4.8.3/contracts/proxy/utils/UUPSUpgradeable.sol";
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts-upgradeable/v4.8.3/contracts/token/ERC721/IERC721Upgradeable.sol";
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts-upgradeable/v4.8.3/contracts/token/ERC20/IERC20Upgradeable.sol";

contract StonerFeePool is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    IERC721Upgradeable public stonerNFT;
    IERC20Upgradeable public rewardToken;

    mapping(uint256 => address) public stakerOf;
    mapping(address => uint256) public rewards;
    mapping(address => uint256[]) public stakedTokens;

    uint256 public totalStaked;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _stonerNFT, address _rewardToken) public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();

        stonerNFT = IERC721Upgradeable(_stonerNFT);
        rewardToken = IERC20Upgradeable(_rewardToken);
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

        // remove from user array
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

    function notifyReward(uint256 amount) external {
        require(totalStaked > 0, "No stakers");
        require(rewardToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        uint256 perToken = amount / totalStaked;

        for (uint256 i = 0; i < totalStaked; i++) {
            address staker = stakerOf[i];
            if (staker != address(0)) {
                rewards[staker] += perToken;
            }
        }
    }

    function claimAll() external {
        uint256 amt = rewards[msg.sender];
        require(amt > 0, "No rewards");

        rewards[msg.sender] = 0;
        require(rewardToken.transfer(msg.sender, amt), "Transfer failed");
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
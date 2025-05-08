// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract StonerFeePool is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    IERC721Upgradeable public stonerNFT;
    IERC20Upgradeable public rewardToken;

    mapping(uint256 => address) public stakerOf;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public stakedCount;

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
        stonerNFT.transferFrom(msg.sender, address(this), tokenId);
        require(stakerOf[tokenId] == address(0), "Already staked");

        stakerOf[tokenId] = msg.sender;
        stakedCount[msg.sender]++;
        totalStaked++;
    }

    function unstake(uint256 tokenId) external {
        require(stakerOf[tokenId] == msg.sender, "Not your token");

        stonerNFT.transferFrom(address(this), msg.sender, tokenId);
        delete stakerOf[tokenId];
        stakedCount[msg.sender]--;
        totalStaked--;
    }

    function notifyReward(uint256 amount) external {
        require(totalStaked > 0, "No stakers");

        uint256 perToken = amount / totalStaked;

        for (uint256 tokenId = 0; tokenId < 10000; tokenId++) {
            address staker = stakerOf[tokenId];
            if (staker != address(0)) {
                rewards[staker] += perToken;
            }
        }

        require(rewardToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");
    }

    function claim() external {
        uint256 amt = rewards[msg.sender];
        require(amt > 0, "No rewards");

        rewards[msg.sender] = 0;
        require(rewardToken.transfer(msg.sender, amt), "Transfer failed");
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}

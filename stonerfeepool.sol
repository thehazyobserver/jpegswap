// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts-upgradeable@4.8.3/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@4.8.3/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@4.8.3/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@4.8.3/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable@4.8.3/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@4.8.3/token/ERC721/IERC721Upgradeable.sol";

interface IStakeReceipt {
    function mint(address to, uint256 tokenId) external;
    function burn(uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract StonerFeePool is
    Initializable,
    OwnableUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable,
    UUPSUpgradeable
{
    IERC721Upgradeable public stonerNFT;
    IStakeReceipt public receiptToken;

    uint256 public totalStaked;
    uint256 public rewardPerTokenStored;
    uint256 public rewardRemainder;
    uint256 public totalRewardsClaimed;

    mapping(uint256 => address) public stakerOf;
    mapping(address => uint256[]) public stakedTokens;
    mapping(uint256 => bool) public isStaked;

    mapping(address => uint256) public rewards;
    mapping(address => uint256) public userRewardPerTokenPaid;

    event Staked(address indexed user, uint256 tokenId);
    event Unstaked(address indexed user, uint256 returnedTokenId);
    event RewardReceived(address indexed sender, uint256 amount);
    event RewardClaimed(address indexed user, uint256 amount);
    event EmergencyUnstake(uint256 tokenId, address to);

    error NotStaked();
    error AlreadyStaked();
    error NotYourToken();
    error NoAvailableTokens();
    error NoStakers();
    error ZeroETH();

    function initialize(address _stonerNFT, address _receiptToken) public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
        __Pausable_init();

        stonerNFT = IERC721Upgradeable(_stonerNFT);
        receiptToken = IStakeReceipt(_receiptToken);
    }

    function stake(uint256 tokenId) external whenNotPaused {
        if (isStaked[tokenId]) revert AlreadyStaked();
        stonerNFT.transferFrom(msg.sender, address(this), tokenId);
        isStaked[tokenId] = true;
        stakerOf[tokenId] = msg.sender;
        stakedTokens[msg.sender].push(tokenId);
        receiptToken.mint(msg.sender, tokenId);
        _updateReward(msg.sender);
        totalStaked++;
        emit Staked(msg.sender, tokenId);
    }

    function unstake(uint256 tokenId) external whenNotPaused {
        if (stakerOf[tokenId] != msg.sender) revert NotYourToken();
        receiptToken.burn(tokenId);
        delete stakerOf[tokenId];
        isStaked[tokenId] = false;
        _removeFromArray(stakedTokens[msg.sender], tokenId);
        totalStaked--;
        _updateReward(msg.sender);
        stonerNFT.transferFrom(address(this), msg.sender, tokenId);
        emit Unstaked(msg.sender, tokenId);
    }

    function notifyNativeReward() external payable {
        if (msg.value == 0) revert ZeroETH();
        if (totalStaked == 0) revert NoStakers();

        uint256 totalValue = msg.value + rewardRemainder;
        uint256 increment = totalValue / totalStaked;
        rewardPerTokenStored += increment;
        rewardRemainder = totalValue % totalStaked;
        emit RewardReceived(msg.sender, msg.value);
    }

    function claimNative() external nonReentrant {
        _updateReward(msg.sender);
        uint256 reward = rewards[msg.sender];
        if (reward == 0) return;
        rewards[msg.sender] = 0;
        totalRewardsClaimed += reward;
        (bool success, ) = payable(msg.sender).call{value: reward}("");
        require(success, "Transfer failed");
        emit RewardClaimed(msg.sender, reward);
    }

    function _updateReward(address user) internal {
        uint256 userBalance = stakedTokens[user].length;
        uint256 owed = (userBalance * (rewardPerTokenStored - userRewardPerTokenPaid[user]));
        rewards[user] += owed;
        userRewardPerTokenPaid[user] = rewardPerTokenStored;
    }

    function _removeFromArray(uint256[] storage array, uint256 tokenId) internal {
        for (uint i = 0; i < array.length; i++) {
            if (array[i] == tokenId) {
                array[i] = array[array.length - 1];
                array.pop();
                break;
            }
        }
    }

    function emergencyUnstake(uint256 tokenId, address to) external onlyOwner {
        if (!isStaked[tokenId]) revert NotStaked();
        address staker = stakerOf[tokenId];
        if (staker != address(0)) {
            _removeFromArray(stakedTokens[staker], tokenId);
            delete stakerOf[tokenId];
            isStaked[tokenId] = false;
            totalStaked--;
        }
        stonerNFT.transferFrom(address(this), to, tokenId);
        emit EmergencyUnstake(tokenId, to);
    }

    /// @dev Register my contract on Sonic FeeM
function registerMe() external {
    (bool _success,) = address(0xDC2B0D2Dd2b7759D97D50db4eabDC36973110830).call(
        abi.encodeWithSignature("selfRegister(uint256)", 92)
    );
    require(_success, "FeeM registration failed");
}

function pause() external onlyOwner {
    _pause();
}

function unpause() external onlyOwner {
    _unpause();
}


    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    receive() external payable {
        notifyNativeReward();
    }
}

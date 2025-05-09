// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./SwapPool.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract SwapPoolFactory is Ownable {
    address public implementation;
    mapping(address => address) public collectionToPool;
    address[] public allPools;

    event PoolCreated(address indexed collection, address pool);
    event FactoryDeployed(address indexed implementation, address indexed owner);

    error ZeroAddressNotAllowed();
    error PoolAlreadyExists();
    error InvalidFeeRange();
    error InvalidShareRange();
    error InvalidContract();

    constructor(address _implementation) {
        if (_implementation == address(0)) revert ZeroAddressNotAllowed();
        implementation = _implementation;
        emit FactoryDeployed(_implementation, msg.sender);
    }

    function createPool(
        address nftCollection,
        address feeToken,
        address receiptContract,
        address stonerPool,
        uint256 swapFee,
        uint256 minStakeDuration,
        uint256 stonerShare
    ) external onlyOwner returns (address) {
        if (nftCollection == address(0) || feeToken == address(0) || receiptContract == address(0) || stonerPool == address(0)) {
            revert ZeroAddressNotAllowed();
        }
        if (collectionToPool[nftCollection] != address(0)) revert PoolAlreadyExists();
        if (swapFee < 1e15 || swapFee > 1e18) revert InvalidFeeRange();
        if (stonerShare > 100) revert InvalidShareRange();

        try IERC721(nftCollection).balanceOf(address(this)) {} catch { revert InvalidContract(); }
        try IERC20(feeToken).totalSupply() {} catch { revert InvalidContract(); }

        bytes memory initData = abi.encodeWithSelector(
            SwapPool.initialize.selector,
            nftCollection,
            feeToken,
            receiptContract,
            stonerPool,
            swapFee,
            minStakeDuration,
            stonerShare
        );

        ERC1967Proxy proxy = new ERC1967Proxy(implementation, initData);
        address proxyAddress = address(proxy);

        collectionToPool[nftCollection] = proxyAddress;
        allPools.push(proxyAddress);

        emit PoolCreated(nftCollection, proxyAddress);
        return proxyAddress;
    }

    function setImplementation(address newImpl) external onlyOwner {
        if (newImpl == address(0)) revert ZeroAddressNotAllowed();
        implementation = newImpl;
    }

    function getAllPools() external view returns (address[] memory) {
        return allPools;
    }
}
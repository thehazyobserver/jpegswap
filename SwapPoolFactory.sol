// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface ISwapPool {
    function initialize(
        address nftCollection,
        address feeToken,
        address receiptContract,
        address stonerPool,
        uint256 swapFee,
        uint256 minStakeDuration,
        uint256 stonerShare
    ) external;
}

contract SwapPoolFactory is Ownable {
    address public implementation;
    address public feeToken;
    address public stonerPool;

    mapping(address => address) public collectionToPool;
    address[] public allPools;

    event PoolCreated(address indexed collection, address pool);

    constructor(address _implementation, address _feeToken, address _stonerPool) {
        implementation = _implementation;
        feeToken = _feeToken;
        stonerPool = _stonerPool;
    }

    function createPool(
        address nftCollection,
        address receiptContract,
        uint256 swapFee,
        uint256 minStakeDuration,
        uint256 stonerShare
    ) external onlyOwner returns (address) {
        require(collectionToPool[nftCollection] == address(0), "Pool already exists");

        bytes memory initData = abi.encodeWithSelector(
            ISwapPool.initialize.selector,
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

    function setImplementation(address newImplementation) external onlyOwner {
        implementation = newImplementation;
    }

    function getAllPools() external view returns (address[] memory) {
        return allPools;
    }
}

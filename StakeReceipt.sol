// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakeReceipt is ERC721Enumerable, Ownable {
    address public pool;
    string private baseURI;

    event BaseURIUpdated(string newBaseURI);

    error OnlyPool();
    error NonTransferable();
    error InvalidURI();

    constructor(string memory name_, string memory symbol_, address pool_) ERC721(name_, symbol_) {
        pool = pool_;
    }

    modifier onlyPool() {
        if (msg.sender != pool) revert OnlyPool();
        _;
    }

    function mint(address to, uint256 tokenId) external onlyPool {
        _mint(to, tokenId);
    }

    function burn(uint256 tokenId) external onlyPool {
        _burn(tokenId);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory uri) external onlyOwner {
        if (bytes(uri).length == 0) revert InvalidURI();
        baseURI = uri;
        emit BaseURIUpdated(uri);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override {
        if (from != address(0) && to != address(0)) revert NonTransferable();
        super._beforeTokenTransfer(from, to, tokenId);
    }
}
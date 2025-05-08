// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakeReceipt is ERC721Enumerable, Ownable {
    address public pool;

    constructor(
        string memory name_,
        string memory symbol_,
        address pool_
    ) ERC721(name_, symbol_) {
        pool = pool_;
    }

    modifier onlyPool() {
        require(msg.sender == pool, "Only the associated pool can mint or burn");
        _;
    }

    function mint(address to, uint256 tokenId) external onlyPool {
        _mint(to, tokenId);
    }

    function burn(uint256 tokenId) external onlyPool {
        _burn(tokenId);
    }
}

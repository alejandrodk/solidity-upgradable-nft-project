// SPDX-License-Identifier: MIT
//https://docs.alchemy.com/docs/how-to-create-erc-1155-tokens
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract AwesomeGame is ERC1155 {
    // Fungible currencies
    uint256 public constant GOLD = 0;
    uint256 public constant SILVER = 1;
    // Fungible Weapons
    uint256 public constant SWORD = 2;
    uint256 public constant SHIELD = 3;
    // Not Fungible crown
    uint256 public constant CROWN = 4;

    constructor() ERC1155("https://awesomegame.com/assets/{id}.json") {
        _mint(msg.sender, GOLD, 10**18, "");
        _mint(msg.sender, SILVER, 10**18, "");
        _mint(msg.sender, SWORD, 1000, "");
        _mint(msg.sender, SHIELD, 1000, "");
        _mint(msg.sender, CROWN, 1, "");
    }
}

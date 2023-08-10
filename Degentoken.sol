// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "hardhat/console.sol";

contract DegenToken is ERC20, Ownable, ERC20Burnable {

    constructor() ERC20("Degen", "DGN") {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function transferTokens(address _receiver, uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        _transfer(msg.sender, _receiver, amount);
    }

    function checkBalance() external view returns (uint) {
        return balanceOf(msg.sender);
    }

    function burnTokens(uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        _burn(msg.sender, amount);
    }

    function gameStore() public pure returns (string memory) {
        return "1. ProPlayer NFT value = 200 \n 2. SuperNinja value = 100 \n 3. DegenCap value = 75";
    }

    function redeemTokens(uint choice) external {
        require(choice >= 1 && choice <= 3, "Invalid selection");

        uint256 requiredAmount;

        if (choice == 1) {
            requiredAmount = 200;
        } else if (choice == 2) {
            requiredAmount = 100;
        } else if (choice == 3) {
            requiredAmount = 75;
        }

        require(balanceOf(msg.sender) >= requiredAmount, "Insufficient balance");
        _transfer(msg.sender, owner(), requiredAmount);
    }
}

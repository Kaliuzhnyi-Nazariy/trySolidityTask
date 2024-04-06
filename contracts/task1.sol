// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract SolarGreenToken is ERC20, ERC20Burnable, Ownable, ERC20Permit {
    constructor(
        address initialOwner
    )
        Ownable(initialOwner)
        ERC20("Solar Green", "SGR")
        ERC20Permit("Solar Green")
    {
        _mint(msg.sender, 100000000 * 10 ** decimals());
    }

    struct BannedUser {
        address wallet;
        string nickName;
    }

    BannedUser[] public blacklist;

    struct User {
        address payable wallet;
        string nickName;
        uint tokensAmount;
        uint userAmountOfUSDT;
    }

    mapping(address => User) public users;

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function addToBlackList(address wallet) public onlyOwner {
        require(
            users[wallet].wallet != address(0),
            "This user is not in user list!"
        );
        for (uint i = 0; i < blacklist.length; i++) {
            if (blacklist[i].wallet == wallet) {
                revert("User is already in the blacklist!");
            }
        }
        blacklist.push(BannedUser(wallet, users[wallet].nickName));
    }

    function removeFromBlackList(address wallet) public onlyOwner {
        for (uint i = 0; i < blacklist.length; i++) {
            if (blacklist[i].wallet == wallet) {
                blacklist[i] = blacklist[blacklist.length - 1];
                blacklist.pop();
                break;
            }
        }
    }
}

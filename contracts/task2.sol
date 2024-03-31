// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract SolarGreen is ERC20, ERC20Burnable, Ownable, ERC20Permit {
    uint public fixedPrice;
    uint public fixedPriceForUSDT;
    bool public abilityToSell = false;
    uint public upToWhenAbillityToSell;
    uint public buyLimit = 50000;

    constructor(
        address initialOwner,
        uint _fixedPrice,
        uint _fixedPriceForUSDT
    )
        Ownable(initialOwner)
        ERC20("Solar Green", "SGR")
        ERC20Permit("Solar Green")
    {
        fixedPrice = _fixedPrice;
        fixedPriceForUSDT = _fixedPriceForUSDT;
        _mint(msg.sender, 100000000 * 10 ** decimals());
    }

    event UserExistenceChecked(address indexed user, bool exists);
    event changeAbilityToSell(bool newValue);

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

    User[] public boughtList;

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function addUser(
        address payable _wallet,
        string memory _nickName,
        uint amountOfUSDT
    ) public {
        require(
            users[_wallet].wallet == address(0),
            "This account is already added!"
        );
        users[_wallet] = User(_wallet, _nickName, 0, amountOfUSDT);
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

    function setInfoForSale(uint _upToWhenAbillityToSell) external onlyOwner {
        abilityToSell = true;
        upToWhenAbillityToSell = _upToWhenAbillityToSell;
        emit changeAbilityToSell(abilityToSell);
    }

    function isInBlacklist(address wallet) internal view returns (bool) {
        for (uint i = 0; i < blacklist.length; i++) {
            if (blacklist[i].wallet == wallet) {
                return true;
            }
        }
        return false;
    }

    uint private availableTokens;

    function setAvailableAmountOfTokensToSale(uint percent) public onlyOwner {
        if (percent == 0) {
            revert("Tokens not selling!");
        }
        if (percent > 100) {
            revert("Please enter less percents!");
        }

        uint percentValue = (totalSupply() * percent) / 100;
        availableTokens = totalSupply() - percentValue;
    }

    function availableAmountOfTokensToSale() public view returns (uint) {
        return availableTokens;
    }

    function userExists(address user) internal view returns (bool) {
        return users[user].wallet != address(0);
    }

    uint public boughtForNow = 0;

    uint public timeCurrent = block.timestamp;

    function check() public {
        if (block.timestamp > upToWhenAbillityToSell) {
            abilityToSell = false;
            upToWhenAbillityToSell = 0;
            emit changeAbilityToSell(abilityToSell);
        }
    }

    function buyToken(uint amountOfTokens) public payable {
        require(userExists(msg.sender), "User does not exist!");
        require(!isInBlacklist(msg.sender), "This user is in the blacklist!");
        require(
            boughtForNow + amountOfTokens <= availableAmountOfTokensToSale(),
            "was bought all available amount of tokens!"
        );
        check();
        require(
            block.timestamp < upToWhenAbillityToSell,
            "Time was running out!"
        );
        require(abilityToSell == true, "Couldn't make any operations!");
        require(
            users[msg.sender].tokensAmount + amountOfTokens < buyLimit,
            "Exceeded purchase limit!"
        );

        uint totalCost = amountOfTokens * fixedPrice;
        require(msg.value >= totalCost, "Insufficient funds!");

        _transfer(owner(), msg.sender, amountOfTokens);

        _burn(owner(), amountOfTokens);

        boughtForNow += amountOfTokens;

        users[msg.sender].tokensAmount += amountOfTokens;

        boughtList.push(users[msg.sender]);
    }

    function buyTokenByUSDT(uint amountOfTokens, uint amountOfUSDT) public {
        require(userExists(msg.sender), "User does not exist!");
        require(!isInBlacklist(msg.sender), "This user is in the blacklist!");
        require(
            boughtForNow + amountOfTokens <= availableAmountOfTokensToSale(),
            "was bought all available amount of tokens!"
        );
        check();
        require(
            block.timestamp < upToWhenAbillityToSell,
            "Time was running out!"
        );
        require(abilityToSell == true, "Couldn't make any operations!");
        require(
            users[msg.sender].tokensAmount + amountOfTokens < buyLimit,
            "Exceeded purchase limit!"
        );

        uint totalCost = amountOfTokens * fixedPriceForUSDT;
        require(amountOfUSDT >= totalCost, "Insufficient funds!");

        uint diff = amountOfUSDT - totalCost;

        if (diff > 0) {
            users[msg.sender].userAmountOfUSDT =
                users[msg.sender].userAmountOfUSDT -
                amountOfUSDT +
                diff;
        } else {
            users[msg.sender].userAmountOfUSDT -= totalCost;
        }

        _transfer(owner(), msg.sender, amountOfTokens);

        _burn(owner(), amountOfTokens);

        boughtForNow += amountOfTokens;

        users[msg.sender].tokensAmount += amountOfTokens;

        boughtList.push(users[msg.sender]);
    }
}

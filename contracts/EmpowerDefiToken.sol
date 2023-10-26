// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract EmpowerDefiToken is ERC20, ERC20Burnable, Ownable {
    mapping(address => uint256) public borrowed;

    event IssueCredits(address, uint256);
    event Mint(address, uint256);

    constructor() ERC20("EmpowerDefi Token", "EmpowerDefi") {
        _mint(msg.sender, 101714777000000000000000000);
    }

    function mint(address to, uint256 _amount) public onlyOwner {
        _mint(to, _amount);
        emit Mint(msg.sender, _amount);
    }

    function issueCredits(address _to, uint256 _amount) external onlyOwner {
        _mint(_to, _amount);
        emit IssueCredits(_to, _amount);
    }
}

pragma solidity >=0.5.16 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// https://docs.openzeppelin.com/contracts/2.x/erc20-supply
contract DappsToken is ERC20 {
    string public name = "Dappstoken";
    string public symbol = "DTKN";
    uint public decimals = 18;

    constructor(uint256 initialSupply) public {
        _mint(msg.sender, initialSupply * (10 ** 18));
    }
}
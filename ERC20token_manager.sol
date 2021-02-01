// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <=0.7.5;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.3.0/contracts/token/ERC20/ERC20.sol";

contract ERC20token is ERC20{
 
    constructor (uint mint_amount) public ERC20("StandardERC20", "ERC"){
        _mint(msg.sender, mint_amount * (10 ** uint256(decimals())));
    }
}
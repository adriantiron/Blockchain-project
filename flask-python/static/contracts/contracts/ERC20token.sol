// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "./token/ERC20.sol";

contract ERC20token is ERC20{
 
    constructor (uint mint_amount) ERC20("StandardERC20", "ERC"){
        _mint(msg.sender, mint_amount * (10 ** uint256(decimals())));
    }
}
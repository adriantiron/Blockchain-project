// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <=0.7.5;

import "./ERC20token.sol";

contract ERC20token_manager{

    ERC20token public stdToken;
    
    constructor () public {
        stdToken = new ERC20token(10000);
    }
    
    function getName() public view returns (string memory){
        return stdToken.name();
    }
    
    function getSymbol() public view returns (string memory){
        return stdToken.symbol();
    }
    
    function getTotalSupply() public view returns (uint256){
        return stdToken.totalSupply();
    }
    
    function getBalanceOf(address account) public view returns (uint256){
        return stdToken.balanceOf(account);
    }
    
    function transfer(address recipient, uint256 amount) public {
        stdToken.transfer(recipient, amount);
    }
}
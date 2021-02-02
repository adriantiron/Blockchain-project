// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "./GenericUser.sol";

contract Financer is GenericUser{
    
    constructor (address _addr, string memory _name){
        addr = _addr;
        role = 3;
        name = _name;
    }
}
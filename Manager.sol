// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <=0.7.5;

import "./GenericUser.sol";

contract Manager is GenericUser{
    
    constructor (address _addr, string memory _name){
        addr = _addr;
        role = 0;
        rep = 5;
        name = _name;
    }
}
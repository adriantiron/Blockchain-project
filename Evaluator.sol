// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "./GenericUser.sol";

contract Freelancer is GenericUser{
    
    constructor (address _addr, string memory _name, string memory _category){
        addr = _addr;
        role = 1;
        rep = 5;
        name = _name;
        category = _category;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "./GenericUser.sol";

contract Evaluator is GenericUser{
    
    constructor (address _addr, string memory _name, string memory _category){
        addr = _addr;
        role = uint(Roles.Evaluator);
        rep = 5;
        name = _name;
        category = _category;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "./GenericUser.sol";

contract Financer is GenericUser{
    
    constructor (address _addr, string memory _name){
        addr = _addr;
        role = uint(Roles.Financer);
        name = _name;
        rep = 0;
        category = "";
    }
}
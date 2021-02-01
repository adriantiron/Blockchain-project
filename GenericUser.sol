// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <=0.7.5;

abstract contract GenericUser {
    address public addr;
    uint public role;
    uint public rep;
    string public name;
    string public category;
    
    function rep_up() public {
        if (rep < 10)
            rep++;
    }
    
    function rep_down() public {
        if (rep > 1)
            rep--;
    }
}
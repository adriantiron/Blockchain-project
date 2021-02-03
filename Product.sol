// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

contract Product {
    uint public product_id;
    address public manager_address;
    string public description;
    uint public dev;
    uint public rev;
    string public category;
    States currentState;
    
    enum States{ Defined, Started, Finished}
    
    constructor (uint _prod_id, address _mng_addr, string memory _description, uint _dev, uint _rev, string memory _category) {
        product_id = _prod_id;
        manager_address = _mng_addr;
        description = _description;
        dev = _dev;
        rev = _rev;
        category = _category;
        currentState = States.Defined;
    }
    
    function getState() public view returns (uint){
        return uint(currentState);
    }
}
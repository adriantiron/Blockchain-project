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
    mapping (address => uint256) public shares;
    mapping (address => bool) public financer_exists;
    address[] public financers;
    uint public funded_sum;
    address public evaluator;
    address[] public freelancers;
    mapping (address => bool) public freelancer_exists;
    
    enum States{ Funding, Started, Finished, Retired }
    
    constructor (uint _prod_id, address _mng_addr, string memory _description, uint _dev, uint _rev, string memory _category) {
        product_id = _prod_id;
        manager_address = _mng_addr;
        description = _description;
        dev = _dev;
        rev = _rev;
        category = _category;
        currentState = States.Funding;
        funded_sum = 0;
    }
    
    function getState() public view returns (uint){
        return uint(currentState);
    }
    
    function getFinancersLength() public view returns (uint) {
        return financers.length;
    }
    
    function storeEvaluator(address _ev) public {
        evaluator = _ev;
    }
    
    function storeFreelancer(address _fr) public {
        require(freelancer_exists[_fr] == false, "Freelancer is already stored!");
        freelancers.push(_fr);
        freelancer_exists[_fr] = true;
    }
    
    function check_sum() private {
        if (funded_sum >= (dev + rev)) {
            currentState = States.Started;
        }
    }
    
    function storeShare(address _financer, uint _amount) public {
        require(currentState == States.Funding, "You cannot share funds now!");
        
        shares[_financer] += _amount;
        funded_sum += _amount;
        if (!financer_exists[_financer]){
            financer_exists[_financer] = true;
            financers.push(_financer);
        }
        check_sum();
    }
    
    function withdrawShare(address _financer, uint _amount) public {
        require(currentState == States.Funding, "You cannot take back funds now!");

        shares[_financer] -= _amount;
        funded_sum -= _amount;
        
        if (shares[_financer] == 0 && financer_exists[_financer]){
            financer_exists[_financer] = false;
        }
    }
    
    function giveBackAllFunds() public {
        require(currentState == States.Funding, "You cannot give back funds now!");
        currentState = States.Retired;
        
        for(uint it = 0; it < financers.length; it++) {
            if (financer_exists[financers[it]]){
                shares[financers[it]] = 0;
                financer_exists[financers[it]] = false;
            }
        }
        funded_sum = 0;
        delete financers;
    }
}
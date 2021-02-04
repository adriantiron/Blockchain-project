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
    
    uint public funded_sum;
    mapping (address => uint256) public shares;
    address[] public financers;
    mapping (address => bool) public financer_exists;
    
    address public evaluator;
    address[] public freelancers;
    address[] public chosen_freelancers;
    mapping (address => bool) public freelancer_exists;
    mapping (address => bool) public chosen_freelancer_exists;
    uint public alloc_share;
    
    enum States{ Funding, Teaming, Started, Finished, Retired, Evaluation }
    
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
    
    function setState(uint _st) public {
        currentState = States(_st);
    }
    
    function getFinancersLength() public view returns (uint) {
        return financers.length;
    }
    
    function getFreelancersLength() public view returns (uint) {
        return freelancers.length;
    }
    
    function getChosenFreelancersLength() public view returns (uint) {
        return chosen_freelancers.length;
    }
    
    function storeEvaluator(address _ev) public {
        evaluator = _ev;
    }
    
    function storeFreelancer(address _fr) public {
        require(freelancer_exists[_fr] == false, "Freelancer is already stored!");
        freelancers.push(_fr);
        freelancer_exists[_fr] = true;
    }
    
    function teamFreelancer(address _fr) public {
        require(chosen_freelancer_exists[_fr] == false, "Freelancer is already teamed up!");
        chosen_freelancers.push(_fr);
        chosen_freelancer_exists[_fr] = true;
    }
    
    function resetFreelancer(uint _idx) public {
        freelancers[_idx] = address(0);
    }
    
    function deleteAllFreelancersAndEvaluator() public {
        delete freelancers;
        delete chosen_freelancers;
        delete evaluator;
    }
    
    function addAllocShare(uint _sh) public {
        alloc_share += _sh;
    }
    
    function check_sum() private {
        if (funded_sum >= (dev + rev)) {
            currentState = States.Teaming;
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
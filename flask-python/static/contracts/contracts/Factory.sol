// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "./Manager.sol";
import "./Freelancer.sol";
import "./Evaluator.sol";
import "./Financer.sol";

contract Factory {
    
    
    function new_manager(address _addr, string memory _name) public returns (Manager) {
        Manager manager = new Manager(_addr, _name);
        return manager;
    }
    
    function new_freelancer(address _addr, string memory _name, string memory _category) public returns (Freelancer) {
        Freelancer freelancer = new Freelancer(_addr, _name, _category);
        return freelancer;
    }
    
    function new_evaluator(address _addr, string memory _name, string memory _category) public returns (Evaluator) {
        Evaluator evaluator = new Evaluator(_addr, _name, _category);
        return evaluator;
    }
    
    function new_financer(address _addr, string memory _name) public returns (Financer) {
        Financer financer = new Financer(_addr, _name);
        return financer;
    }
}
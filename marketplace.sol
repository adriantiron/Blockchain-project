// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "./GenericUser.sol";
import "./Factory.sol";
import "./ERC20token_manager.sol";
import "./Product.sol";

contract Marketplace {

    mapping(address => GenericUser) private users_contracts;
    mapping(uint => Product) private products_contracts;
    genericUser[] private users_structs;
    prodStruct[] private products_structs;
    ERC20token_manager private tkn_mng;
    uint public productsNu = 0;
    mapping(address => freelancerShare) freelancers_map;
    
    enum States{ Funding, Teaming, Started, Finished, Published, Retired, Evaluation }
    enum Roles{ Manager, Freelancer, Evaluator, Financer}

    // Role: 0 - manager | 1 - freelancer | 2 - evaluator | 3 - financer
    struct genericUser{
        address addr;
        uint role;
        uint rep;
        string name;
        string category;
    }

    struct freelancerShare{
        uint share; // from 1% to 100% of prod dev
        uint rep; // for which freelancer to select
    }

    struct prodStruct{
        uint product_id;
        address manager_address;
        string description;
        uint dev;
        uint rev;
        string category;
        States currentState;
	    uint funded_sum;
        
        address[] applied_freelancers;
        address[] selected_freelancers; // who to select
        address applied_evaluator;

        uint alloc_share; // current allocated share (0%->100%)*
    }

    constructor (Factory _uf, ERC20token_manager _tkn_mng){
        tkn_mng = _tkn_mng;
        
        // REMIX JavaScript VM
        address manager_addr = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        
        address freelancer_0_addr = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        address freelancer_1_addr = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;
        address freelancer_2_addr = 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB;

        address evaluator_0_addr = 0x17F6AD8Ef982297579C203069C1DbfFE4348c372;
        address evaluator_1_addr = 0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678;
        
        address financer_0_addr = 0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB;
        address financer_1_addr = 0xdD870fA1b7C4700F2BD7f44238821C26f7392148;
        
        // create user contracts and store
        storeAndAllocUser(_uf.new_manager(manager_addr, "manager"), 2000);
        
        storeAndAllocUser(_uf.new_freelancer(freelancer_0_addr, "freelancer-0", "Cryptocurrency"), 2500);
        storeAndAllocUser(_uf.new_freelancer(freelancer_1_addr, "freelancer-1", "Games"), 3000);
        storeAndAllocUser(_uf.new_freelancer(freelancer_2_addr, "freelancer-2", "Games"), 7500);
        
        storeAndAllocUser(_uf.new_evaluator(evaluator_0_addr, "evaluator-0", "Games"), 700);
        storeAndAllocUser(_uf.new_evaluator(evaluator_1_addr, "evaluator-1", "Cryptocurrency"), 950);
        
        storeAndAllocUser(_uf.new_financer(financer_0_addr, "financer-0"), 30000);
        storeAndAllocUser(_uf.new_financer(financer_1_addr, "financer-2"), 50000);
    }
    
    modifier onlyManager {
        require(users_contracts[msg.sender].role() == uint(Roles.Manager));
        _;
    }

    modifier onlyFreelancer {
        require(users_contracts[msg.sender].role() == uint(Roles.Freelancer));
        _;
    }

    modifier onlyEvaluator {
        require(users_contracts[msg.sender].role() == uint(Roles.Evaluator));
        _;
    }
    
    modifier onlyFreelancerOrEvaluator {
        require(users_contracts[msg.sender].role() == uint(Roles.Freelancer) || users_contracts[msg.sender].role() == uint(Roles.Evaluator));
        _;
    }
    
    modifier onlyFinancer {
        require(users_contracts[msg.sender].role() == uint(Roles.Financer));
        _;
    }
    
    function createUserStruct(address _addr) private view returns (genericUser memory){
        genericUser memory gu;
        gu.addr = users_contracts[_addr].addr();
        gu.role = users_contracts[_addr].role();
        gu.rep = users_contracts[_addr].rep();
        gu.name = users_contracts[_addr].name();
        gu.category = users_contracts[_addr].category();
        
        return gu;
    }
    
    function createProductStruct(uint _prod_id) private view returns (prodStruct memory){
        prodStruct memory ps;
        ps.product_id = products_contracts[_prod_id].product_id();
        ps.manager_address = products_contracts[_prod_id].manager_address();
        ps.description = products_contracts[_prod_id].description();
        ps.dev = products_contracts[_prod_id].dev();
        ps.rev = products_contracts[_prod_id].rev();
        ps.category = products_contracts[_prod_id].category();
        ps.currentState = States(products_contracts[_prod_id].getState());
        ps.funded_sum = products_contracts[_prod_id].funded_sum();
        
        return ps;
    }
    
    function storeAndAllocUser(GenericUser _gu, uint _alloc_amount) private {
        address _useraddr = _gu.addr();
        
        users_contracts[_useraddr] = _gu;
        users_structs.push(createUserStruct(_useraddr));
        tkn_mng.transfer(_useraddr, _alloc_amount);
    }
    
    function storeProduct(Product _pr) private {
        uint prod_id = _pr.product_id();
        
        products_contracts[prod_id] = _pr;
        products_structs.push(createProductStruct(prod_id));
    }
    
    function init_product(string memory _description, uint _dev, uint _rev, string memory _category) public onlyManager {
        Product product = new Product(productsNu, msg.sender, _description, _dev, _rev, _category);
        productsNu++;
        storeProduct(product);
    }
    
    function getThisBalance() public view returns (uint){
        return (tkn_mng.getBalanceOf(address(this)));
    }
    
    function getUserProfile(address _addr) public view returns (uint role, uint reputation, uint balance, string memory category) {
        return (users_contracts[_addr].role(), users_contracts[_addr].rep(), tkn_mng.getBalanceOf(_addr), users_contracts[_addr].category());
    }
    
    function getProductDetails(uint _prod_id) public view returns (uint dev, uint rev, string memory category, uint state, uint funded_sum) {
        require(_prod_id < productsNu, "Product does not exist!");
        Product prd = products_contracts[_prod_id];
        
        return (prd.dev(), prd.rev(), prd.category(), prd.getState(), prd.funded_sum());
    }
    
    function finance_product(uint _prod_id, uint _token_amount) public onlyFinancer {
        require(_prod_id < productsNu, "Product does not exist!");
        
        address fin_addr = msg.sender;
        tkn_mng.transferFrom(fin_addr, address(this), _token_amount);
        products_contracts[_prod_id].storeShare(fin_addr, _token_amount);
        
        if (products_contracts[_prod_id].getState() == uint(States.Teaming)){
            products_structs[_prod_id].currentState = States.Teaming;
        }
    }
    
    function withdraw_sum(uint _prod_id, uint _token_amount) public onlyFinancer {
        require(_prod_id < productsNu, "Product does not exist!");
        address fin_addr = msg.sender;
        require(products_contracts[_prod_id].shares(fin_addr) >= _token_amount, "You asked for more than you gave...");
        
        tkn_mng.transferFrom(address(this), fin_addr, _token_amount);
        products_contracts[_prod_id].withdrawShare(fin_addr, _token_amount);
    }
    
    function retireProduct(uint _prod_id) public onlyManager {
        require(_prod_id < productsNu, "Product does not exist!");
        require(products_contracts[_prod_id].getState() == uint(States.Funding), "Product is done funding already...");
        
        for(uint it = 0; it < products_contracts[_prod_id].getFinancersLength(); it++) {
            address _fin_add = products_contracts[_prod_id].financers(it);
            
            if (products_contracts[_prod_id].financer_exists(_fin_add)){
                tkn_mng.transferFrom(address(this), _fin_add, products_contracts[_prod_id].shares(_fin_add));
            }
        }
        
        products_contracts[_prod_id].giveBackAllFunds(); 
        products_structs[_prod_id].currentState = States.Retired;
    }
    
    function registerForEvaluation(uint _prod_id) public onlyEvaluator{
        require(_prod_id < productsNu, "Product does not exist!");
        require(keccak256(abi.encodePacked((users_contracts[msg.sender].category()))) == keccak256(abi.encodePacked((products_contracts[_prod_id].category()))), "You do not specialize in the product's category!");
        require(products_contracts[_prod_id].evaluator() == address(0), "There already is an evaluator for this product!");
        require(products_contracts[_prod_id].getState() == uint(States.Teaming));
        
        products_structs[_prod_id].applied_evaluator = msg.sender;
        products_contracts[_prod_id].storeEvaluator(msg.sender);
    }
    
    function registerForFreelancing(uint _prod_id, uint _dev_amount) public onlyFreelancer {
        require(_prod_id < productsNu, "Product does not exist!");
        require(keccak256(abi.encodePacked((users_contracts[msg.sender].category()))) == keccak256(abi.encodePacked((products_contracts[_prod_id].category()))), "You do not specialize in the product's category!");
        require(!products_contracts[_prod_id].freelancer_exists(msg.sender), "This freelancer has already registered!");
        require(_dev_amount > 0, "DEV sum must be bigger than 0!");
        require(products_contracts[_prod_id].getState() == uint(States.Teaming));
        
        products_structs[_prod_id].applied_freelancers.push(msg.sender);
        products_contracts[_prod_id].storeFreelancer(msg.sender);
        freelancers_map[msg.sender].rep = users_contracts[msg.sender].rep();
        
        if (_dev_amount >= products_contracts[_prod_id].dev()){
            freelancers_map[msg.sender].share = products_contracts[_prod_id].dev();
        }else{
            freelancers_map[msg.sender].share = _dev_amount; 
        }
    }

    function selectFreelancers(uint _prod_id) public onlyManager {
        require(_prod_id < productsNu, "Product does not exist!");
        require(products_contracts[_prod_id].getState() == uint(States.Teaming));
        
        Product current_product = products_contracts[_prod_id];
        uint dev_goal = products_contracts[_prod_id].dev();
        uint freel_index = 0;
        
        while(current_product.alloc_share() < dev_goal && freel_index < current_product.getFreelancersLength()) {
            // while not enough freelancers were selected
            
            address best_freelancer = current_product.freelancers(0); // current best freelancer is the first one
            uint best_fl_index = 0;
            
            for (uint j=1; j < current_product.getFreelancersLength(); j++) { // for every other applied freelancer
                address current_freelancer = current_product.freelancers(j);
                
                if (current_freelancer == address(0)){
                    continue;
                }
                
                if(freelancers_map[current_freelancer].rep > freelancers_map[best_freelancer].rep && 
                    (freelancers_map[current_freelancer].share + current_product.alloc_share()) <= dev_goal) { // if rep is better and share isnt bigger than max
                    best_freelancer = current_freelancer;
                    best_fl_index = j;
                }
            }

            if(freelancers_map[best_freelancer].share + current_product.alloc_share() > dev_goal) {
                break; // all remaining applied freelancers want too much share
            }

            products_structs[_prod_id].selected_freelancers.push(best_freelancer);
            products_structs[_prod_id].alloc_share += freelancers_map[best_freelancer].share; // best freelancer is selected and current allocated share is updated
            products_structs[_prod_id].applied_freelancers[best_fl_index] = address(0);
            
            products_contracts[_prod_id].teamFreelancer(best_freelancer);
            products_contracts[_prod_id].addAllocShare(freelancers_map[best_freelancer].share);
            products_contracts[_prod_id].resetFreelancer(best_fl_index);
            
            freel_index++;
        }

        if(current_product.alloc_share() >= dev_goal) {
            products_structs[_prod_id].currentState = States.Started; // can start developing this product
            products_contracts[_prod_id].setState(uint(States.Started));
        }
        else {
            products_structs[_prod_id].currentState = States.Teaming;
            products_contracts[_prod_id].setState(uint(States.Teaming));
        }
    }

    function notifyManager(uint _prod_id) public onlyFreelancer { // finished development
        require(_prod_id < productsNu, "Product does not exist!");
        require(products_contracts[_prod_id].getState() == uint(States.Started));
    
        Product current_product = products_contracts[_prod_id];
        
        if (current_product.chosen_freelancer_exists(msg.sender)){
            products_contracts[_prod_id].setState(uint(States.Finished));
            products_structs[_prod_id].currentState = States.Finished;
        }else{
            revert("You are not part of the product's freelancing team!");
        }
    }

    function acceptResult(uint _prod_id, bool accept) public onlyManager {
        require(_prod_id < productsNu, "Product does not exist!");
        require(products_contracts[_prod_id].getState() == uint(States.Finished));
        
        Product current_product = products_contracts[_prod_id];
        address man_addr = current_product.manager_address();
        
        // if manager accepts to pay freelancers
        if(accept) {
            tkn_mng.transferFrom(address(this), man_addr, current_product.rev());
            users_contracts[man_addr].rep_up();

            for (uint j=0; j<current_product.getChosenFreelancersLength(); j++) {
                address current_freelancer = current_product.chosen_freelancers(j);
                
                //transfer money to freelancer based on his share
                tkn_mng.transferFrom(address(this), current_freelancer, freelancers_map[current_freelancer].share);
                
                //increment freelancer rep
                if(freelancers_map[current_freelancer].rep < 10) {
                    freelancers_map[current_freelancer].rep += 1;
                }
                users_contracts[current_freelancer].rep_up();
            }
            products_contracts[_prod_id].setState(uint(States.Published));
            products_structs[_prod_id].currentState = States.Published;
        }
        else {
            products_contracts[_prod_id].setState(uint(States.Evaluation));
            products_structs[_prod_id].currentState = States.Evaluation;
        }
    }

    function evaluateProduct(uint _prod_id, bool accept) public onlyEvaluator {
        require(_prod_id < productsNu, "Product does not exist!");
        require(products_contracts[_prod_id].getState() == uint(States.Evaluation));
        Product current_product = products_contracts[_prod_id];
        require(msg.sender == current_product.evaluator(), "You are not the evaluator for this product!");
        
        address man_addr = current_product.manager_address();
        tkn_mng.transferFrom(address(this), msg.sender, current_product.rev());
        
        // if evaluator accepts to pay freelancers
        if(accept) {
            for (uint j=0; j<current_product.getChosenFreelancersLength(); j++) {
                address current_freelancer = current_product.chosen_freelancers(j);
                
                //transfer money to freelancer based on his share
                tkn_mng.transferFrom(address(this), current_freelancer, freelancers_map[current_freelancer].share);
                
                //increment freelancer rep
                if(freelancers_map[current_freelancer].rep < 10) {
                    freelancers_map[current_freelancer].rep += 1;
                }
                users_contracts[current_freelancer].rep_up();
            }
            products_contracts[_prod_id].setState(uint(States.Published));
            products_structs[_prod_id].currentState = States.Published;
            
            if(freelancers_map[man_addr].rep > 1) {
                    freelancers_map[man_addr].rep -= 1;
                }
            users_contracts[man_addr].rep_down();
        }
        else {
            for (uint j=0; j<current_product.getChosenFreelancersLength(); j++) {
                address current_freelancer = current_product.chosen_freelancers(j);

                //decrement freelancer rep
                if(freelancers_map[current_freelancer].rep > 1) {
                    freelancers_map[current_freelancer].rep -= 1;
                }
                users_contracts[current_freelancer].rep_down();
            }
            // mark the current product for redevelopment
            products_structs[_prod_id].alloc_share = 0;
            delete products_structs[_prod_id].applied_evaluator;
            delete products_structs[_prod_id].applied_freelancers;
            delete products_structs[_prod_id].selected_freelancers;
            products_contracts[_prod_id].deleteAllFreelancersAndEvaluator();
            
            products_contracts[_prod_id].setState(uint(States.Teaming));
            products_structs[_prod_id].currentState = States.Teaming;
            }
    }
}

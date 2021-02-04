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
    
    enum States{ Funding, Teaming, Started, Finished, Retired, Evaluation }
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
        address freelancer_3_addr = 0x617F2E2fD72FD9D5503197092aC168c91465E7f2;
        
        address evaluator_0_addr = 0x17F6AD8Ef982297579C203069C1DbfFE4348c372;
        address evaluator_1_addr = 0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678;
        address evaluator_2_addr = 0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7;
        address evaluator_3_addr = 0x1aE0EA34a72D944a8C7603FfB3eC30a6669E454C;
        
        address financer_0_addr = 0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB;
        address financer_1_addr = 0x583031D1113aD414F02576BD6afaBfb302140225;
        address financer_2_addr = 0xdD870fA1b7C4700F2BD7f44238821C26f7392148;
        
        // Ganache
        /*address manager_addr = 0x9D5818ac8D429B4aB51Ff0e40ec83790755eD3a5;
        
        address freelancer_0_addr = 0xc9980FF6e1370dc7EFA5607C662ebB7953dEe231;
        address freelancer_1_addr = 0xC2087837E54dDeD0e57DD0cF74826680A2E9D349;
        address freelancer_2_addr = 0xc06D847E919bF34507c866260884B4B415171bA3;
        address freelancer_3_addr = 0xd1f079782484620250afdAbd5E85F793601B9Bc3;
        
        address evaluator_0_addr = 0x3F0C6e33b12e7144450B2785269e27FAFD86a28c;
        address evaluator_1_addr = 0x049Eb93680C7b8b98BaC6a54D874910fd88d4564;
        address evaluator_2_addr = 0xeF43023060eCa4Aad93b4368322Ffe823770926C;
        address evaluator_3_addr = 0xB3c81f904B6DfDed618BbD38BEd3eAF6CaE42286;
        
        address financer_0_addr = 0x2e9ec3A179D45B767a2b7F251b13C8038afBf8A7;
        address financer_1_addr = 0x4EFE3F7AE0aF8C1E33806B76f44fa041650CEce2;
        address financer_2_addr = 0x39565f1a1e5058465C00558A1734b92051E5dD5f;*/
        
        // create user contracts and store
        storeAndAllocUser(_uf.new_manager(manager_addr, "manager"), 2000);
        
        storeAndAllocUser(_uf.new_freelancer(freelancer_0_addr, "freelancer-0", "Cryptocurrency"), 2500);
        storeAndAllocUser(_uf.new_freelancer(freelancer_1_addr, "freelancer-1", "Games"), 3000);
        storeAndAllocUser(_uf.new_freelancer(freelancer_2_addr, "freelancer-2", "Games"), 7500);
        storeAndAllocUser(_uf.new_freelancer(freelancer_3_addr, "freelancer-3", "Cryptocurrency"), 4400);
        
        storeAndAllocUser(_uf.new_evaluator(evaluator_0_addr, "evaluator-0", "Games"), 700);
        storeAndAllocUser(_uf.new_evaluator(evaluator_1_addr, "evaluator-1", "Cryptocurrency"), 950);
        storeAndAllocUser(_uf.new_evaluator(evaluator_2_addr, "evaluator-2", "Games"), 1100);
        storeAndAllocUser(_uf.new_evaluator(evaluator_3_addr, "evaluator-3", "Cryptocurrency"), 500);
        
        storeAndAllocUser(_uf.new_financer(financer_0_addr, "financer-0"), 30000);
        storeAndAllocUser(_uf.new_financer(financer_1_addr, "financer-1"), 25000);
        storeAndAllocUser(_uf.new_financer(financer_2_addr, "financer-2"), 50000);
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
    
    function getUserProfile(address _addr) public view returns (string memory name, string memory role, uint reputation, uint balance, string memory category) {
        string memory str_role;
        uint256 int_role = uint(users_contracts[_addr].role());
        GenericUser usr = users_contracts[_addr];
        
        if (int_role == 0){
            str_role = "Manager";
        }else if (int_role == 1){
            str_role = "Freelancer";
        }else if (int_role == 2){
            str_role = "Evaluator";
        }else{
            str_role = "Financer";
        }
        
        return (usr.name(), str_role, usr.rep(), tkn_mng.getBalanceOf(_addr), usr.category());
    }
    
    function getProductDetails(uint _prod_id) public view returns (address manager_address, string memory description, uint dev, uint rev, string memory category, string memory state, uint funded_sum) {
        require(_prod_id < productsNu, "Product does not exist!");
        
        string memory str_state;
        uint int_state = products_contracts[_prod_id].getState();
        Product prd = products_contracts[_prod_id];
        
        if (int_state == 0){
            str_state = "Funding";
        }else if (int_state == 1){
            str_state = "Teaming";
        }else if (int_state == 2){
            str_state = "Started";
        }else if (int_state == 3){
            str_state = "Finished";
        }else if (int_state == 4){
            str_state = "Retired";
        }else{
            str_state = "Evaluation";
        }
        
        return (prd.manager_address(), prd.description(), prd.dev(), prd.rev(), prd.category(), str_state, prd.funded_sum());
    }
    
    function finance_product(uint _prod_id, uint _token_amount) public onlyFinancer {
        require(_prod_id < productsNu, "Product does not exist!");
        
        address fin_addr = msg.sender;
        address man_addr = products_contracts[_prod_id].manager_address();
        tkn_mng.transferFrom(fin_addr, man_addr, _token_amount);
        products_contracts[_prod_id].storeShare(fin_addr, _token_amount);
        
        if (products_contracts[_prod_id].getState() == uint(States.Teaming)){
            products_structs[_prod_id].currentState = States.Teaming;
        }
    }
    
    function withdraw_sum(uint _prod_id, uint _token_amount) public onlyFinancer {
        require(_prod_id < productsNu, "Product does not exist!");
        address fin_addr = msg.sender;
        address man_addr = products_contracts[_prod_id].manager_address();
        require(products_contracts[_prod_id].shares(fin_addr) >= _token_amount, "You asked for more than you gave...");
        
        tkn_mng.transferFrom(man_addr, fin_addr, _token_amount);
        products_contracts[_prod_id].withdrawShare(fin_addr, _token_amount);
    }
    
    function retireProduct(uint _prod_id) public onlyManager {
        require(_prod_id < productsNu, "Product does not exist!");
        require(products_contracts[_prod_id].getState() == uint(States.Funding), "Product is done funding already...");
        
        address man_addr = msg.sender;
        for(uint it = 0; it < products_contracts[_prod_id].getFinancersLength(); it++) {
            address _fin_add = products_contracts[_prod_id].financers(it);
            
            if (products_contracts[_prod_id].financer_exists(_fin_add)){
                tkn_mng.transferFrom(man_addr, _fin_add, products_contracts[_prod_id].shares(_fin_add));
            }
        }
        
        products_contracts[_prod_id].giveBackAllFunds(); 
        products_structs[_prod_id].currentState = States.Retired;
    }
    
    function getListOfProducts() public view onlyFreelancerOrEvaluator returns (prodStruct[] memory){
    	return products_structs;
    }
    
    function registerForEvaluation(uint _prod_id) public onlyEvaluator{
        require(_prod_id < productsNu, "Product does not exist!");
        require(keccak256(abi.encodePacked((users_contracts[msg.sender].category()))) == keccak256(abi.encodePacked((products_contracts[_prod_id].category()))), "You do not specialize in the product's category!");
        require(products_contracts[_prod_id].evaluator() == address(0), "There already is an evaluator for this product!");
        
        products_structs[_prod_id].applied_evaluator = msg.sender;
        products_contracts[_prod_id].storeEvaluator(msg.sender);
    }
    
    function registerForFreelancing(uint _prod_id, uint _dev_amount) public onlyFreelancer {
        require(_prod_id < productsNu, "Product does not exist!");
        require(keccak256(abi.encodePacked((users_contracts[msg.sender].category()))) == keccak256(abi.encodePacked((products_contracts[_prod_id].category()))), "You do not specialize in the product's category!");
        require(!products_contracts[_prod_id].freelancer_exists(msg.sender), "This freelancer has already registered!");
        require(_dev_amount > 0, "DEV sum must be bigger than 0!");
        
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
            products_structs[_prod_id].currentState = States.Retired;
            products_contracts[_prod_id].setState(uint(States.Retired));
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
            users_contracts[man_addr].rep_up();

            for (uint j=0; j<current_product.getChosenFreelancersLength(); j++) {
                address current_freelancer = current_product.chosen_freelancers(j);
                
                //transfer money to freelancer based on his share
                tkn_mng.transferFrom(man_addr, current_freelancer, freelancers_map[current_freelancer].share);
                
                //increment freelancer rep
                if(freelancers_map[current_freelancer].rep < 10) {
                    freelancers_map[current_freelancer].rep += 1;
                }
                users_contracts[current_freelancer].rep_up();
            }
            products_contracts[_prod_id].setState(uint(States.Retired));
            products_structs[_prod_id].currentState = States.Retired;
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
        tkn_mng.transferFrom(man_addr, msg.sender, current_product.rev());
        
        // if evaluator accepts to pay freelancers
        if(accept) {
            for (uint j=0; j<current_product.getChosenFreelancersLength(); j++) {
                address current_freelancer = current_product.chosen_freelancers(j);
                
                //transfer money to freelancer based on his share
                tkn_mng.transferFrom(man_addr, current_freelancer, freelancers_map[current_freelancer].share);
                
                //increment freelancer rep
                if(freelancers_map[current_freelancer].rep < 10) {
                    freelancers_map[current_freelancer].rep += 1;
                }
                users_contracts[current_freelancer].rep_up();
            }
            products_contracts[_prod_id].setState(uint(States.Retired));
            products_structs[_prod_id].currentState = States.Retired;
            
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

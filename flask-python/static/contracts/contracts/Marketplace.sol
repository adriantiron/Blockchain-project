// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

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
    Factory private uf;
    uint public productsNu = 0;
        
    enum States{ defined, started, finished}
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
        address adr;
        uint share;
    }

    struct prodStruct{
        uint product_id;
        address manager_address;
        string description;
        uint dev;
        uint rev;
        string category;
        States currentState;
    }

    constructor (Factory _uf, ERC20token_manager _tkn_mng){
        tkn_mng = _tkn_mng;
        uf = _uf;
    }
    
    modifier onlyManager {
        require(users_contracts[msg.sender].role() == uint(Roles.Manager));
        _;
    }

    function storeUsers(address[] memory _addresses) public {
        // Ganache
        address manager_addr = _addresses[0];
        
        address freelancer_0_addr = _addresses[1];
        address freelancer_1_addr = _addresses[2];
        address freelancer_2_addr = _addresses[3];
        address freelancer_3_addr = _addresses[4];
        
        address evaluator_0_addr = _addresses[5];
        address evaluator_1_addr = _addresses[6];
        address evaluator_2_addr = _addresses[7];
        address evaluator_3_addr = _addresses[8];
        
        address financer_0_addr = _addresses[9];
        address financer_1_addr = _addresses[10];
        address financer_2_addr = _addresses[11];
        
        // create user contracts and store
        storeAndAllocUser(uf.new_manager(manager_addr, "manager"), 2000);
        
        storeAndAllocUser(uf.new_freelancer(freelancer_0_addr, "freelancer-0", "Cryptocurrency"), 2500);
        storeAndAllocUser(uf.new_freelancer(freelancer_1_addr, "freelancer-1", "Games"), 3000);
        storeAndAllocUser(uf.new_freelancer(freelancer_2_addr, "freelancer-2", "Games"), 7500);
        storeAndAllocUser(uf.new_freelancer(freelancer_3_addr, "freelancer-3", "Cryptocurrency"), 4400);
        
        storeAndAllocUser(uf.new_evaluator(evaluator_0_addr, "evaluator-0", "Games"), 700);
        storeAndAllocUser(uf.new_evaluator(evaluator_1_addr, "evaluator-1", "Cryptocurrency"), 950);
        storeAndAllocUser(uf.new_evaluator(evaluator_2_addr, "evaluator-2", "Games"), 1100);
        storeAndAllocUser(uf.new_evaluator(evaluator_3_addr, "evaluator-3", "Cryptocurrency"), 500);
        
        storeAndAllocUser(uf.new_financer(financer_0_addr, "financer-0"), 30000);
        storeAndAllocUser(uf.new_financer(financer_1_addr, "financer-1"), 25000);
        storeAndAllocUser(uf.new_financer(financer_2_addr, "financer-2"), 50000);
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
        
        if (int_role == 0){
            str_role = "Manager";
        }else if (int_role == 1){
            str_role = "Freelancer";
        }else if (int_role == 2){
            str_role = "Evaluator";
        }else{
            str_role = "Financer";
        }
        
        return (users_contracts[_addr].name(), str_role, users_contracts[_addr].rep(), tkn_mng.getBalanceOf(_addr), users_contracts[_addr].category());
    }
    
    function getProductDetails(uint _prod_id) public view returns (address manager_address, string memory description, uint dev, uint rev, string memory category, string memory state) {
        string memory str_state;
        uint int_state = products_contracts[_prod_id].getState();
        
        if (int_state == 0){
            str_state = "Defined";
        }else if (int_state == 1){
            str_state = "Started";
        }else{
            str_state = "Finished";
        }
        
        return (products_contracts[_prod_id].manager_address(), products_contracts[_prod_id].description(), products_contracts[_prod_id].dev(), products_contracts[_prod_id].rev(), products_contracts[_prod_id].category(), str_state);
    }
}

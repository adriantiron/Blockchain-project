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
    uint public productsNu = 0;
        
    enum States{ Funding, Started, Finished, Retired }
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
            str_state = "Funding";
        }else if (int_state == 1){
            str_state = "Started";
        }else if (int_state == 2){
            str_state = "Finished";
        }else{
            str_state = "Retired";
        }
        
        return (products_contracts[_prod_id].manager_address(), products_contracts[_prod_id].description(), products_contracts[_prod_id].dev(), products_contracts[_prod_id].rev(), products_contracts[_prod_id].category(), str_state);
    }
    
    function finance_product(uint _prod_id, uint _token_amount) public onlyFinancer {
        require(_prod_id < productsNu, "Product does not exist!");
        
        address fin_addr = msg.sender;
        address man_addr = products_contracts[_prod_id].manager_address();
        tkn_mng.transferFrom(fin_addr, man_addr, _token_amount);
        products_contracts[_prod_id].storeShare(fin_addr, _token_amount);
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
    }
}

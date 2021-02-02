// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "./GenericUser.sol";
import "./Factory.sol";
import "./ERC20token_manager.sol";

contract Marketplace {

    mapping(address => GenericUser) private users_contracts;
    genericUser[] private users_structs;
    product[] private products;
    ERC20token_manager private tkn_mng;
    
    enum States{ defined, started, finished}

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

    struct product{
        uint product_id;
        address manager_address;
        string description;
        uint dev;
        uint rev;
        string category;
        address evaluator;
        uint freelancersNr;
        mapping (uint => freelancerShare) freelancingShares;
        States currentState;
    }


    constructor (Factory _uf, ERC20token_manager _tkn_mng){
        tkn_mng = _tkn_mng;
        
        // choose addresses from the remix deploy & run tab
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
    
    function createStruct(address _addr) private view returns (genericUser memory){
        genericUser memory gu;
        gu.addr = users_contracts[_addr].addr();
        gu.role = users_contracts[_addr].role();
        gu.rep = users_contracts[_addr].rep();
        gu.name = users_contracts[_addr].name();
        gu.category = users_contracts[_addr].category();
        
        return gu;
    }
    
    function storeAndAllocUser(GenericUser _gu, uint _alloc_amount) private {
        address _useraddr = _gu.addr();
        
        users_contracts[_useraddr] = _gu;
        users_structs.push(createStruct(_useraddr));
        tkn_mng.transfer(_useraddr, _alloc_amount);
    }
    
    function getUserProfile(address _addr) public view returns (string memory name, string memory role, uint reputation, uint balance, string memory category) {
        string memory str_role;
        uint256 int_role = users_contracts[_addr].role();
        
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
}

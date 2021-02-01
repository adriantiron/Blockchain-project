pragma solidity >=0.7.0 <=0.7.3;

contract Marketplace {

    address owner;
    uint productsNr;

    enum States{ defined, started, finished}

    struct genericUser{
        address payable adr;
        string role;
        string name;
        uint rep;
        string category;
    }

    struct freelancerShare{
        address adr;
        uint share;
    }

    struct product{
        uint product_id;
        address manager_adress;
        string description;
        uint dev;
        uint rev;
        string category;
        address evaluator;
        uint freelancersNr;
        mapping (uint => freelancerShare) shares;
        States currentState;
    }

    mapping (address => genericUser) users;
    mapping (uint => product) products;

    constructor(){
        productsNr = 0;
        owner = msg.sender;
    }

    function applyForRole(string calldata role, string calldata name, string calldata category) public {
        require(keccak256(bytes(role)) == keccak256(bytes("manager")) ||
        keccak256(bytes(role)) ==  keccak256(bytes("freelancer")) ||
        keccak256(bytes(role)) == keccak256(bytes("evaluator")), "role must be manager, freelancer or evaluator");


        require(keccak256(bytes(role)) != keccak256(bytes("manager")) &&
        keccak256(bytes(category)) != keccak256(bytes("")), "must have a category" );
       users[msg.sender] = genericUser(msg.sender,role, name, 5, category);
    }


    function myProfile() public view returns(string memory, string memory, uint, string memory) {
       require(users[msg.sender].adr == msg.sender, "address not found");
       return (users[msg.sender].name, users[msg.sender].role, users[msg.sender].rep, users[msg.sender].category);

    }

    // function applyForFinancer(string name) public {
    //   // trebuie sa vedem cum ii dam token-uri
    // }
}

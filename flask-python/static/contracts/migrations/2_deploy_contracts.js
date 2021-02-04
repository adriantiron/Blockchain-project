var ERC20token = artifacts.require("ERC20token");
var ERC20token_manager = artifacts.require("ERC20token_manager");
var GenericUser = artifacts.require("GenericUser");
var Manager = artifacts.require("Manager");
var Freelancer = artifacts.require("Freelancer");
var Financer = artifacts.require("Financer");
var Evaluator = artifacts.require("Evaluator")
var Factory = artifacts.require("Factory")
var Marketplace = artifacts.require("Marketplace")

module.exports = async function (deployer) {

    await deployer.deploy(ERC20token_manager);
    var token_manager = await ERC20token_manager.deployed();

    await deployer.deploy(Factory);
    var factory = await Factory.deployed();

    await deployer.deploy(Marketplace, factory.address, token_manager.address, {gas: 20000000});
};

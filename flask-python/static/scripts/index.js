var web3 = new Web3(new Web3.providers.HttpProvider('http://127.0.0.1:7545'))
var mp_contract;


async function init_product(sender, _description, _dev,  _rev, _category) {
    let init_prod = await mp_contract.methods.init_product(_description, _dev, _rev, _category).send({from: sender, gas: 20000000});
    console.log("Product initialized: ", init_prod);
}

async function getThisBalance() {
    let get_balance = await mp_contract.methods.getThisBalance().call();
    console.log("Contract balance: ", get_balance);
}

async function getUserProfile(_addr) {
    let get_user = await mp_contract.methods.getUserProfile(_addr).call();
    console.log("User data: ", get_user);
}

async function getProductDetails(_prod_id) {
    let prod_details = await mp_contract.methods.getProductDetails(_prod_id).call();
    console.log("Product details: ", prod_details);
}

async function finance_product(sender, _prod_id, _token_amount) {
    let finance_prod = await mp_contract.methods.finance_product(_prod_id, _token_amount).send({from: sender, gas: 20000000});
    console.log("Product financed: ", finance_prod);
}

async function withdraw_sum(sender, _prod_id, _token_amount) {
    let withdraw = await mp_contract.methods.withdraw_sum(_prod_id, _token_amount).send({from: sender, gas: 20000000});
    console.log("Withdraw: ", withdraw);
}

async function retireProduct(sender, _prod_id) {
    let retire = await mp_contract.methods.retireProduct(_prod_id).send({from: sender, gas: 20000000});
    console.log("Retire product: ", retire);
}

async function registerForEvaluation(sender, _prod_id) {
    let registerEval = await mp_contract.methods.registerForEvaluation(_prod_id).send({from: sender, gas: 20000000});
    console.log("Register evaluator: ", registerEval);
}

async function registerForFreelancing(sender, _prod_id, _dev_amount) {
    let registerFreel = await mp_contract.methods.registerForFreelancing(_prod_id, _dev_amount).send({from: sender, gas: 20000000});
    console.log("Register freelancer: ", registerFreel);
}

async function selectFreelancers(sender, _prod_id) {
    let selectFreel = await mp_contract.methods.selectFreelancers(_prod_id).send({from: sender, gas: 20000000});
    console.log("Select freelancers: ", selectFreel);
}

async function notifyManager(sender, _prod_id) {
    let notify = await mp_contract.methods.notifyManager(_prod_id).send({from: sender, gas: 20000000});
    console.log("Notify Manager: ", notify);
}

async function acceptResult(sender, _prod_id, accept) {
    let acceptRes = await mp_contract.methods.acceptResult(_prod_id, accept).send({from: sender, gas: 20000000});
    console.log("Manager accept: ", acceptRes);
}

async function evaluateProduct(sender, _prod_id, accept) {
    let evaluate = await mp_contract.methods.evaluateProduct(_prod_id, accept).send({from: sender, gas: 20000000});
    console.log("Evaluator accept: ", evaluate);
}

async function main() {
    var contracts = await getContracts();
    var accounts = await promisify(web3.eth.getAccounts);

    var mp_json = contracts["Marketplace"];

    mp_contract = new web3.eth.Contract(mp_json['abi'], mp_json['networks']['5777']['address']);
    
    // let mp_store_users = await mp_contract.methods.storeUsers(accounts).call(); // does not have enough gas for this..

    await init_product(accounts[0], "Description", 4000, 1000, "Games");
    await getThisBalance();
    await getUserProfile(accounts[0]);
    await getProductDetails(1);
    await finance_product(accounts[1], 1, 2000); // vm revert error....
    await finance_product(accounts[2], 1, 2000);
    await getThisBalance();
}

async function getContracts() {
    var response = await fetch('http://localhost:5000/getContracts', {});
    var data = await response.json();
    return data.contracts;
}


var promisify = (fun, params=[]) => {
  return new Promise((resolve, reject) => {
    fun(...params, (err, data) => {
      if (err !== null) reject(err);
      else resolve(data);
    });
  });
}

main();

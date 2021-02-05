var web3 = new Web3(new Web3.providers.HttpProvider('http://127.0.0.1:7545'))
var mp_contract, accounts;


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
    accounts = await promisify(web3.eth.getAccounts);

    var mp_json = contracts["Marketplace"];

    mp_contract = new web3.eth.Contract(mp_json['abi'], mp_json['networks']['5777']['address']);
    
    // let mp_store_users = await mp_contract.methods.storeUsers(accounts).call(); // does not have enough gas for this..

    test_case_1();
    //test_case_2();
    //test_case_3();
    //test_case_4();

}

async function getContracts() {
    var response = await fetch('http://localhost:5000/getContracts', {});
    var data = await response.json();
    return data.contracts;
}


async function test_case_1() {
    await init_product(accounts[0], "Description", 12000, 1000, "Games");
    await getThisBalance();
    await getUserProfile(accounts[6]);
    await getUserProfile(accounts[7]);
    await getProductDetails(0);
    await finance_product(accounts[6], 0, 5000);
    await finance_product(accounts[7], 0, 7000);
    await getThisBalance();
    await getUserProfile(accounts[6]);
    await getUserProfile(accounts[7]);
    await withdraw_sum(accounts[7], 0, 2000);
    await getUserProfile(accounts[7]);
    await retireProduct(accounts[0], 0);
    await getUserProfile(accounts[6]);
    await getUserProfile(accounts[7]);
}

async function test_case_2() {
    await init_product(accounts[0], "Description", 12000, 1000, "Games");
    await getThisBalance();
    await getUserProfile(accounts[6]);
    await getUserProfile(accounts[7]);
    await getProductDetails(1);
    await finance_product(accounts[6], 1, 5000);
    await finance_product(accounts[7], 1, 8000);
    await getThisBalance();
    await getUserProfile(accounts[6]);
    await getUserProfile(accounts[7]);
    await registerForEvaluation(accounts[4], 1);
    await registerForFreelancing(accounts[2], 1, 3000);
    await registerForFreelancing(accounts[3], 1, 9000);
    await selectFreelancers(accounts[0], 1);
    await notifyManager(accounts[2], 1);
    await getUserProfile(accounts[2]);
    await getUserProfile(accounts[3]);
    await getUserProfile(accounts[0]);
    await acceptResult(accounts[0], 1, true);
    await getUserProfile(accounts[2]);
    await getUserProfile(accounts[3]);
    await getUserProfile(accounts[0]);
}

async function test_case_3() {
    await init_product(accounts[0], "Description", 12000, 1000, "Games");
    await getThisBalance();
    await getUserProfile(accounts[6]);
    await getUserProfile(accounts[7]);
    await getProductDetails(2);
    await finance_product(accounts[6], 2, 5000);
    await finance_product(accounts[7], 2, 8000);
    await getThisBalance();
    await getUserProfile(accounts[6]);
    await getUserProfile(accounts[7]);
    await registerForEvaluation(accounts[4], 2);
    await registerForFreelancing(accounts[2], 2, 3000);
    await registerForFreelancing(accounts[3], 2, 9000);
    await selectFreelancers(accounts[0], 2);
    await notifyManager(accounts[2], 2);
    await getUserProfile(accounts[2]);
    await getUserProfile(accounts[3]);
    await acceptResult(accounts[0], 2, false);
    await getUserProfile(accounts[2]);
    await getUserProfile(accounts[3]);
    await getUserProfile(accounts[0]);
    await getUserProfile(accounts[4]);
    await evaluateProduct(accounts[4], 2, true);
    await getUserProfile(accounts[2]);
    await getUserProfile(accounts[3]);
    await getUserProfile(accounts[0]);
    await getUserProfile(accounts[4]);
}

async function test_case_4() {
    await init_product(accounts[0], "Description", 12000, 1000, "Games");
    await getThisBalance();
    await getUserProfile(accounts[6]);
    await getUserProfile(accounts[7]);
    await getProductDetails(3);
    await finance_product(accounts[6], 3, 5000);
    await finance_product(accounts[7], 3, 8000);
    await getThisBalance();
    await getUserProfile(accounts[6]);
    await getUserProfile(accounts[7]);
    await registerForEvaluation(accounts[4], 3);
    await registerForFreelancing(accounts[2], 3, 3000);
    await registerForFreelancing(accounts[3], 3, 9000);
    await selectFreelancers(accounts[0], 3);
    await notifyManager(accounts[2], 3);
    await getUserProfile(accounts[2]);
    await getUserProfile(accounts[3]);
    await acceptResult(accounts[0], 3, false);
    await getUserProfile(accounts[2]);
    await getUserProfile(accounts[3]);
    await getUserProfile(accounts[0]);
    await getUserProfile(accounts[4]);
    await evaluateProduct(accounts[4], 3, false);
    await getUserProfile(accounts[2]);
    await getUserProfile(accounts[3]);
    await getUserProfile(accounts[0]);
    await getUserProfile(accounts[4]);
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

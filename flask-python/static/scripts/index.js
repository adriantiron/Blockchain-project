var web3 = new Web3(new Web3.providers.HttpProvider('http://127.0.0.1:7545'))

// var balance = ''

// web3.eth.getBalance('0xBd7e6D800A946b91A4f0dcB07Caf4FF3bAA733A8', (err, wei) => {
// 	balance = web3.fromWei(wei, 'ether')
// 	displayBalance()
// })

// function displayBalance() {
// 	console.log(balance.toString())
// }

async function getContracts() {
    var response = await fetch('http://localhost:5000/getContracts', {});
    var data = await response.json();
    return data.contracts;
}

async function main() {
    var contracts = await getContracts();
    var accounts = await promisify(web3.eth.getAccounts);

    var mp_json = contracts["Marketplace"];

    var mp_contract = new web3.eth.Contract(mp_json['abi'], mp_json['networks']['5777']['address']);
    
    let mp_store_users = await mp_contract.methods.storeUsers(accounts).call();
    let mng_prof = await mp_contract.methods.getUserProfile(accounts[0]).call();
    console.log(mng_prof);
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

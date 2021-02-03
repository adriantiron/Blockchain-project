var Web3 = require('web3')

var web3 = new Web3(new Web3.providers.HttpProvider('http://127.0.0.1:7545'))
var balance = ''

// web3.eth.getBalance('0xBd7e6D800A946b91A4f0dcB07Caf4FF3bAA733A8', (err, wei) => {
// 	balance = web3.fromWei(wei, 'ether')
// 	displayBalance()
// })

// function displayBalance() {
// 	console.log(balance.toString())
// }

async function getContracts() {
    const response = await fetch('http://localhost:5000/getContracts', {});
    const data = await response.json();
    return data.contracts;
}

getContracts().then((contracts) => {
    var JsonMarketplace = contracts["Marketplace"]

    var Web3Marketplace = web3.eth.contract(JsonMarketplace['abi'], JsonMarketplace['networks']['5777']['address']);
    console.log(Web3Marketplace);
});

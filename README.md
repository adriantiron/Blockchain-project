# [Blockchain-project](https://profs.info.uaic.ro/~eonica/blockchain/eval.html#project)

### Team Members: 
* Tiron Adrian
* Ihnatiw Stefan

### Structure
In the base folder you'll find all the contracts used. They can be opened and analyzed without going through the paths.

In the `flask-python` folder you can find the _Flask_ server and quick-run script files. In the `static` folder are the smart contracts and the _JavaScript_ files used to deploy the contracts automatically and run some use cases. 

### How to run (_requirements_: Python w/ Flask, Ganache, Truffle):
1. Create new workspace in ganache with gas 20.000.000.
2. Add some user addresses from your local ganache workspace to the Marketplace.sol constructor (they need to be hardcoded...).
2. Compile contracts with `truffle migrate`.
3. Use one of the provided script files to run flask server (Windows Powershell or CMD).
4. In `localhost:5000` check console test cases.

**Note**: We didn't manage to implement an UI, but we have implementations attempting to solve all the other components, from _market initialization_ to _product finalizing_.

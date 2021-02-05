(async () => {
  try {
    console.log("***START SCRIPT***");
      
    const ft_meta = JSON.parse(await remix.call('fileManager', 'getFile', 'browser/artifacts/Factory.json'));
    const tm_meta = JSON.parse(await remix.call('fileManager', 'getFile', 'browser/artifacts/ERC20token_manager.json'));
    const mp_meta = JSON.parse(await remix.call('fileManager', 'getFile', 'browser/artifacts/Marketplace.json'));
    
    console.log("Accessing web3provider...");
    // the variable web3Provider is a remix global variable object
    const accounts = await web3.eth.getAccounts()
    
    console.log("Creating factories...");
    // Create an instance of Contracts Factories
    let ft_factory = new web3.eth.Contract(ft_meta.abi);
    let tm_factory = new web3.eth.Contract(tm_meta.abi);
    let mp_factory = new web3.eth.Contract(mp_meta.abi);
    
    
    console.log("Creating contract instances...");
    
    console.log("Deploying factory contract...");
    let ft_contract = ft_factory.deploy({data: ft_meta.data.bytecode.object});
    let ft_contract_instance = await ft_contract.send({
      from: accounts[0],
      gas: 10000000,
      gasPrice: '30000000000'
    });
    
    console.log("Deploying token manager contract...");
    let tm_contract = tm_factory.deploy({data: tm_meta.data.bytecode.object});
    let tm_contract_instance = await tm_contract.send({
      from: accounts[0],
      gas: 10000000,
      gasPrice: '30000000000'
    });
    
    console.log("Deploying marketplace contract...");
    let mp_contract = mp_factory.deploy({
      data: mp_meta.data.bytecode.object,
      arguments: [ft_contract_instance.options.address, tm_contract_instance.options.address]
    });
    let mp_contract_instance = await mp_contract.send({
      from: accounts[0],
      gas: 25000000,
      gasPrice: '30000000000'
    });

    console.log('\tMarketplace deployed!')
    
    console.log("Getting user profiles...");
    
    let mng_method = await mp_contract_instance.methods.getUserProfile(accounts[0]);
    let frln_method = await mp_contract_instance.methods.getUserProfile(accounts[2]);
    let evl_method = await mp_contract_instance.methods.getUserProfile(accounts[6]);
    let finc_method = await mp_contract_instance.methods.getUserProfile(accounts[10]);
    
    let mng_prof = await mng_method.call({from: accounts[12]});
    let frln_prof = await frln_method.call({from: accounts[12]});
    let evl_prof = await evl_method.call({from: accounts[12]});
    //let finc_prof = await finc_method.call({from: accounts[12]});
    
    console.log(mng_prof);
    console.log(frln_prof);
    console.log(evl_prof);
    //console.log(finc_prof);
    
    console.log("initializing a product...")
    let init_prod_method = await mp_contract_instance.methods.init_product("description", 12000, 1000, "Games");
    await init_prod_method.call({ from: accounts[0]});
    
    console.log("Getting product details...");
    let prod_det_method = await mp_contract_instance.methods.getProductDetails(0);
    let prod_det = await prod_det_method.call({ from: accounts[12]});
    console.log(prod_det);
    
  } catch (e) {
    console.error(e);
  }
})();
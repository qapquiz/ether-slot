const SlotMachineSpinner = artifacts.require("./SlotMachineSpinner.sol");

contract('SlotMachineSpinner', async (accounts) => {
  const owner = accounts[0];
  const other = accounts[1];

  let instance;

  before('setup contract for each test', async () => {
    instance = await SlotMachineSpinner.new();
    await web3.eth.sendTransaction({from: owner, to: instance.address, value: web3.toWei('10', 'ether')});
  });

  it('Owner is contract creator', async () => {
    const contractOwner = await instance.owner();
    assert.equal(contractOwner, owner);
  });

  it('Contract should have some Ether', async () => {
    const contractBalance = await web3.eth.getBalance(instance.address).toNumber();
    const contractBalanceInETH = web3.fromWei(contractBalance, 'ether');

    const contractBalanceExpected = 10;

    assert.equal(contractBalanceInETH, contractBalanceExpected, 'Contract should have 10 ETH.');
  });

  it('Spin the slot machine must be return (string, string, string) in event LogSpinReturn', async () => {
    const result = await instance.spin({from: other, value: web3.toWei('0.01', 'ether')});
    // console.log(result.logs.filter(log => {
    //   return log.event == 'LogTransferReward';
    // }).forEach(log => {
    //   console.log({
    //     ...log.args,
    //     multiplier: log.args.multiplier.toString(),
    //     rewardAmount: web3.fromWei(log.args.rewardAmount.toString(), 'ether')
    //   });
    // }));
    const logs = result.logs.filter(log => {
        return log.event == 'LogSpinReturn';
    });
    
    // logs.forEach(log => {
    //   console.log(log.args);
    // });    

    const symbolsReturn = logs[0].args;
    
    assert.isObject(symbolsReturn);
    assert.isDefined(symbolsReturn.firstSymbol);
    assert.isDefined(symbolsReturn.secondSymbol);
    assert.isDefined(symbolsReturn.thirdSymbol);
  });

  it('Other people cannot withdraw fund from the contract', async () => {
    const contractBalance = await web3.eth.getBalance(instance.address).toNumber();
    const contractBalanceInETH = web3.fromWei(contractBalance, 'ether');

    try {
      await instance.withdraw(contractBalanceInETH, {from: other});
    } catch (error) {
      assert(error);
      return;
    }

    assert(false);

  });

  it('Owner can withdraw from the contract', async () => {
    const ownerBalance = await web3.eth.getBalance(owner).toNumber();
    const ownerBalanceInETH = web3.fromWei(ownerBalance, 'ether');

    const contractBalance = await web3.eth.getBalance(instance.address).toNumber();
    const contractBalanceInETH = web3.fromWei(contractBalance, 'ether');

    await instance.withdraw(contractBalance, {from: owner});

    assert.isBelow(web3.fromWei(await web3.eth.getBalance(instance.address).toNumber(), 'ether'), contractBalanceInETH, 'Contract\'s balance after withdraw should be lower than before withdraw.'); 
    assert.isAbove(web3.fromWei(await web3.eth.getBalance(owner).toNumber(), 'ether'), ownerBalanceInETH, 'Owner\'s balance must be greater than before withdraw.') 
  });
});
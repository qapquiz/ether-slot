const SlotMachineSpinner = artifacts.require("./SlotMachineSpinner.sol");
const { randomBytes } = require('crypto');

function signWithRandomMessage(webAccount) {
  const messageBuffer = randomBytes(32);
  const messageHex = messageBuffer.toString('hex');
  const signatureObject = webAccount.sign(messageHex);

  return signatureObject;
}

contract('SlotMachineSpinner', async (accounts) => {
  const owner = accounts[0];
  const other = accounts[1];

  const privateKey = '0x7367bf5155d05ee25209ec42f26a04cce5f6d598f4ec1c48d59529774922b512';
  let contractInstance;
  let web3;
  let webAccount;

  before('setup contract for each test', async () => {
    contractInstance = await SlotMachineSpinner.new();
    const Web3 = require('web3');
    web3 = new Web3(Web3.givenProvider || 'http://localhost:8545');

	  webAccount = web3.eth.accounts.privateKeyToAccount(privateKey);
    await web3.eth.sendTransaction({
      from: owner, 
      to: contractInstance.address, 
      value: web3.utils.toWei('10', 'ether'),

    });
  });

  it('Owner is contract creator', async () => {
    const contractOwner = await contractInstance.owner();
    assert.equal(contractOwner, owner);
  });

  it('Contract should have some Ether', async () => {
    const contractBalance = await web3.eth.getBalance(contractInstance.address);
    const contractBalanceInETH = web3.utils.fromWei(contractBalance, 'ether');

    const contractBalanceExpected = 10;

    assert.equal(contractBalanceInETH, contractBalanceExpected, 'Contract should have 10 ETH.');
  });

  it('Spin the slot machine must be return (string, string, string) in event LogSpinReturn', async () => {
    const signatureObject = signWithRandomMessage(webAccount);
    
    const result = await contractInstance.spin(
      signatureObject.messageHash,
      signatureObject.v,
      signatureObject.r,
      signatureObject.s,
      {
        from: other, 
        value: web3.utils.toWei('0.01', 'ether')
      }
    );
    
    const logs = result.logs.filter(log => {
        return log.event == 'LogSpinOccured';
    });
    
    const symbolsReturn = logs[0].args;
    
    assert.isObject(symbolsReturn);
    assert.isDefined(symbolsReturn.firstSymbol);
    assert.isDefined(symbolsReturn.secondSymbol);
    assert.isDefined(symbolsReturn.thirdSymbol);
  });

  it('Filter event with address must only come with that address', async () => {
    let eventCount = 0;
    const logSpinReturnEvent = contractInstance.LogSpinOccured({spinner: owner}, function(error, result) {
      if (!error) {
        eventCount++;
      }
    }); 

    let signatureObject = signWithRandomMessage(webAccount);
    await contractInstance.spin(
      signatureObject.messageHash,
      signatureObject.v,
      signatureObject.r,
      signatureObject.s,
      {from: owner, value: web3.utils.toWei('0.01', 'ether')}
    );

    await contractInstance.spin(
      signatureObject.messageHash,
      signatureObject.v,
      signatureObject.r,
      signatureObject.s,
      {from: owner, value: web3.utils.toWei('0.01', 'ether')}
    );
    
    await contractInstance.spin(
      signatureObject.messageHash,
      signatureObject.v,
      signatureObject.r,
      signatureObject.s,
      {from: owner, value: web3.utils.toWei('0.01', 'ether')}
    );
    
    logSpinReturnEvent.stopWatching();
    assert.equal(eventCount, 2, "eventCount after filter must be 2");
  });

  // it('Get Netowrk from web3', async () => {
  //   assert.equal(await web3.eth.net.getId(), 5777, 'Ganache network id must be 5777');
  // });

  it('Other people cannot withdraw fund from the contract', async () => {
    const contractBalance = await web3.eth.getBalance(contractInstance.address);
    const contractBalanceInETH = web3.utils.fromWei(contractBalance, 'ether');

    try {
      await contractInstance.withdraw(contractBalanceInETH, {from: other});
    } catch (error) {
      assert(error);
      return;
    }

    assert(false);
  });

  it('Owner can withdraw from the contract', async () => {
    const ownerBalance = await web3.eth.getBalance(owner);
    const ownerBalanceInETH = web3.utils.fromWei(ownerBalance, 'ether');

    const contractBalance = await web3.eth.getBalance(contractInstance.address);
    const contractBalanceInETH = web3.utils.fromWei(contractBalance, 'ether');

    await contractInstance.withdraw(contractBalance, {from: owner});

    assert.isBelow(web3.utils.fromWei(await web3.eth.getBalance(contractInstance.address), 'ether'), contractBalanceInETH, 'Contract\'s balance after withdraw should be lower than before withdraw.'); 
    assert.isAbove(web3.utils.fromWei(await web3.eth.getBalance(owner), 'ether'), ownerBalanceInETH, 'Owner\'s balance must be greater than before withdraw.') 
  });
});
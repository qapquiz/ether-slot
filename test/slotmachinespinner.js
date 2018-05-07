const SlotMachineSpinner = artifacts.require("./SlotMachineSpinner.sol");

contract('SlotMachineSpinner', async (accounts) => {
  const owner = accounts[0];

  let instance;

  beforeEach('setup contract for each test', async () => {
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
});
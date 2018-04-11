var SimpleStorage = artifacts.require("./SimpleStorage.sol");
const SlotMachineSpinner = artifacts.require("./SlotMachineSpinner.sol");

module.exports = function(deployer) {
  deployer.deploy(SimpleStorage);
  deployer.deploy(SlotMachineSpinner);
};

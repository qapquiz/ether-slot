const SlotMachineSpinner = artifacts.require("./SlotMachineSpinner.sol");

module.exports = function(deployer) {
  deployer.deploy(SlotMachineSpinner);
};

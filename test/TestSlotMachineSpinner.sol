pragma solidity ^0.4.21;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SlotMachineSpinner.sol";

contract TestSlotMachineSpinner {

    SlotMachineSpinner public slotMachineSpinner;
    uint public initialBalance = 1 ether;

    function beforeEach() public {
        slotMachineSpinner = SlotMachineSpinner(DeployedAddresses.SlotMachineSpinner());
    }

    function testSpin() public {
        slotMachineSpinner.spin.value(0.05 ether);

        uint expectedBalance = 0.95 ether;

        Assert.equal(expectedBalance, address(this).balance, "Contracl balance should be 0.95 ether");
    }
}
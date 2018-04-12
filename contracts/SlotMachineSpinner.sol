pragma solidity ^0.4.21;

import "./SlotMachine.sol";

contract SlotMachineSpinner is SlotMachine {
    event SpinOccured(address indexed spinner, bool result);
    event TransferReward(address indexed spinner, uint256 rewardAmount);

    uint private randomNonce = 0;
    uint public minimumWager = 0.001 ether;

    // constructor
    function SlotMachineSpinner() public {

    }

    function randomWithMod(uint _modulus) private returns (uint256) {
        randomNonce++;
        return uint256(keccak256(block.difficulty, block.coinbase, msg.sender, randomNonce)) % _modulus;
    }

    function findMultiplier(uint randomNumber) private pure returns (uint) {
        uint multiplier = 0;
        
        if (randomNumber <= 3) {
            multiplier = 2;
            return multiplier;
        }

        if (randomNumber <= 5) {
            multiplier = 4;
            return multiplier;
        }

        return multiplier;    
    }

    function spin() payable public {
        require(msg.value >= minimumWager); 
        uint wager = msg.value;
        uint modulus = 10;
        uint multiplier = findMultiplier(randomWithMod(modulus));
        uint rewardAmount = wager * multiplier;
        bool result = rewardAmount == 0;

        if (result) {
            msg.sender.transfer(rewardAmount);
            emit TransferReward(msg.sender, rewardAmount);    
        }

        emit SpinOccured(msg.sender, result);
    }

}
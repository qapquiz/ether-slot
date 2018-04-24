pragma solidity ^0.4.23;


import "./SlotMachine.sol";


contract SlotMachineSpinner is SlotMachine {
    event SpinOccured(address indexed spinner, uint256 wager, bool result);
    event TransferReward(address indexed spinner, uint256 rewardAmount);

    uint private randomNonce = 0;
    uint public minimumWager = 0.001 ether;
    uint public maximumMultiplier = 8;

    function randomWithWagerAndMod(uint wager, uint _modulus) private returns (uint256) {
        randomNonce++;
        return uint256(keccak256(block.difficulty, block.coinbase, msg.sender, wager, randomNonce)) % _modulus;
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
        require(address(this).balance >= msg.value * maximumMultiplier);
        uint wager = msg.value;
        uint modulus = 10;
        uint multiplier = findMultiplier(randomWithWagerAndMod(wager, modulus));
        uint rewardAmount = wager * multiplier;
        bool result = rewardAmount != 0;

        if (result) {
            msg.sender.transfer(rewardAmount);
            emit TransferReward(msg.sender, rewardAmount);    
        }

        emit SpinOccured(msg.sender, wager, result);
    }

    function() payable public {

    }
}
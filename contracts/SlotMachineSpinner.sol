pragma solidity 0.4.23;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./SlotMachine.sol";


contract SlotMachineSpinner is SlotMachine {
    using SafeMath for uint256;

    event LogSpinOccured(address indexed spinner, uint256 wager, bool result);
    event LogTransferReward(address indexed spinner, uint256 rewardAmount);

    uint256 private randomNonce = 0;
    uint256 private minimumWager = 0.001 ether;
    uint256 private maximumMultiplier = 8;

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
        // Conditions
        require(msg.value >= minimumWager, "Your wager must be more than 0.001 ether."); 
        require(
            address(this).balance >= msg.value.mul(maximumMultiplier), 
            "Sorry, right now the contract doesn't have enough balance to pay you back."
        );


        // Interaction
        uint wager = msg.value;
        uint modulus = 10;
        uint multiplier = findMultiplier(randomWithWagerAndMod(wager, modulus));
        uint rewardAmount = wager.mul(multiplier);
        bool result = rewardAmount != 0;

        if (result) {
            msg.sender.transfer(rewardAmount);
            emit LogTransferReward(msg.sender, rewardAmount);    
        }

        emit LogSpinOccured(msg.sender, wager, result);
    }

    function() payable public {

    }
}
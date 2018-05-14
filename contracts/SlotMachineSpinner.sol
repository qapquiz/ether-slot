pragma solidity 0.4.23;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./SlotMachine.sol";


contract SlotMachineSpinner is SlotMachine {
    using SafeMath for uint256;

    event LogSpinOccured(address indexed spinner, uint256 wager, bool result);
    event LogTransferReward(address indexed spinner, uint8 multiplier, uint256 rewardAmount);
    event LogSpinReturn(string firstSymbol, string secondSymbol, string thirdSymbol);

    uint256 private randomNonce = 0;
    uint256 private minimumWager = 0.001 ether;
    uint256 private maximumMultiplier = 8;

    function randomWithWagerAndMod(uint wager, uint _modulus) private returns (uint256) {
        randomNonce++;
        return uint256(keccak256(block.difficulty, block.coinbase, block.number, msg.sender, wager, randomNonce)) % _modulus;
    }

    function findMultiplier(string symbol) private pure returns (uint8) {
        uint8 multiplier = 0;

        if (compareString(symbol, "bar")) {
            multiplier = 60;
        }

        if (compareString(symbol, "seven")) {
            multiplier = 40;
        }

        if (compareString(symbol, "cherry")) {
            multiplier = 20;
        }

        if (compareString(symbol, "orange")) {
            multiplier = 5;
        }

        if (compareString(symbol, "grape")) {
            multiplier = 5;
        }

        if (compareString(symbol, "bell")) {
            multiplier = 5;
        }

        return multiplier;
        
    }

    function findCherryMultiplier(uint8 cherryCount) private pure returns (uint8) {
        uint8 multiplier;
        
        if (cherryCount == 1) {
            multiplier = 1;    
        }

        if (cherryCount == 2) {
            multiplier = 3;
        }

        return multiplier;
    }

    function findSymbolInSlot(uint wager, uint[6] probabilities) private returns (string slotFace) {
        uint256 modulus = 10001;
        uint256 randomNumber = randomWithWagerAndMod(wager, modulus);

        if (randomNumber <= probabilities[0]) {
            return "bar";
        }

        if (randomNumber <= probabilities[1]) {
            return "seven";
        }

        if (randomNumber <= probabilities[2]) {
            return "cherry";
        }

        if (randomNumber <= probabilities[3]) {
            return "orange";
        }

        if (randomNumber <= probabilities[4]) {
            return "grape";
        }

        if (randomNumber <= probabilities[5]) {
            return "bell";
        }
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

        uint[6] memory firstSlotProbabilities = [uint(435), 1739, 3478, 5652, 7826, 10000];
        uint[6] memory secondSlotProbabilities = [uint(435), 870, 2173, 4783, 7392, 10000];
        uint[6] memory thirdSlotProbabilities = [uint(435), 870, 2173, 4783, 7392, 10000];

        string memory symbolInFirstSlot = findSymbolInSlot(wager, firstSlotProbabilities);
        string memory symbolInSecondSlot = findSymbolInSlot(wager, secondSlotProbabilities);
        string memory symbolInThirdSlot = findSymbolInSlot(wager, thirdSlotProbabilities);

        bool isWin = false;

        if (compareString(symbolInFirstSlot, symbolInSecondSlot) && compareString(symbolInFirstSlot, symbolInThirdSlot)) {
            // WIN
            isWin = true;
            sendReward(wager, symbolInFirstSlot);
        }


        uint8 cherryCount = countCherry(symbolInFirstSlot, symbolInSecondSlot, symbolInThirdSlot);

        if (cherryCount == 1 && !isWin) {
            // WIN with 1 cherry           
            isWin = true;  
            sendCherryReward(wager, cherryCount);
        }

        if (cherryCount == 2 && !isWin) {
            // WIN with 2 cherries
            isWin = true;
            sendCherryReward(wager, cherryCount);
        }
        
        // LOSE
        if (!isWin) {
            emit LogSpinOccured(msg.sender, wager, false);
        }

        emit LogSpinReturn(symbolInFirstSlot, symbolInSecondSlot, symbolInThirdSlot);
    }

    function sendReward(uint wager, string symbol) private {
        uint8 multiplier = findMultiplier(symbol);
        uint256 rewardAmount = wager.mul(multiplier);
        bool result = true;

        assert(address(this).balance >= rewardAmount);

        msg.sender.transfer(rewardAmount);
        emit LogTransferReward(msg.sender, multiplier, rewardAmount);
        emit LogSpinOccured(msg.sender, wager, result);
    }

    function sendCherryReward(uint wager, uint8 cherryCount) private {
        uint8 multiplier = findCherryMultiplier(cherryCount);
        uint256 rewardAmount = wager.mul(multiplier);
        bool result = true;

        assert(address(this).balance >= rewardAmount);

        msg.sender.transfer(rewardAmount);
        emit LogTransferReward(msg.sender, multiplier, rewardAmount);
        emit LogSpinOccured(msg.sender, wager, result);
    }

    function countCherry(string symbolInFirstSlot, string symbolInSecondSlot, string symbolInThirdSlot) pure private returns (uint8) {
        uint8 cherryCount = 0;

        if (compareString(symbolInFirstSlot, "cherry")) {
            cherryCount++;
        }

        if (compareString(symbolInSecondSlot, "cherry")) {
            cherryCount++;
        }

        if (compareString(symbolInThirdSlot, "cherry")) {
            cherryCount++;
        }

        return cherryCount;
    }

    function compareString(string first, string second) pure private returns (bool isDifference) {
        return keccak256(first) == keccak256(second);
    }

    function() payable public {

    }
}
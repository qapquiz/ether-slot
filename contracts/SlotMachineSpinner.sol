pragma solidity 0.4.24;

// Conditions => Effects => Interaction
// constructor
// fallback
// external
// public
// internal
// private

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./SlotMachine.sol";

contract SlotMachineSpinner is SlotMachine {
    using SafeMath for uint256;

    address private webAddress = 0x7812Ef241478294B354e4D8Ff0ddDA02C74639cD;
    uint private minimumWager = 0.001 ether;
    uint private maximumWager = 0.1 ether;
    uint[6] private firstSlotProbabilities = [uint(435), 1739, 3478, 5652, 7826, 10000];
    uint[6] private secondSlotProbabilities = [uint(435), 870, 2173, 4783, 7392, 10000];
    uint[6] private thirdSlotProbabilities = [uint(435), 870, 2173, 4783, 7392, 10000];

    event LogSpinOccured(address indexed spinner, uint256 wager, bool result, string firstSymbol, string secondSymbol, string thirdSymbol);
    event LogTransferReward(address indexed spinner, uint8 multiplier, uint256 rewardAmount);

    modifier mustSignWithECDSA(bytes32 hash, uint8 _v, bytes32 _r, bytes32 _s) {
        require(ecrecover(hash, _v, _r, _s) == webAddress, "public key & private key mismatch");
        _;
    }

    // Fallback function
    function () external payable {
        
    }

    // External function
    function spin(bytes32 hash, uint8 _v, bytes32 _r, bytes32 _s)
        external
        payable
        mustSignWithECDSA(hash, _v, _r, _s)
    {
        // Conditions
        require(msg.value >= minimumWager, "wager must be greater than or equal minimumWager.");
        require(msg.value <= maximumWager, "wager must be lower than or equal maximumWager.");

        // Interaction
        uint firstRandomNumber;
        uint secondRandomNumber;
        uint thirdRandomNumber;
        (firstRandomNumber, secondRandomNumber, thirdRandomNumber) = _generateRandomNumber(_s);

        string memory firstSymbol = _findSymbolInSlot(firstRandomNumber, firstSlotProbabilities);
        string memory secondSymbol = _findSymbolInSlot(secondRandomNumber, secondSlotProbabilities);
        string memory thirdSymbol = _findSymbolInSlot(thirdRandomNumber, thirdSlotProbabilities);
        
        bool isWin = false;

        if (_isWin(firstSymbol, secondSymbol, thirdSymbol)) {
            // Normal win
            isWin = true;
            _sendReward(msg.value, firstSymbol);
        } 

        uint8 cherryCount = _countCherry(firstSymbol, secondSymbol, thirdSymbol);

        if (cherryCount > 0 && !isWin) {
            // Cherry win
            isWin = true;
            _sendCherryReward(msg.value, cherryCount);
        }

        emit LogSpinOccured(msg.sender, msg.value, isWin, firstSymbol, secondSymbol, thirdSymbol);
    }

    function getContractBalance() external view returns (uint) {
        return address(this).balance;
    }

    // Private function
    function _sendReward(uint256 wager, string symbol) private {
        uint8 multiplier = _findMultiplier(symbol);
        uint256 rewardAmount = wager.mul(multiplier);

        assert(address(this).balance >= rewardAmount);

        msg.sender.transfer(rewardAmount);
        emit LogTransferReward(msg.sender, multiplier, rewardAmount);
    }

    function _sendCherryReward(uint256 wager, uint8 cherryCount) private {
        uint8 multiplier = _findCherryMultiplier(cherryCount);
        uint256 rewardAmount = wager.mul(multiplier);

        assert(address(this).balance >= rewardAmount);

        msg.sender.transfer(rewardAmount);
        emit LogTransferReward(msg.sender, multiplier, rewardAmount);
    }

    function _generateRandomNumber(bytes32 signature) private pure returns (uint, uint, uint) {
        uint modulus = 10001;
        uint firstRandomNumber = uint(signature) % modulus;
        uint secondRandomNumber = (uint(signature) / 10000) % modulus;
        uint thirdRandomNumber = (uint(signature) / 1000000) % modulus;

        return (firstRandomNumber, secondRandomNumber, thirdRandomNumber);
    }

    function _findSymbolInSlot(uint randomNumber, uint[6] probabilities) private pure returns (string) {
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
    
    function _findMultiplier(string symbol) private pure returns (uint8) {
        if (_compareString(symbol, "bar")) {
            return 60;
        }

        if (_compareString(symbol, "seven")) {
            return 40;
        }

        if (_compareString(symbol, "cherry")) {
            return 20;
        }

        if (_compareString(symbol, "orange")) {
            return 5;
        }

        if (_compareString(symbol, "grape")) {
            return 5;
        }

        if (_compareString(symbol, "bell")) {
            return 5;
        }
    }

    function _findCherryMultiplier(uint8 cherryCount) private pure returns (uint8) {
        if (cherryCount == 1) {
            return 1;    
        }

        if (cherryCount == 2) {
            return 3;
        }
    }

    function _compareString(string first, string second) private pure returns (bool) {
        return keccak256(abi.encodePacked(first)) == keccak256(abi.encodePacked(second));
    }

    function _isCherry(string symbol) private pure returns (bool) {
        return _compareString(symbol, "cherry");
    }

    function _isWin(string firstSymbol, string secondSymbol, string thirdSymbol) private pure returns (bool) {
        return (_compareString(firstSymbol, secondSymbol) && _compareString(firstSymbol, thirdSymbol));
    }

    function _countCherry(string firstSymbol, string secondSymbol, string thirdSymbol) private pure returns (uint8) {
        uint8 cherryCount = 0;
        
        if (_isCherry(firstSymbol)) {
            cherryCount++;
        }

        if (_isCherry(secondSymbol)) {
            cherryCount++;
        }

        if (_isCherry(thirdSymbol)) {
            cherryCount++;
        }
        
        return cherryCount;
    }
}

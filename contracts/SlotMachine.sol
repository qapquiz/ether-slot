pragma solidity 0.4.24;


import "openzeppelin-solidity/contracts/ownership/Ownable.sol";


contract SlotMachine is Ownable {
    function withdraw(uint amount) external onlyOwner {
        require(amount != 0, "Withdraw amount can't be zero.");
        require(address(this).balance >= amount, "Withdraw amount can't be more than contract balance.");

        msg.sender.transfer(amount);
    }
}

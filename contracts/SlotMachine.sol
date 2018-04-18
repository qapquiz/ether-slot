pragma solidity ^0.4.22;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";

contract SlotMachine is Ownable {

    event Transfer(address owner, uint256 amount, uint256 contractBalance);        

    // constructor
    function SlotMachine() public {
        
    }

    function withdraw(uint amount) public onlyOwner {
        require(owner != 0);
        require(amount > 0);
        require(address(this).balance > 0);
        owner.transfer(amount);
        emit Transfer(owner, amount, address(this).balance);
    }
}
pragma solidity ^0.4.23;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";

contract SlotMachine is Ownable {

    event Transfer(address owner, uint256 amount, uint256 contractBalance);        

    constructor() public {
        
    }

    function withdraw(uint amount) public onlyOwner {
        require(amount > 0);
        require(address(this).balance >= amount);
        owner.transfer(amount);
        emit Transfer(owner, amount, address(this).balance);
    }
}
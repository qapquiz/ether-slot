pragma solidity ^0.4.23;


import "zeppelin-solidity/contracts/ownership/Ownable.sol";


contract SlotMachine is Ownable {
    function withdraw(uint amount) public onlyOwner {
        require(amount != 0);
        require(address(this).balance >= amount);

        owner.transfer(amount);
    }
}

pragma solidity 0.4.24;

contract ModulusExponential {

    // bigModExp now resides at address 0x05, and performs b^e mod m, taking as input, in order:
    // - length of the base;
    // - length of the exponent;
    // - length of the modulus;
    // - the base itself (b above);
    // - the exponent itself (e);
    // - the modulus (m).

    function modulusExponential(uint256 base, uint256 exponent, uint256 modulus) public view returns (uint256 result) {
        assembly {
            let free_memory_pointer := mload(0x40)
            let precompiled_moduls_exponential_pointer := 0x05

            mstore(free_memory_pointer, 0x20) // Length of Base
            mstore(add(free_memory_pointer, 0x20), 0x20) // Length of Exponent
            mstore(add(free_memory_pointer, 0x40), 0x20) // Length of Modulus

            mstore(add(free_memory_pointer, 0x60), base) // Base
            mstore(add(free_memory_pointer, 0x80), exponent) // Exponent
            mstore(add(free_memory_pointer, 0xa0), modulus) // Modulus

            // Call Modulus Exponential precompiled contract
            // call(gasLimit, to, value, inputOffset, inputSize, outputOffset, outputSize)
            let success := call(not(0), precompiled_moduls_exponential_pointer, 0, free_memory_pointer, 0xc0, free_memory_pointer, 0x20)

            switch success
            case 0 {
                revert(0, 0)
            }
            
            result := mload(free_memory_pointer)
        }
    }
}

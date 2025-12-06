// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.20;

import "fhevm/lib/TFHE.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Zama FHEVM Demo - Encrypted Value Storage
/// @notice Allows users to store an encrypted value that only they can view.
contract EncryptedStorage is Ownable {
    // A mapping from user address to their encrypted balance/value
    mapping(address => euint64) internal encryptedValues;

    event ValueStored(address indexed user, bytes timestamp);

    constructor() Ownable(msg.sender) {}

    /// @notice Mint/Set an encrypted value for the caller
    /// @param encryptedAmount The encrypted 64-bit integer
    function storeValue(einput encryptedAmount, bytes calldata inputProof) public {
        // Verify the input is valid
        euint64 value = TFHE.asEuint64(encryptedAmount, inputProof);
        
        // Store it in the mapping
        encryptedValues[msg.sender] = value;
        
        // Emit event (data is hidden, but we know action happened)
        emit ValueStored(msg.sender, abi.encodePacked(block.timestamp));
    }

    /// @notice Add to your existing encrypted value (Homomorphic Addition)
    /// @param encryptedAmount The encrypted amount to add
    function addValue(einput encryptedAmount, bytes calldata inputProof) public {
        euint64 addAmount = TFHE.asEuint64(encryptedAmount, inputProof);
        
        // Homomorphic addition: No decryption required!
        encryptedValues[msg.sender] = TFHE.add(encryptedValues[msg.sender], addAmount);
    }

    /// @notice View your own encrypted value (Requires Reencryption)
    /// @param publicKey The user's public key for re-encryption
    /// @param signature The user's signature to prove ownership
    /// @return The re-encrypted value viewable only by the user
    function viewValue(bytes32 publicKey, bytes calldata signature) 
        public 
        view 
        onlySender(signature) 
        returns (bytes memory) 
    {
        return TFHE.reencrypt(encryptedValues[msg.sender], publicKey, 0);
    }

    /// @notice Validates the signature to ensure only the user accesses their data
    modifier onlySender(bytes calldata signature) {
        // In a real implementation, we validate the signature against the view key
        // This is a simplified modifier logic for the demo structure
        _;
    }
}
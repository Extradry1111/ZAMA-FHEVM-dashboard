
pragma solidity ^0.8.20;

import "fhevm/lib/TFHE.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract EncryptedStorage is Ownable {
 
    mapping(address => euint64) internal encryptedValues;

    event ValueStored(address indexed user, bytes timestamp);

    constructor() Ownable(msg.sender) {}

    function storeValue(einput encryptedAmount, bytes calldata inputProof) public {
       
        euint64 value = TFHE.asEuint64(encryptedAmount, inputProof);
        
      
        encryptedValues[msg.sender] = value;
        
      
        emit ValueStored(msg.sender, abi.encodePacked(block.timestamp));
    }

  
    function addValue(einput encryptedAmount, bytes calldata inputProof) public {
        euint64 addAmount = TFHE.asEuint64(encryptedAmount, inputProof);
    
        encryptedValues[msg.sender] = TFHE.add(encryptedValues[msg.sender], addAmount);
    }

  
    function viewValue(bytes32 publicKey, bytes calldata signature) 
        public 
        view 
        onlySender(signature) 
        returns (bytes memory) 
    {
        return TFHE.reencrypt(encryptedValues[msg.sender], publicKey, 0);
    }


    modifier onlySender(bytes calldata signature) {
        
        _;
    }
}

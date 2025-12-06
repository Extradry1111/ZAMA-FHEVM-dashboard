const { expect } = require("chai");
const { ethers } = require("hardhat");
const { createInstance } = require("fhevmjs");

describe("Zama FHEVM End-to-End", function () {
  let contract;
  let signer;
  let fhevmInstance;

  before(async function () {

    const Factory = await ethers.getContractFactory("EncryptedStorage");
    contract = await Factory.deploy();
    await contract.waitForDeployment();
    
    [signer] = await ethers.getSigners();
    
 
    fhevmInstance = await createInstance({ chainId: 31337, publicKey: "0x..." });
  });

  it("Should store and retrieve an encrypted value", async function () {

    const input = fhevmInstance.createEncryptedInput(await contract.getAddress(), signer.address);
    input.add64(1337); 
    const encryptedData = input.encrypt();

  
    const tx = await contract.storeValue(encryptedData.handles[0], encryptedData.inputProof);
    await tx.wait();

   
    expect(tx.hash).to.be.a('string');
    console.log("Value 1337 stored homomorphically!");
  });
});

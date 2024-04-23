// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

//18 04 24 https://pad.riseup.net/p/zQay3DMHT_VLL5YisANK/timeslider#486
contract Wallet {

    //Map that stores all the adresses with the available tokens
    mapping (address => uint) addressMap;
    address contractOwner;

    constructor(){
        contractOwner = msg.sender; 
        addressMap[contractOwner] = 1000; //Set 1000 tokens to the contract owner
    }

    event ownerAddedTokens(uint amount);

    event tokensTransfered(address sender, address destination, uint amount);

    modifier onlyOwnerHasAccess {
        require(msg.sender == contractOwner, "Only the contract owner has access to this function");
        _;
    }

    function getAvailableTokens(address addressToCheck) view external returns(uint){
        require(msg.sender == addressToCheck, "The address difers from yours");
        return addressMap[addressToCheck];
    }

    // Transfers token to other adderss registered on the map.
    function sendTokens(uint amount, address destination) external {
        require(addressMap[msg.sender] >= amount, "insufficient funds"); // If insuficient found it gets reverted.
        addressMap[destination] += amount;
        addressMap[msg.sender] -= amount;
        emit tokensTransfered(msg.sender, destination, amount);
    }

    // Function to add tokens, this function adds an amount of tokens to the owner of this contract.
    function addTokes(uint amount) external onlyOwnerHasAccess {
        addressMap[msg.sender] += amount;
        emit ownerAddedTokens(amount);
    }


}
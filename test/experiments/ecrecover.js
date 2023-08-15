
  const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
  const { expect } = require("chai");
const { keccak256, ripemd160, verifyMessage } = require("ethers");
const { ethers } = require("hardhat");



describe("ECDSA signing ", function(){
    describe("signing messages", function(){
        let deployer, player;
        let ecrecoverContract;

        before(async function(){
            [deployer, player] = await ethers.getSigners();
            
        });

        it("Should deploy", async function(){
            const contractFactory = await ethers.getContractFactory('testECRECOVER', deployer);
            ecrecoverContract = await contractFactory.deploy();
            // console.log("ecrecoverContract address is ");
            console.log(ecrecoverContract.address);

        });

        it("should work with API", async function(){
            // ecrecoverContract.getAddress();
            message = "43"
            let utf8Encode = new TextEncoder();
            message = utf8Encode.encode("43");
            console.log("HASH IS ", ethers.utils.keccak256((message)) );
            sig = await player.signMessage(message);
            console.log("player address is ", player.address);
            console.log("recovered address is ",ethers.utils.verifyMessage(message, sig));
            
        });

        it("should check sign the message per contract", async function(){
            message = "43"
            let utf8Encode = new TextEncoder();
            message = utf8Encode.encode("43");
            // console.log("HASH IS ", ethers.utils.keccak256((message)) );

            signedMessage = await player.signMessage(message);
            // console.log("SIGNATURE IS ", signedMessage);

            sig = await ethers.utils.splitSignature(signedMessage)
            // console.log("Sig is ",sig);
            console.log("player address is : ", player.address);
            await ecrecoverContract.testMessage(sig.v, sig.r, sig.s);
            
        });

        it("should sign basic structs", async function(){
            const domain = {
                name: 'My App',
                version: '1',
                chainId: 1,
                verifyingContract: '0x1111111111111111111111111111111111111111'
              };
              const types = {
                Mail: [
                  { name: 'from', type: 'Person' },
                  { name: 'to', type: 'Person' },
                  { name: 'content', type: 'string' }
                ],
                Person: [
                  { name: 'name', type: 'string' },
                  { name: 'wallet', type: 'address' }
                ]
              };
              const mail = {
                from: {
                   name: 'Alice',
                   wallet: '0x2111111111111111111111111111111111111111'
                },
                to: {
                   name: 'Bob',
                   wallet: '0x3111111111111111111111111111111111111111'
                },
                content: 'Hello!'
              };

              const signature = await player._signTypedData(domain, types, mail);
              const expectedSignerAddress = player.address;
              const recoveredAddress = ethers.utils.verifyTypedData(domain, types, mail, signature);
              console.log("Local signature verification ",recoveredAddress === expectedSignerAddress);
              // true
        });

        it("should be able to sign structures and be compatible with solidity ", async function(){

            const domain = {
                name: 'rando',
                version: '1',
                chainId: 1,
                verifyingContract: '0x1111111111111111111111111111111111111111'
            };

            const types = {
                basicStruct: [
                    { name: 'id', type: 'string' },
                    { name: 'name', type: 'string' },                    
                  ],
            };

            const values = {
                id : "1" ,
                name: "hello"
            };

            Sig = await player._signTypedData(domain, types, values);
            console.log(Sig);
            sig = ethers.utils.splitSignature(Sig)

            result =  ethers.utils.verifyTypedData(domain, types, values, Sig);
            console.log("RESULT US ", result);
            await ecrecoverContract.testStructs(sig.v, sig.r, sig.s);
        });

    });
});
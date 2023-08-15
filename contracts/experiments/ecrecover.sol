// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";
import "solmate/src/tokens/ERC20.sol";


contract testECRECOVER
{
    struct basicStruct
    {
        string id;
        string name;
    }

    struct EIP712Domain
    {
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
    }


    function testStructs(uint8 v, bytes32 r, bytes32 s) public view 
    {

        
        bytes32 domain = keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string,string,uint256,address)"),
                    "rando",// keccak256("rando"),
                    "1",// keccak256("1"),
                    1,
                    0x1111111111111111111111111111111111111111  
                )
            );

        // basicStruct memory obj;
        // obj.id = 1;
        // obj.name = "hello";

        bytes32 hashStruct = keccak256(
            abi.encode(
                keccak256("testStructs(uint256,string)"),
                "1",
                "hello"
            )
        );

        bytes32 hash = keccak256(
            abi.encode(
                0x1901,
                domain,
                hashStruct
            )
        );

        address result = ecrecover(hash, v,r,s);

        console.log("RESULT IS ", result);

        //signing structs message is 
        // \x19\01 . domainseperator . hashStruct
        // hashStrct = hash("testStructs(uint256,string)", 1, "hello")



    }
    
    function testMessage(uint8 v, bytes32 r, bytes32 s) public view
    {  

    //lets start with a number
    string memory a = "43";
    // console.log("number is ",a);

    // console.log("hash is ",uint256(hash));

    bytes32 hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n2",a));
    // console.log("hash with Ethereum prefix is ",uint256(hash));

    address recoveredPubkey = ecrecover(hash, v,r,s);


    console.log("Recovered public key is : ",recoveredPubkey);

    }

}

// contract Verifier {
//     function verifyHash(bytes32 hash, uint8 v, bytes32 r, bytes32 s) public pure
//                  returns (address signer) {

//         bytes32 messageDigest = keccak256("\x19Ethereum Signed Message:\n32", hash);

//         return ecrecover(messageDigest, v, r, s);
//     }
// }
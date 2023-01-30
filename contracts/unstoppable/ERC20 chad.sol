pragma solidity ^0.8.0;


import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract ERC20CHAD is ERC20
{
    constructor() ERC20("ERChad", "ECC")
    {

    }
    function mintMon(address adr, uint256 amount) public
    {
        _mint(adr, amount);
    }
}
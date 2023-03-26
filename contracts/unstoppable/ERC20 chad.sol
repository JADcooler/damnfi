pragma solidity ^0.8.0;


import "solmate/src/tokens/ERC20.sol";
//https://www.diffchecker.com/HhATt7gP/
contract ERC20CHAD is ERC20
{
    constructor() ERC20("ERChad", "ECC",18)
    {

    }
    function mintMon(address adr, uint256 amount) public
    {
        _mint(adr, amount);
    }
}
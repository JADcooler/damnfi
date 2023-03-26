pragma solidity ^0.8.0;

contract testt
{
    address public interact;
    uint public amou;
    function start(address adr, uint amount) public
    {
        interact = adr;
        amou = amount;
        ints(payable(interact)).reen(amou);
    }
    event asd(uint balance);


    fallback() external payable
    {
        emit asd(interact.balance);
       // while(interact.balance > 10)
        //
    }
}

contract ints 
{
    receive() external payable {}

    function reen(uint amount) public payable
    {
        payable(msg.sender).transfer(amount);
        
    }

}
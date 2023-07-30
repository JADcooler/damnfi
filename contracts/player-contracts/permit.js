const { ethers } = require("hardhat");
const { abi } = require("../artifacts/contracts/MyToken.sol/MyToken.json")
require('dotenv').config()

  function getTimestampInSeconds() {
    // returns current timestamp in seconds
    return Math.floor(Date.now() / 1000);
  }
  
  async function main() {
  
    // get a provider instance
    const provider = new ethers.providers.StaticJsonRpcProvider(process.env.RPC_URL)
  
    // get the network chain id
    const chainId = (await provider.getNetwork()).chainId;
  
    // create a signer instance with the token owner
    const tokenOwner = await new ethers.Wallet(process.env.PRIVATE_KEY_DEPLOYER, provider)

    // create a signer instance with the token receiver
    const tokenReceiver = await new ethers.Wallet(process.env.PRIVATE_KEY_ACCOUNT_2, provider)
  
    // get the MyToken contract factory and deploy a new instance of the contract
    const myToken = new ethers.Contract("YOUR_DEPLOYED_CONTRACT_ADDRESS", abi, provider)
  
    // check account balances
    let tokenOwnerBalance = (await myToken.balanceOf(tokenOwner.address)).toString()
    let tokenReceiverBalance = (await myToken.balanceOf(tokenReceiver.address)).toString()

    console.log(`Starting tokenOwner balance: ${tokenOwnerBalance}`);
    console.log(`Starting tokenReceiver balance: ${tokenReceiverBalance}`);
  
    // set token value and deadline
    const value = ethers.utils.parseEther("1");
    const deadline = getTimestampInSeconds() + 4200;
  
    // get the current nonce for the deployer address
    const nonces = await myToken.nonces(tokenOwner.address);
  
    // set the domain parameters
    const domain = {
      name: await myToken.name(),
      version: "1",
      chainId: chainId,
      verifyingContract: myToken.address
    };
  
    // set the Permit type parameters
    const types = {
      Permit: [{
          name: "owner",
          type: "address"
        },
        {
          name: "spender",
          type: "address"
        },
        {
          name: "value",
          type: "uint256"
        },
        {
          name: "nonce",
          type: "uint256"
        },
        {
          name: "deadline",
          type: "uint256"
        },
      ],
    };
  
    // set the Permit type values
    const values = {
      owner: tokenOwner.address,
      spender: tokenReceiver.address,
      value: value,
      nonce: nonces,
      deadline: deadline,
    };
  
    // sign the Permit type data with the deployer's private key
    const signature = await tokenOwner._signTypedData(domain, types, values);
  
    // split the signature into its components
    const sig = ethers.utils.splitSignature(signature);
  
    // verify the Permit type data with the signature
    const recovered = ethers.utils.verifyTypedData(
      domain,
      types,
      values,
      sig
    );
  
    // get network gas price
    gasPrice = await provider.getGasPrice()
  
    // permit the tokenReceiver address to spend tokens on behalf of the tokenOwner
    let tx = await myToken.connect(tokenOwner).permit(
      tokenOwner.address,
      tokenReceiver.address,
      value,
      deadline,
      sig.v,
      sig.r,
      sig.s, {
        gasPrice: gasPrice,
        gasLimit: 80000 //hardcoded gas limit; change if needed
      }
    );
  
    await tx.wait(2) //wait 2 blocks after tx is confirmed
  
    // check that the tokenReceiver address can now spend tokens on behalf of the tokenOwner
    console.log(`Check allowance of tokenReceiver: ${await myToken.allowance(tokenOwner.address, tokenReceiver.address)}`);
  
    // transfer tokens from the tokenOwner to the tokenReceiver address
    tx = await myToken.connect(tokenReceiver).transferFrom(
      tokenOwner.address,
      tokenReceiver.address,
      value, {
        gasPrice: gasPrice,
        gasLimit: 80000 //hardcoded gas limit; change if needed
      }
    );
  
    await tx.wait(2) //wait 2 blocks after tx is confirmed

    // Get ending balances
    tokenOwnerBalance = (await myToken.balanceOf(tokenOwner.address)).toString()
    tokenReceiverBalance = (await myToken.balanceOf(tokenOwner.address)).toString()

    console.log(`Ending tokenOwner balance: ${tokenOwnerBalance}`);
    console.log(`Ending tokenReceiver balance: ${tokenReceiverBalance}`);
  }
  
  
  main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
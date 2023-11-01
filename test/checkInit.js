const { ethers } = require('hardhat');
const { expect } = require('chai');

describe('[CHECKIT] initializer recall', function () {

    let deployer, contr;

    before(async function () {
        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
        [deployer] = await ethers.getSigners();
        let contrF = await ethers.getContractFactory("MyContract")
        contr = await contrF.deploy();

    });

    //start
    it("Should print 1 ,2 ,3 ", async function (){
    
    });
});

const { should, expect } = require("chai");

describe('MultiSender Contract', function () {
    let multiSender;
    let owner;
    let addr1;
    let addr2;
    before(async function () {
        [owner, addr1, addr2] = await ethers.getSigners();
        let MultiSender = await ethers.getContractFactory('MultiSender');
        multiSender = await MultiSender.deploy(owner);
        await multiSender.deployed();
    });
});

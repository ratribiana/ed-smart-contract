const { expect, assert } = require("chai");
const { ethers } = require("hardhat");

describe("EmpowerDefi ERC20 Token", function () {
  it("Should return the token name", async function () {
    const Token = await ethers.getContractFactory("EmpowerDefi");
    const edToken = await Token.deploy();
    await edToken.deployed();

    expect(await edToken.name()).to.equal("EmpowerDefi");
  });

  it("Should display the correct token symbol", async () => {
    const Token = await ethers.getContractFactory("EmpowerDefi");
    const edToken = await Token.deploy();
    await edToken.deployed();

    expect(await edToken.name()).to.equal("EmpowerDefi");
  });

  it("Should be able to read the current token supply", async () => {
    const Token = await ethers.getContractFactory("EmpowerDefi");
    const edToken = await Token.deploy();
    await edToken.deployed();

    // Mint 500 initial token supply
    await edToken.mint(
      "0x282093489Fa2db5e36c1894e808b789D624031BE",
      ethers.utils.parseEther("500")
    );

    const totalSupply = ethers.utils.formatEther(await edToken?.totalSupply());

    // Tests
    assert.equal(totalSupply, 500);
    assert.deepEqual(totalSupply, "500.0");
  });

  it("Should be able to query address' balance", async () => {
    const Token = await ethers.getContractFactory("EmpowerDefi");
    const edToken = await Token.deploy();
    await edToken.deployed();

    // Mint 500 initial token supply
    await edToken.mint(
      "0x282093489Fa2db5e36c1894e808b789D624031BE",
      ethers.utils.parseEther("500")
    );

    // Tests
    assert.equal(
      ethers.utils.formatEther(
        await edToken.balanceOf("0x282093489Fa2db5e36c1894e808b789D624031BE")
      ),
      500
    );
  });

  it("Should be able to support transfers", async () => {
    const Token = await ethers.getContractFactory("EmpowerDefi");
    const edToken = await Token.deploy();
    await edToken.deployed();

    const receiverWallet = "0x1fcb2d8E0420fd4DA92979446AB247bbaA5a958a";

    // Mint 500 initial token supply to the contract owner
    await edToken.mint(
      "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
      ethers.utils.parseEther("500")
    );

    // Transfer token to receiver address
    await edToken.transfer(receiverWallet, ethers.utils.parseEther("100"));

    assert.equal(
      ethers.utils.formatEther(await edToken.balanceOf(receiverWallet)),
      "100.0"
    );
  });

  it("Should be able to support burning", async () => {
    const Token = await ethers.getContractFactory("EmpowerDefi");
    const edToken = await Token.deploy();
    await edToken.deployed();

    // Get contract owner
    const owner = await edToken.owner();

    // Mint 500 initial token supply to the contract owner
    await edToken.mint(owner, ethers.utils.parseEther("500"));

    // Burn some tokens
    await edToken.burn(ethers.utils.parseEther("400"));

    // Tests
    assert.equal(
      ethers.utils.formatEther(await edToken.balanceOf(owner)),
      "100.0"
    );
    assert.equal(
      ethers.utils.formatEther(await edToken.totalSupply()),
      "100.0"
    );
  });
});

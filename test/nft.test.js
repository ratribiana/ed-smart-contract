const { expect, assert } = require("chai");
const { ethers } = require("hardhat");

describe("EmpowerDefiNFT - ERC721", function () {
  it("Should return the edNft name", async function () {
    const NFT = await ethers.getContractFactory("EmpowerDefiNFT");
    const edNft = await NFT.deploy();
    await edNft.deployed();

    // Tests
    expect(await edNft.name()).to.equal("EmpowerDefi NFT");
  });

  it("Has a name", async () => {
    const NFT = await ethers.getContractFactory("EmpowerDefiNFT");
    const edNft = await NFT.deploy();
    await edNft.deployed();

    const name = await edNft.name();

    // Tests
    expect(name).to.equal("EmpowerDefi NFT");
  });

  it("Has a symbol", async () => {
    const NFT = await ethers.getContractFactory("EmpowerDefiNFT");
    const edNft = await NFT.deploy();
    await edNft.deployed();

    const symbol = await edNft.symbol();

    // Tests
    expect(symbol).to.equal("DefiNFT");
  });

  it("Can mint a new NFT", async () => {
    const NFT = await ethers.getContractFactory("EmpowerDefiNFT");
    const edNft = await NFT.deploy();
    await edNft.deployed();
    let owner = await edNft.owner();

    // Mint sample NFT
    await edNft.mint(ethers.utils.parseEther("1"), { from: owner });

    const balance = ethers.utils.formatEther(await edNft.balanceOf(owner));

    // Test
    expect(balance).to.equal(ethers.utils.formatEther("1"));
  });

  it("Can transfer a edNft", async () => {
    const NFT = await ethers.getContractFactory("EmpowerDefiNFT");
    const edNft = await NFT.deploy();
    await edNft.deployed();

    let owner = await edNft.owner();
    let receiver = "0x1fcb2d8e0420fd4da92979446ab247bbaa5a958a";
    let tokenId = ethers.utils.parseEther("2");

    // Mint sample NFT
    await edNft.mint(tokenId, { from: owner });
    // Perform transfer
    await edNft.transferFrom(owner, receiver, tokenId, { from: owner });
    const balance = await edNft.balanceOf(receiver);

    // Tests
    expect(balance.toNumber()).to.equal(1);
  });

  it("Emits the Transfer event on transfer", async () => {
    const NFT = await ethers.getContractFactory("EmpowerDefiNFT");
    const edNft = await NFT.deploy();
    await edNft.deployed();

    let tokenId = ethers.utils.parseEther("2");
    let owner = await edNft.owner();
    let receiver = "0x1fcb2d8e0420fd4da92979446ab247bbaa5a958a";

    await edNft.mint(tokenId, { from: owner });
    const result = await edNft.transferFrom(owner, receiver, tokenId, {
      from: owner,
    });

    // Tests
    assert(result, "Transfer", (ev) => {
      return (
        ev.from === owner &&
        ev.to === receiver &&
        ev.tokenId.toNumber() === tokenId
      );
    });
  });

  it("Cannot transfer an NFT that the owner does not own", async () => {
    const NFT = await ethers.getContractFactory("EmpowerDefiNFT");
    const edNft = await NFT.deploy();
    await edNft.deployed();

    let tokenId = ethers.utils.parseEther("2");
    let owner = await edNft.owner();
    let receiver = "0x1fcb2d8e0420fd4da92979446ab247bbaa5a958a";

    await edNft.mint(tokenId, { from: owner });
    try {
      await edNft.transferFrom(receiver, owner, tokenId, {
        from: receiver,
      });
      assert.fail("Expected throw not received");
    } catch (error) {
      expect(error.message);
    }
  });
});

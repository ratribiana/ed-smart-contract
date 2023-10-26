require("@nomiclabs/hardhat-waffle");

const { ethers } = require("hardhat");
const hre = require("hardhat");

/*** This script will deploy all the contracts */
async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts using the account: " + deployer.address);

  // Deploy NFT
  const NFT = await hre.ethers.getContractFactory("EmpowerDefiNFT");
  const ED_NFT = await NFT.deploy();
  await ED_NFT.deployed();

  console.log("NFT has been deployed to: " + ED_NFT.address);
}

// We recommend thxs pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

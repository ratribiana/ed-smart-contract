require("@nomiclabs/hardhat-waffle");

const { ethers } = require("hardhat");
const hre = require("hardhat");

/*** This script will deploy all the contracts */
async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts using the account: " + deployer.address);

  // Deploy USDC TEST TOKENS
  const TOKEN = await hre.ethers.getContractFactory("EmpowerDefiUSDC");
  const ED_USDC_TOKEN = await TOKEN.deploy();
  await ED_USDC_TOKEN.deployed();

  console.log("TEST USDC has been deployed to: " + ED_USDC_TOKEN.address);
}

// We recommend thxs pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

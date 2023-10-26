require("@nomiclabs/hardhat-waffle");

const { ethers } = require("hardhat");
const hre = require("hardhat");

/*** This script will deploy all the contracts */
async function main() {
  const [deployer] = await ethers.getSigners();

  const nftAddress = "0x7fEA39ec7266b82aC7Ab0c4Af54290472F6108cF";
  const usdcAddress = "0x7Dd3A67603F5C974d4B8d42c0f94a876cF7a5143";
  const empowerDefiTokenAddress = "0x4742525651e8D07100caAE18C910F7077351929f";

  console.log("Deploying contracts using the account: " + deployer.address);

  // Deploy LENDING_PROTOCOL
  const PROTOCOL = await hre.ethers.getContractFactory("EmpowerDefiCapital");
  const LENDING_PROTOCOL = await PROTOCOL.deploy(
    usdcAddress,
    nftAddress,
    empowerDefiTokenAddress
  );
  await LENDING_PROTOCOL.deployed();

  console.log(
    "LENDING_PROTOCOL has been deployed to: " + LENDING_PROTOCOL.address
  );
}

// We recommend thxs pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

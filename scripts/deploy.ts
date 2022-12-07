import { ethers } from "hardhat";

async function main() {
  // Grab the contract factory
  const UpgradableNFT = await ethers.getContractFactory("UpgradableNFT");

  // Start deployment, returning a promise that resolves to a contract object
  const upgradableNFT = await UpgradableNFT.deploy(); // Instance of the contract
  console.log("Contract deployed to address:", upgradableNFT.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

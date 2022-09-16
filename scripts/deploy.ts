import { ethers } from "hardhat";

async function main() {
  // Grab the contract factory
  const XNFT = await ethers.getContractFactory("XNFT");

  // Start deployment, returning a promise that resolves to a contract object
  const xNFT = await XNFT.deploy(); // Instance of the contract
  console.log("Contract deployed to address:", xNFT.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

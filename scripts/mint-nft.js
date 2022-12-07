const dotenv = require("dotenv");
const ethers = require("ethers");

dotenv.config();

// Define an Alchemy Provider
const ALCHEMY_API_KEY = process.env.ALCHEMY_API_KEY;

const provider = new ethers.providers.AlchemyProvider(
  "goerli",
  ALCHEMY_API_KEY
);

// Create signer
const PRIVATE_KEY = process.env.PRIVATE_KEY;

const signer = new ethers.Wallet(PRIVATE_KEY, provider);

// Get contract ABI
const contract = require("../artifacts/contracts/UpgradableNFT.sol/UNFT.json");
const abi = contract.abi;
const contractAddress = process.env.CONTRACT_ADDRESS;

// Create a contract instance
const contractInstance = new ethers.Contract(contractAddress, abi, signer);

// Get the NFT Metadata IPFS URL
const tokenUri =
  "https://gateway.pinata.cloud/ipfs/QmVL1Bst3zh9Gv714QmibH6EBBR5TupoUXsaBJvytp6puW";

// Mint NFT
const mintNFT = async () => {
  let nftTxn = await contractInstance.mintNFT(signer.address, tokenUri);
  await nftTxn.wait();
  console.log(
    `NFT Minted! Check it out at: https://goerli.etherscan.io/tx/${nftTxn.hash}`
  );
};

mintNFT()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

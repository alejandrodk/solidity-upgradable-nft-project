import dotenv from "dotenv";
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-ethers";

dotenv.config();

const { ALCHEMY_API_URL, PRIVATE_KEY, ALCHEMY_NETWORK } = process.env;

const config: HardhatUserConfig = {
  solidity: process.env.SOLIDITY_VERSION || "0.8.4",
  defaultNetwork: ALCHEMY_NETWORK,
  networks: {
    hardhat: {},
    goerli: {
      url: ALCHEMY_API_URL,
      accounts: [`0x${PRIVATE_KEY}`],
    },
  },
};

export default config;

import dotenv from "dotenv";
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

dotenv.config();

const { SOLIDITY_VERSION, ALCHEMY_API_URL, PRIVATE_KEY, ETH_NETWORK } =
  process.env;

const config: HardhatUserConfig = {
  solidity: SOLIDITY_VERSION || "0.8.17",
  defaultNetwork: ETH_NETWORK,
  networks: {
    hardhat: {},
    goerli: {
      url: ALCHEMY_API_URL,
      accounts: [`0x${PRIVATE_KEY}`],
    },
  },
};

export default config;

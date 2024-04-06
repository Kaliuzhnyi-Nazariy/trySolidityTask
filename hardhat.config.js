require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

const { ALCHEMY_TESNET_URL, SECRET_KEY } = process.env;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.20",
  networks: {
    goerli: {
      url: ALCHEMY_TESNET_URL,
      accounts: [SECRET_KEY],
    },
  },
};

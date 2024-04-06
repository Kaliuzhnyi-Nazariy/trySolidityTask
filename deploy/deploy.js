const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  async function askAbout(message) {
    const readline = require("readline").createInterface({
      input: process.stdin,
      output: process.stdout,
    });
    return new Promise((res) => [
      readline.question(message, (input) => {
        readline.close();
        res(input);
      }),
    ]);
  }

  const SolarGreenToken = await ethers.getContractFactory("SolarGreenToken");
  const solarGreenToken = await SolarGreenToken.deploy(deployer.address);

  const initialCost = await askAbout("Enter a value of tokens: ");

  const initialCostInUSDT = await askAbout("Enter a value of tokens in USDT: ");

  const valueOfTokens = ethers.parseEther(initialCost).toString();

  const valueOfTokensInUSDT = ethers.parseEther(initialCostInUSDT).toString();

  const overrides = {
    value: ethers.parseEther(initialCost),
    valueInUSDT: ethers.parseEther(valueOfTokensInUSDT),
  };

  const SolarGreenSell = await ethers.getContractFactory("SolarGreenSell");
  const solarGreenSell = await SolarGreenSell.deploy(
    deployer.address,
    valueOfTokens,
    valueOfTokensInUSDT,
    overrides
  );
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.log(err);
    process.exit(1);
  });

import { ethers } from "hardhat";
import { env } from "process";

async function main() {
  const protocolAddressProvider = env.PROTOCOL_ADDRESS_PROVIDER || "";
  const uniswapV2Router = env.UNI_V2_ROUTER_ADDRESS || "";
  const deployer = (await ethers.getSigners())[0];

  if (!protocolAddressProvider) {
    throw new Error("Protocol address provider is not provided");
  }

  if (!uniswapV2Router) {
    throw new Error("Uniswap V2 router address is not provided");
  }

  console.log(
    `Deploying liquidation bot with the account: ${deployer.address}`
  );
  console.log(`Protocol address provider: ${protocolAddressProvider}`);
  console.log(`Uniswap V2 router: ${uniswapV2Router}`);

  const LiquidateLoan = await ethers.getContractFactory("LiquidateLoan");
  const contract = await LiquidateLoan.deploy(
    protocolAddressProvider,
    uniswapV2Router,
    deployer.address
  );

  await contract.waitForDeployment();

  console.log(`Liquidation bot deployed to ${contract.target}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

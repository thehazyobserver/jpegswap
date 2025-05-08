const { ethers, upgrades } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  const feeToken = "0xC046dCb16592FBb3F9fA0C629b8D93090dD4cB76"; // $JOINT token address
  const stonerNFT = "0x9b567e03d891F537b2B7874aA4A3308Cfe2F4FBb"; // $STONER NFT address

  // Deploy StonerFeePool
  const StonerFeePool = await ethers.getContractFactory("StonerFeePool");
  const stonerPool = await StonerFeePool.deploy(stonerNFT, feeToken);
  await stonerPool.deployed();
  console.log("StonerFeePool:", stonerPool.address);

  // Deploy SwapPool logic
  const SwapPool = await ethers.getContractFactory("SwapPool");
  const swapImpl = await SwapPool.deploy();
  await swapImpl.deployed();
  console.log("SwapPool logic:", swapImpl.address);

  // Deploy Factory
  const SwapPoolFactory = await ethers.getContractFactory("SwapPoolFactory");
  const factory = await SwapPoolFactory.deploy(swapImpl.address, feeToken, stonerPool.address);
  await factory.deployed();
  console.log("SwapPoolFactory:", factory.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

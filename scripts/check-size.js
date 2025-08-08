const hre = require("hardhat");
const fs = require("fs");

async function main() {
  console.log("Compiling contracts...");
  await hre.run("compile");
  
  const contractName = "SwapPoolNative";
  const artifact = await hre.artifacts.readArtifact(contractName);
  
  const bytecodeSize = artifact.bytecode.length / 2 - 1; // Convert hex to bytes (subtract 1 for 0x prefix)
  const deployedBytecodeSize = artifact.deployedBytecode.length / 2 - 1;
  
  console.log(`\n📊 Contract Size Analysis for ${contractName}:`);
  console.log(`├── Bytecode size: ${bytecodeSize.toLocaleString()} bytes`);
  console.log(`├── Deployed bytecode size: ${deployedBytecodeSize.toLocaleString()} bytes`);
  console.log(`├── EIP-170 limit: 24,576 bytes`);
  
  if (bytecodeSize > 24576) {
    console.log(`❌ Contract is ${(bytecodeSize - 24576).toLocaleString()} bytes over the limit!`);
    console.log(`📈 Size reduction needed: ${((bytecodeSize - 24576) / bytecodeSize * 100).toFixed(1)}%`);
  } else {
    console.log(`✅ Contract is under the limit by ${(24576 - bytecodeSize).toLocaleString()} bytes`);
    console.log(`📉 Remaining headroom: ${((24576 - bytecodeSize) / 24576 * 100).toFixed(1)}%`);
  }
  
  console.log(`\n🔧 Compiler Settings:`);
  console.log(`├── Optimizer runs: 1`);
  console.log(`├── Via IR: true`);
  console.log(`└── Solidity version: 0.8.19`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

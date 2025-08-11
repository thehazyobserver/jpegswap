const { ethers } = require("hardhat");

async function main() {
    console.log("Checking compilation of GPT-5 improved contracts...");
    
    try {
        // Try to get contract factories to verify compilation
        await ethers.getContractFactory("SwapPoolNative");
        console.log("✅ SwapPool.sol compiles successfully");
        
        await ethers.getContractFactory("StonerFeePool");
        console.log("✅ stonerfeepool.sol compiles successfully");
        
        console.log("\n🎉 All contracts compile with GPT-5 reward safety improvements!");
        
    } catch (error) {
        console.error("❌ Compilation error:", error.message);
        process.exit(1);
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });

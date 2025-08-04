# 🚀 JPEGSwap Automated Deployment Solution

## 📋 Overview

Complete automation scripts for deploying the JPEGSwap ecosystem across multiple networks with zero configuration hassle.

## ⚡ Quick Deploy Commands

### Single Command Deployment
```bash
# Deploy entire ecosystem to specified network
npm run deploy:full -- --network [mainnet|polygon|arbitrum|sonic]

# Deploy with verification
npm run deploy:verify -- --network mainnet

# Deploy to testnet
npm run deploy:test -- --network goerli
```

## 🏗️ Deployment Architecture

### Contract Deployment Order
1. **StakeReceipt** (Non-upgradeable base contract)
2. **SwapPool Implementation** (UUPS upgradeable logic)
3. **StonerFeePool Implementation** (UUPS upgradeable logic)
4. **SwapPoolFactory** (Factory with proxy deployment)
5. **Configuration & Initialization**

## 📝 Hardhat Deployment Scripts

### 1. Main Deployment Script (`deploy/01_deploy_ecosystem.js`)

```javascript
const { ethers, upgrades } = require("hardhat");

async function main() {
    console.log("🚀 Starting JPEGSwap Ecosystem Deployment...");
    
    // Get deployer account
    const [deployer] = await ethers.getSigners();
    console.log("📝 Deploying with account:", deployer.address);
    console.log("💰 Account balance:", (await deployer.getBalance()).toString());

    // 1. Deploy StakeReceipt Contract
    console.log("\n1️⃣ Deploying StakeReceipt...");
    const StakeReceipt = await ethers.getContractFactory("StakeReceipt");
    const stakeReceipt = await StakeReceipt.deploy(
        "JPEGSwap Stake Receipt",
        "JSR"
    );
    await stakeReceipt.deployed();
    console.log("✅ StakeReceipt deployed to:", stakeReceipt.address);

    // 2. Deploy SwapPool Implementation
    console.log("\n2️⃣ Deploying SwapPool Implementation...");
    const SwapPool = await ethers.getContractFactory("SwapPoolNative");
    const swapPoolImpl = await SwapPool.deploy();
    await swapPoolImpl.deployed();
    console.log("✅ SwapPool Implementation:", swapPoolImpl.address);

    // 3. Deploy StonerFeePool Implementation
    console.log("\n3️⃣ Deploying StonerFeePool Implementation...");
    const StonerFeePool = await ethers.getContractFactory("StonerFeePool");
    const stonerPoolImpl = await StonerFeePool.deploy();
    await stonerPoolImpl.deployed();
    console.log("✅ StonerFeePool Implementation:", stonerPoolImpl.address);

    // 4. Deploy SwapPoolFactory
    console.log("\n4️⃣ Deploying SwapPoolFactory...");
    const SwapPoolFactory = await ethers.getContractFactory("SwapPoolFactoryNative");
    const factory = await SwapPoolFactory.deploy(swapPoolImpl.address);
    await factory.deployed();
    console.log("✅ SwapPoolFactory deployed to:", factory.address);

    // 5. Configuration
    console.log("\n5️⃣ Configuring Contracts...");
    
    // Set factory address in StakeReceipt if needed
    // Configure default parameters
    
    console.log("\n🎉 Deployment Complete!");
    console.log("📋 Contract Addresses:");
    console.log("├── StakeReceipt:", stakeReceipt.address);
    console.log("├── SwapPool Implementation:", swapPoolImpl.address);
    console.log("├── StonerFeePool Implementation:", stonerPoolImpl.address);
    console.log("└── SwapPoolFactory:", factory.address);

    // Save deployment info
    const deploymentInfo = {
        network: hre.network.name,
        deployer: deployer.address,
        contracts: {
            stakeReceipt: stakeReceipt.address,
            swapPoolImpl: swapPoolImpl.address,
            stonerPoolImpl: stonerPoolImpl.address,
            factory: factory.address
        },
        timestamp: new Date().toISOString()
    };

    await saveDeploymentInfo(deploymentInfo);
    return deploymentInfo;
}

async function saveDeploymentInfo(info) {
    const fs = require('fs');
    const path = `deployments/${info.network}_deployment.json`;
    fs.writeFileSync(path, JSON.stringify(info, null, 2));
    console.log("💾 Deployment info saved to:", path);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error("❌ Deployment failed:", error);
        process.exit(1);
    });
```

### 2. Pool Creation Script (`deploy/02_create_test_pool.js`)

```javascript
const { ethers } = require("hardhat");

async function main() {
    console.log("🎯 Creating Test Pool...");
    
    // Load deployment info
    const deploymentInfo = require(`../deployments/${hre.network.name}_deployment.json`);
    
    // Get contracts
    const factory = await ethers.getContractAt("SwapPoolFactoryNative", deploymentInfo.contracts.factory);
    const stakeReceipt = await ethers.getContractAt("StakeReceipt", deploymentInfo.contracts.stakeReceipt);
    
    // Deploy test NFT collection
    console.log("🖼️ Deploying Test NFT Collection...");
    const TestNFT = await ethers.getContractFactory("TestNFT");
    const testNFT = await TestNFT.deploy("Test Collection", "TEST");
    await testNFT.deployed();
    console.log("✅ Test NFT deployed to:", testNFT.address);

    // Create swap pool
    console.log("🏊 Creating Swap Pool...");
    const tx = await factory.createPool(
        testNFT.address,    // NFT collection
        20                  // 20% to stoner pool
    );
    const receipt = await tx.wait();
    
    // Get pool address from events
    const poolCreatedEvent = receipt.events.find(e => e.event === 'PoolCreated');
    const poolAddress = poolCreatedEvent.args.poolAddress;
    
    console.log("✅ Swap Pool created at:", poolAddress);
    
    // Configure StakeReceipt to allow this pool
    console.log("🔧 Configuring StakeReceipt...");
    await stakeReceipt.setPool(poolAddress);
    
    console.log("🎉 Test Pool Setup Complete!");
    
    // Update deployment info
    deploymentInfo.testPool = {
        nftCollection: testNFT.address,
        swapPool: poolAddress,
        stonerShare: 20
    };
    
    await saveDeploymentInfo(deploymentInfo);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error("❌ Pool creation failed:", error);
        process.exit(1);
    });
```

### 3. Verification Script (`deploy/03_verify_contracts.js`)

```javascript
const { run } = require("hardhat");

async function main() {
    console.log("🔍 Verifying Contracts...");
    
    // Load deployment info
    const deploymentInfo = require(`../deployments/${hre.network.name}_deployment.json`);
    
    const contracts = [
        {
            name: "StakeReceipt",
            address: deploymentInfo.contracts.stakeReceipt,
            constructorArguments: ["JPEGSwap Stake Receipt", "JSR"]
        },
        {
            name: "SwapPoolNative",
            address: deploymentInfo.contracts.swapPoolImpl,
            constructorArguments: []
        },
        {
            name: "StonerFeePool",
            address: deploymentInfo.contracts.stonerPoolImpl,
            constructorArguments: []
        },
        {
            name: "SwapPoolFactoryNative",
            address: deploymentInfo.contracts.factory,
            constructorArguments: [deploymentInfo.contracts.swapPoolImpl]
        }
    ];

    for (const contract of contracts) {
        try {
            console.log(`📋 Verifying ${contract.name}...`);
            await run("verify:verify", {
                address: contract.address,
                constructorArguments: contract.constructorArguments,
            });
            console.log(`✅ ${contract.name} verified`);
        } catch (error) {
            console.log(`❌ ${contract.name} verification failed:`, error.message);
        }
    }
    
    console.log("🎉 Verification Complete!");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error("❌ Verification failed:", error);
        process.exit(1);
    });
```

## 🌐 Network Configuration

### Hardhat Config (`hardhat.config.js`)

```javascript
require("@nomicfoundation/hardhat-toolbox");
require("@openzeppelin/hardhat-upgrades");
require("dotenv").config();

module.exports = {
    solidity: {
        version: "0.8.19",
        settings: {
            optimizer: {
                enabled: true,
                runs: 200
            }
        }
    },
    networks: {
        // Ethereum Mainnet
        mainnet: {
            url: `https://mainnet.infura.io/v3/${process.env.INFURA_PROJECT_ID}`,
            accounts: [process.env.PRIVATE_KEY],
            gasPrice: 20000000000, // 20 gwei
        },
        // Polygon
        polygon: {
            url: "https://polygon-rpc.com",
            accounts: [process.env.PRIVATE_KEY],
            gasPrice: 30000000000, // 30 gwei
        },
        // Arbitrum
        arbitrum: {
            url: "https://arb1.arbitrum.io/rpc",
            accounts: [process.env.PRIVATE_KEY],
            gasPrice: 1000000000, // 1 gwei
        },
        // Sonic (Current deployment)
        sonic: {
            url: "https://rpc.sonic.org",
            accounts: [process.env.PRIVATE_KEY],
            gasPrice: 1000000000, // 1 gwei
        },
        // Testnets
        goerli: {
            url: `https://goerli.infura.io/v3/${process.env.INFURA_PROJECT_ID}`,
            accounts: [process.env.PRIVATE_KEY],
        }
    },
    etherscan: {
        apiKey: {
            mainnet: process.env.ETHERSCAN_API_KEY,
            polygon: process.env.POLYGONSCAN_API_KEY,
            arbitrumOne: process.env.ARBISCAN_API_KEY,
            goerli: process.env.ETHERSCAN_API_KEY
        }
    },
    gasReporter: {
        enabled: process.env.REPORT_GAS !== undefined,
        currency: "USD",
    }
};
```

### Environment Template (`.env.example`)

```bash
# Private key for deployment (without 0x prefix)
PRIVATE_KEY=your_private_key_here

# Infura Project ID for Ethereum networks
INFURA_PROJECT_ID=your_infura_project_id

# API Keys for contract verification
ETHERSCAN_API_KEY=your_etherscan_api_key
POLYGONSCAN_API_KEY=your_polygonscan_api_key
ARBISCAN_API_KEY=your_arbiscan_api_key

# Gas reporting (optional)
REPORT_GAS=true
COINMARKETCAP_API_KEY=your_coinmarketcap_key

# Network specific settings
DEFAULT_SWAP_FEE=10000000000000000  # 0.01 ETH in wei
DEFAULT_STONER_SHARE=20             # 20% to stoner pool
DEFAULT_BATCH_SIZE=10               # Default batch limit
```

## 📋 Package.json Scripts

```json
{
    "scripts": {
        "compile": "hardhat compile",
        "test": "hardhat test",
        "test:coverage": "hardhat coverage",
        "deploy:full": "hardhat run deploy/01_deploy_ecosystem.js",
        "deploy:pool": "hardhat run deploy/02_create_test_pool.js",
        "deploy:verify": "hardhat run deploy/03_verify_contracts.js",
        "deploy:mainnet": "npm run deploy:full -- --network mainnet && npm run deploy:verify -- --network mainnet",
        "deploy:polygon": "npm run deploy:full -- --network polygon && npm run deploy:verify -- --network polygon",
        "deploy:arbitrum": "npm run deploy:full -- --network arbitrum && npm run deploy:verify -- --network arbitrum",
        "deploy:sonic": "npm run deploy:full -- --network sonic",
        "deploy:test": "npm run deploy:full -- --network goerli && npm run deploy:pool -- --network goerli"
    }
}
```

## 🔧 Post-Deployment Configuration

### Batch Limits Configuration
```javascript
// Configure optimal batch limits after deployment
const swapPool = await ethers.getContractAt("SwapPoolNative", poolAddress);

// Set production-ready limits
await swapPool.setBatchLimits(
    25,  // maxBatchSize (increased for production)
    50   // maxUnstakeAllLimit (higher for better UX)
);
```

### Factory Global Settings
```javascript
const factory = await ethers.getContractAt("SwapPoolFactoryNative", factoryAddress);

// Configure factory-wide settings
await factory.setDefaultSwapFee(ethers.utils.parseEther("0.01"));
await factory.setDefaultStonerShare(20); // 20% to stoner pools
```

## 📊 Deployment Verification Checklist

### ✅ Pre-Deployment
- [ ] Environment variables configured
- [ ] Network settings validated
- [ ] Deployer account has sufficient balance
- [ ] Smart contracts compiled successfully

### ✅ Post-Deployment
- [ ] All contracts deployed and verified
- [ ] Initialization completed successfully
- [ ] Batch limits configured appropriately
- [ ] Test pool created and functional
- [ ] StakeReceipt permissions set correctly
- [ ] Gas estimation functions working
- [ ] Event emissions verified

### ✅ Production Readiness
- [ ] Security audit completed
- [ ] Admin functions access controlled
- [ ] Emergency functions tested
- [ ] Upgrade mechanisms validated
- [ ] Performance benchmarked
- [ ] Documentation updated

## 🚨 Emergency Procedures

### Contract Pause (if needed)
```javascript
// Emergency pause all operations
await swapPool.pause();
await stonerPool.pause();
```

### Upgrade Preparation
```javascript
// For UUPS upgrades
const newImplementation = await SwapPool.deploy();
await swapPool.upgradeTo(newImplementation.address);
```

## 📈 Success Metrics

After deployment, verify these metrics:
- ✅ Gas costs within expected ranges
- ✅ All functions executable without errors
- ✅ Events emitted correctly
- ✅ Security features functioning
- ✅ Frontend integration possible

---

**Ready for automated deployment?** 🚀

Run `npm run deploy:full -- --network [your-network]` to deploy the complete JPEGSwap ecosystem!
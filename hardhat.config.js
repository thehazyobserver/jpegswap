require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: {
    version: "0.8.19",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1  // Very low runs for size optimization
      },
      viaIR: true,  // Enable IR optimization for better size reduction
      evmVersion: "london"
    }
  },
  networks: {
    sonic: {
      url: "https://rpc.soniclabs.com/",
      chainId: 146
    }
  }
};

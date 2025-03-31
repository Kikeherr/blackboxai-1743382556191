# ZoicTrack Blockchain Integration Guide

## Prerequisites
1. Node.js (v14+)
2. npm/yarn
3. Truffle/Hardhat (for contract deployment)
4. MetaMask wallet with testnet ETH
5. Infura project ID

## Setup Steps

### 1. Install Dependencies
```bash
npm install -g truffle
npm install @truffle/hdwallet-provider dotenv
```

### 2. Environment Configuration
Create `.env` file:
```env
INFURA_PROJECT_ID=your_infura_id
MNEMONIC="your wallet mnemonic phrase"
CONTRACT_OWNER=0xYourWalletAddress
```

### 3. Contract Deployment
```bash
truffle migrate --network ropsten
```

### 4. Update Configuration
After deployment, update `blockchain_config.json` with:
- Contract address from deployment
- Your wallet address
- Infura project ID

## Smart Contract Development

### Testing
```bash
truffle test
```

### Verifying on Etherscan
```bash
truffle run verify ZoicTrack --network ropsten
```

## Security Notes
- Never commit `.env` to version control
- Use testnet for development
- Store private keys securely
- Consider using hardware wallets in production

## Troubleshooting
- Insufficient funds: Get Ropsten ETH from faucet
- Connection issues: Verify Infura project ID
- Gas errors: Adjust gas price in config
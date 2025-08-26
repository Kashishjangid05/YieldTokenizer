
<div align="center">
   <h1>🚀 YieldTokenizer</h1>
   <p><b>Tokenize your yield on the Stacks blockchain with Clarity smart contracts.</b></p>
  
   <a href="https://clarity-lang.org/" target="_blank"><img src="https://img.shields.io/badge/clarity-v1.0-blue?logo=stacks" alt="Clarity" /></a>
   <a href="https://github.com/hirosystems/clarinet-sdk" target="_blank"><img src="https://img.shields.io/badge/clarinet-dev--tool-orange" alt="Clarinet" /></a>
   <a href="https://vitest.dev/" target="_blank"><img src="https://img.shields.io/badge/tested%20with-vitest-6E9F18.svg?logo=vitest" alt="Vitest" /></a>
   <a href="https://nodejs.org/" target="_blank"><img src="https://img.shields.io/badge/node-%3E=18.0.0-green?logo=node.js" alt="Node.js" /></a>
</div>

---

## 📖 Project Overview

YieldTokenizer is a Clarity smart contract project designed to tokenize and manage yield on the Stacks blockchain. It provides a robust framework for simulating, testing, and deploying yield-based DeFi primitives using Clarinet and Vitest.

---

## 🛠️ Tech Stack

| Technology   | Description                        |
| ------------ | ---------------------------------- |
| Clarity      | Smart contract language (Stacks)   |
| Clarinet     | Dev & testing framework            |
| Vitest       | JS/TS testing framework            |
| Node.js      | Runtime (v18+ recommended)         |

---

## ⚡ Quick Start

```sh
# 1. Clone the repository
git clone <your-repo-url>
cd YieldTokenizer

# 2. Install dependencies
npm install

# 3. Run tests
npx vitest

# 4. Simulate contracts locally
clarinet integrate
```

---

## 📦 Smart Contract Address
ST5VY23SM2P74BAXHT992TBYRHPS1VES3GDBRYN2.YieldTokenizer
![alt text](image.png)


---

## 💡 How to Use

1. Edit the Clarity contract in [`contracts/YieldTokenizer.clar`](contracts/YieldTokenizer.clar).
2. Write and run tests in [`tests/YieldTokenizer.test.ts`](tests/YieldTokenizer.test.ts).
3. Use Clarinet to simulate and interact with the contract locally.
4. Deploy to Stacks Testnet/Mainnet using Clarinet CLI.

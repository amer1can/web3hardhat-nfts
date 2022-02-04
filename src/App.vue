<template>
  <div class="main">
    <div class="header pt-4">My awesome NFT collection</div>
    <p class="subheader mt-3">Special! Unique! Top rated NFT for you!</p>
    <button v-if="!account" class="walletbtn mt-3" @click="connect">{{ buttonStatus }}</button>
    <button v-else class="walletbtn mt-3" @click="askContractToMintNft">Mint NFT</button>
    <label class="status d-block mt-3">{{ walletConnectionStatus }}</label>
    <label class="status d-block mt-3">{{ networkStatus }}</label>

    <div class="newnft mt-3" v-if="tokenId">
      <p class="mess">Hey there! We've minted your NFT!</p>
      <p><a :href='`https://rinkeby.rarible.com/token/${contractAddress}:${tokenId}`' target="_blank">Here's the link</a></p>
      <p class="total mt-2 text-center text-uppercase">{{ tokenId }} / 50 minted</p>
    </div>
    <div class="newnft mt-3" v-else>
      <h3>No new NFTs :(</h3>
<!--      <p class="total mt-2 text-center text-uppercase">{{ tokenId }} / 50 minted</p>-->
    </div>
  </div>

  <div class="footer">
    <img src="./assets/twitter-logo.svg" alt="">
    <a href="https://twitter.com/amer1canWM" target="_blank" rel="noreferrer">Seeing on Twitter</a>
  </div>

</template>

<script>

import ethers from 'ethers';
import abi from './utils/EpicNFT.json';

export default {
  name: 'App',
  data() {
    return {
      contractAddress: "0xeea903D138be8F6a6c040f5232259C3BeA25e9D2",
      contractABI: abi.abi,
      buttonStatus: "Connect to Wallet",
      walletConnectionStatus: null,
      networkStatus: null,
      account: null,
      tokenId: null,
    }
  },
  mounted() {
    this.checkWalletConnection();
  },
  methods: {
    async checkWalletConnection() {
      const { ethereum } = window;

      if(!ethereum) {
        console.log("Make sure you have metamask!");
        this.buttonStatus = "Install Metamask";
        return;
      } else {
        console.log("We have the ethereum object", ethereum)
      }

      const chainId = await ethereum.request({
        method: 'eth_chainId'
      });
      console.log('Connected to chain: ', chainId)

      const rinkebyChainId = '0x4';
      if (chainId !== rinkebyChainId) {
        alert("You are not connected to Rinkeby Test Network!");
      } else {
        const accounts = await ethereum.request({
          method: 'eth_accounts'
        });

        // проверяем есть ли доступ к уже авторизованным аккаунтам
        if (accounts.length !==0) {
          this.account = accounts[0];
          console.log("Found authorized account: ", this.account);
          this.buttonStatus = "Connected";
          this.walletConnectionStatus = "Account: " + this.account;
          await this.setupMintListener();
        } else {
          console.log("No authorized accounts found");
          this.walletConnectionStatus = "No authorized accounts found";
        }
      }
    },
    async connect() {
      try {
        const { ethereum } = window;
        if(!ethereum) {
          alert("Get Metamask!");
        }

        const chainId = await ethereum.request({
          method: 'eth_chainId'
        });
        console.log('Connected to chain: ', chainId)

        const rinkebyChainId = '0x4';
        if (chainId !== rinkebyChainId) {
          alert("You are not connected to Rinkeby Test Network!");
        } else {
          const accounts = await ethereum.request({
            method: 'eth_requestAccounts'
          });
          this.account = accounts[0];
          console.log("Connected: ", this.account);
          this.buttonStatus = "Connected";
          this.walletConnectionStatus = "Account: " + this.account;
        }

      } catch(err) {
        console.log(err);
      }
    },
    async askContractToMintNft() {
      try {
        const { ethereum } = window;

        if (ethereum) {
          const provider = new ethers.providers.Web3Provider(ethereum);
          const signer = provider.getSigner();
          const connectedContract = new ethers.Contract(this.contractAddress, this.contractABI, signer);

          await this.setupMintListener();

          console.log("Going to pop wallet now to pay gas...");
          console.log("Gas price: ", signer.getGasPrice());
          let nftTxn = await connectedContract.makeEpicNFT();
          console.log("Mining... Please, wait.");
          await nftTxn.wait();

          console.log(`Mined, see transaction: https://rinkeby.etherscan.io/tx/${nftTxn.hash}`);
        } else {
          console.log("Ethereum object doesn't exist!");
        }
      } catch(err) {
        console.log(err);
      }
    },
    async setupMintListener() {
      try {
        const { ethereum } = window;

        if (ethereum) {
          const provider = new ethers.providers.Web3Provider(ethereum);
          const signer = provider.getSigner();
          const connectedContract = new ethers.Contract(this.contractAddress, this.contractABI, signer);
          connectedContract.on("NewNFTMinted", (from, tokenId) => {
            console.log(from, tokenId.toNumber());
            this.tokenId = tokenId.toNumber();
            // alert(`Hey there! We've minted your NFT. It may be blank right now. It can take a max of 10 min to show up on OpenSea. Here's the link: <https://rinkeby.rarible.com/token/${this.contractAddress}:${tokenId.toNumber()}>`)
          })
          console.log("Setup event listener!")

        } else {
          console.log("Ethereum object doesn't exist!");
        }
      } catch(err) {
        console.log(err);
      }
    },
  }
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  background: #100f0f;
  display: flex;
  flex-direction: column;
  height: 100vh;
}
.main {
  flex-grow: 1;
}
.header {
  font-size: 50px;
  font-weight: bold;
  background: -webkit-linear-gradient(left, #e8b756 30%, #e71515 60%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}
.subheader {
  font-size: 30px;
  color: white;
}
.walletbtn {
  font-size: 22px;
  padding: 0.5em;
  border-radius: 15px;
  background: -webkit-linear-gradient(left, #e8b756, #e71515);
  background-size: 200% 200%;
  animation: gradient-animation 4s ease infinite;
  align-self: center;
}
.status {
  color: darkgrey;
}
.newnft {
  margin: 0 auto;
  padding: 20px;
  max-width: 320px;
  border: 1px solid grey;
  border-radius: 20px;
}
.newnft a {
  color: crimson;
  text-decoration: none;
  font-weight: 600;
  font-size: 20px;
}
.mess {
  color: #e8b756;
}
.total {
  color: darkgrey;
  font-size: 18px;
}

.footer {
  padding: 20px 0px;
}
.footer a {
  color: coral;
  font-size: 18px;
  font-weight: bold;
  text-decoration: none;
  transition: all 0.2s ease-in;
}
.footer a:hover {
  color: #ff4444;
  transition: all 0.2s ease-in;
}
.footer img {
  width: 30px;
}


/* KeyFrames */
@-webkit-keyframes gradient-animation {
  0% {
    background-position: 0% 50%;
  }
  50% {
    background-position: 100% 50%;
  }
  100% {
    background-position: 0% 50%;
  }
}
@-moz-keyframes gradient-animation {
  0% {
    background-position: 0% 50%;
  }
  50% {
    background-position: 100% 50%;
  }
  100% {
    background-position: 0% 50%;
  }
}
@keyframes gradient-animation {
  0% {
    background-position: 0% 50%;
  }
  50% {
    background-position: 100% 50%;
  }
  100% {
    background-position: 0% 50%;
  }
}
</style>

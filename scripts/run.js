const hre = require("hardhat");

async function main() {
    const EpicNFTFactory = await hre.ethers.getContractFactory("EpicNFT");
    const epicNftContract = await EpicNFTFactory.deploy();

    await epicNftContract.deployed();

    console.log("EpicNFT deployed to:", epicNftContract.address);

    let txn = await epicNftContract.makeEpicNFT();
    await txn.wait();

    txn = await epicNftContract.makeEpicNFT();
    await txn.wait();
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });

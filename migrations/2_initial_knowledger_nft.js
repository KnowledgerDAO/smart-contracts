const OwnerContract = artifacts.require("Owner");
const BuyerContract = artifacts.require("Buyer");
// const KnowledgerNFT = artifacts.require("KnowledgerNFT");

module.exports = async function (deployer, network, [owner]) {
    await deployer.deploy(OwnerContract, [owner]);
    // const ownerInstance = await OwnerContract.deployed();
    await deployer.deploy(BuyerContract);
};

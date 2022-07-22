const OwnerContract = artifacts.require("Owner");
const BuyerContract = artifacts.require("Buyer");
const PublisherContract = artifacts.require("Publisher");
const ReviewerContract = artifacts.require("Reviewer");
const ContentContract = artifacts.require("Content");
const KnowledgerNFT = artifacts.require("KnowledgerNFT");

module.exports = async function (deployer, network, [owner]) {
    await deployer.deploy(OwnerContract, [owner]);
    const ownerInstance = await OwnerContract.deployed();
    const buyerInstance = await deployer.deploy(BuyerContract, ownerInstance.address);
    const reviewerInstance = await deployer.deploy(ReviewerContract);
    const publisherInstance = await deployer.deploy(PublisherContract);
    const contentInstance = await deployer.deploy(ContentContract, reviewerInstance.address, publisherInstance.address);
    await deployer.deploy(KnowledgerNFT, ownerInstance.address, publisherInstance.address, reviewerInstance.address, buyerInstance.address, contentInstance.address);
};

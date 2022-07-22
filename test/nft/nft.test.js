const { expect } = require("chai")
const OwnerContract = artifacts.require("Owner");
const BuyerContract = artifacts.require("Buyer");
const PublisherContract = artifacts.require("Publisher");
const ReviewerContract = artifacts.require("Reviewer");
const ContentContract = artifacts.require("Content");
const KnowledgerNFT = artifacts.require("KnowledgerNFT");

require("chai")
    .use(require("chai-as-promised"))
    .should();

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("KnowledgerNFT", function ([owner]) {

    let ownerContract;
    let buyerContract;
    let publisherContract;
    let reviewerContract;
    let contentContract;
    let knowledgerNFT;

    before(async () => {
        ownerContract = await OwnerContract.deployed();
        buyerContract = await BuyerContract.deployed();
        publisherContract = await PublisherContract.deployed();
        reviewerContract = await ReviewerContract.deployed();
        contentContract = await ContentContract.deployed();
        knowledgerNFT = await KnowledgerNFT.deployed();
    });

    describe(".deployed", () => {
        it("should verify that contracts have been deployed with success", async () => {
            expect(ownerContract).to.not.eq(null);
            expect(buyerContract).to.not.eq(null);
            expect(publisherContract).to.not.eq(null);
            expect(reviewerContract).to.not.eq(null);
            expect(contentContract).to.not.eq(null);
            expect(knowledgerNFT).to.not.eq(null);
        });
    });

});

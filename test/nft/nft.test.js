const { expect } = require("chai")
const OwnerContract = artifacts.require("Owner");
const BuyerContract = artifacts.require("Buyer");
const PublisherContract = artifacts.require("Publisher");
const ReviewerContract = artifacts.require("Reviewer");
const ContentContract = artifacts.require("Content");
const KnowledgerNFT = artifacts.require("KnowledgerNFT");
const KnowledgerToken = artifacts.require("Knowledger");

require("chai")
    .use(require("chai-as-promised"))
    .should();

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("KnowledgerNFT", function ([owner, publisher, reviewer1, reviewer2, reviewer3, buyer]) {

    const CONTENT_PROPOSED_EVENT_NAME = 'ContentProposed';

    let ownerContract;
    let buyerContract;
    let publisherContract;
    let reviewerContract;
    let contentContract;
    let knowledgerNFT;
    let knowledgerToken;

    before(async () => {
        ownerContract = await OwnerContract.deployed();
        buyerContract = await BuyerContract.deployed();
        publisherContract = await PublisherContract.deployed();
        reviewerContract = await ReviewerContract.deployed();
        contentContract = await ContentContract.deployed();
        knowledgerToken = await KnowledgerToken.deployed();
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

    describe(".proposeContent", () => {
        before(async () => {
            await knowledgerNFT.allowPublisher(publisher, { from: publisher });
            await knowledgerNFT.allowReviewer(reviewer1, { from: reviewer1 });
            await knowledgerNFT.allowReviewer(reviewer2, { from: reviewer2 });
            await knowledgerNFT.allowReviewer(reviewer3, { from: reviewer3 });
            await knowledgerNFT.allowBuyer(buyer, { from: buyer });
        });

        it("should propose a content with success", async () => {
            const event = await knowledgerNFT.proposeContent(publisher, "about:blank", knowledgerToken.address, 10, 2, 1, { from: publisher });
            console.log(event);
            const contentProposedEvent = event.logs.find(log => log.event === CONTENT_PROPOSED_EVENT_NAME).args;
            expect(contentProposedEvent.tokenId.toNumber()).to.eq(0);
            expect(contentProposedEvent.contentURI).to.eq("about:blank");
        });
    });

});

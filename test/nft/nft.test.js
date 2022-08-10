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
contract("KnowledgerNFT", function ([owner, publisher, reviewer1, reviewer2, reviewer3, buyer, publisher2]) {

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
            const contentProposedEvent = event.logs.find(log => log.event === CONTENT_PROPOSED_EVENT_NAME).args;
            expect(contentProposedEvent.publisher).to.eq(publisher);
            expect(contentProposedEvent.tokenId.toNumber()).to.eq(0);
            expect(contentProposedEvent.contentURI).to.eq("about:blank");
        });

        it("shouldn't propose a content because the caller is not a publisher", async () => {
            await knowledgerNFT.proposeContent(reviewer1, "about:blank", knowledgerToken.address, 10, 2, 1, { from: reviewer1 })
                .should.be.rejectedWith(/is missing role/);
        });

        it("shouldn't propose a content because the value is 0", async () => {
            await knowledgerNFT.proposeContent(publisher, "about:blank", knowledgerToken.address, 0, 2, 1, { from: publisher })
                .should.be.rejectedWith(/The price must be greater than 0/);
        });

        it("shouldn't propose a content because prize percentage must be greater than 1", async () => {
            await knowledgerNFT.proposeContent(publisher, "about:blank", knowledgerToken.address, 10, 1, 1, { from: publisher })
                .should.be.rejectedWith(/The prize percentage must be greater than 1/);
        });

        it("shouldn't propose a content because sum of percentages must be less than 10", async () => {
            await knowledgerNFT.proposeContent(publisher, "about:blank", knowledgerToken.address, 10, 5, 6, { from: publisher })
                .should.be.rejectedWith(/Sum of percentages can not be greater than 10/);
        });
    });

    describe(".getContent", () => {
        it("should retrieve a content created successfully", async () => {
            const [tokenId, contentURI]  = await knowledgerNFT.getContent.call(0);

            expect(Number(tokenId)).to.eq(0);
            expect(contentURI).to.eq("about:blank");
        });

        it("shouldn't retrieve a content with unexisting ID", async () => {
            await knowledgerNFT.getContent.call(1)
                .should.be.rejectedWith(/URI query for nonexistent token/);
        });
    });

    describe(".getContent", () => {
        it("should retrieve a content created successfully", async () => {
            const [tokenId, contentURI]  = await knowledgerNFT.getContent.call(0);

            expect(Number(tokenId)).to.eq(0);
            expect(contentURI).to.eq("about:blank");
        });

        it("shouldn't retrieve a content with unexisting ID", async () => {
            await knowledgerNFT.getContent.call(1)
                .should.be.rejectedWith(/URI query for nonexistent token/);
        });
    });

    describe(".getPublisherContents", () => {
        it("should retrieve the list of contents assigned successfully", async () => {
            const [result]  = await knowledgerNFT.getPublisherContents.call(publisher, { from: publisher });
            console.log(result);
            
            const response  = await contentContract.getContent.call(0, { from: publisher });
            console.log(response);

            const [tokenId, contentURI] = result;
            expect(Number(tokenId)).to.eq(0);
            expect(contentURI).to.eq("about:blank");
        });

        it("shouldn't retrieve the list of contents for unexisting publisher", async () => {
            await knowledgerNFT.getPublisherContents.call(publisher2, { from: publisher2 })
                .should.be.rejectedWith(/This publisher doesn't have any content assigned/);
        });
    });

});

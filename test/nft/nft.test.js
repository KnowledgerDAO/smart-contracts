const { expect } = require("chai")
const OwnerContract = artifacts.require("Owner");
const BuyerContract = artifacts.require("Buyer");

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
    let buyerContractBuyerContract;

    before(async () => {
        ownerContract = await OwnerContract.deployed();
        buyerContract = await BuyerContract.deployed();
    });

    describe(".deployed", () => {
        it("should verify that contracts have been deployed with success", async () => {
            expect(ownerContract).to.not.eq(null);
            expect(buyerContract).to.not.eq(null);
        });
    });

});

const { expect } = require("chai")
const KnowledgerTreasure = artifacts.require("Treasure");

require("chai")
    .use(require("chai-as-promised"))
    .should();

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("KnowledgerTreasure", function ([owner, anotherOwner]) {

    const EVENT_NAME = "ValueChanged";
    const VALUE_TO_STORE = 100;

    let contract;

    before(async () => {
        contract = await KnowledgerTreasure.deployed();
    });

    describe(".owner", () => {
        it("should retrieve the owner with success", async () => {
            const ownerAddress = await contract.owner.call();
            expect(ownerAddress).to.eq(owner);
            expect(ownerAddress).to.not.eq(anotherOwner);
        });
    });

    describe(".store", () => {
        it("should store a new value successfully", async () => {
            const event = await contract.store(VALUE_TO_STORE, { from: owner });
            const eventObject = event.logs.find(log => log.event === EVENT_NAME).args;
            expect(eventObject.newValue.toNumber()).to.eq(VALUE_TO_STORE);
        });

        it("should fail whenever another owner attempts to store a new value", async () => {
            await contract.store(VALUE_TO_STORE, { from: anotherOwner }).should.be.rejected;
        });
    });

    describe(".retrieve", () => {
        it("should retrieve the value stored before successfully", async () => {
            const valueStored = await contract.retrieve.call();
            expect(valueStored.toNumber()).to.eq(VALUE_TO_STORE);
        });
    });

    describe(".transferOwnership", () => {
        it("should transfer the ownership to another address successfully", async () => {
            await contract.transferOwnership(anotherOwner, { from: owner });
            const ownerAddress = await contract.owner.call();
            expect(ownerAddress).to.eq(anotherOwner);
            expect(ownerAddress).to.not.eq(owner);
        });

        it("should fail whenever another address attempts to transfer the ownership without the right grant", async () => {
            const oldOwner = owner;
            await contract.transferOwnership(oldOwner, { from: oldOwner }).should.be.rejected;
        });
    });

    describe(".renounceOwnership", () => {
        it("should fail whenever another address attempts to renounce the ownership without the right grant", async () => {
            const oldOwner = owner;
            await contract.renounceOwnership({ from: oldOwner }).should.be.rejected;
        });

        it("should renounce the ownership successfully", async () => {
            await contract.renounceOwnership({ from: anotherOwner });
            const ownerAddress = await contract.owner.call();
            expect(parseInt(ownerAddress, 16)).to.eq(0);
        });
    });
});

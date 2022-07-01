const { expect } = require('chai')
const KnowledgerToken = artifacts.require("Knowledger");

require('chai')
    .use(require('chai-as-promised'))
    .should();

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("KnowledgerToken", function ([owner, user1, user2]) {

    const INITIAL_SUPPLY = 1000000;
    const TRANSFER_EVENT_NAME = 'Transfer';

    let contract;

    before(async () => {
        contract = await KnowledgerToken.deployed();
    });

    describe('.initialSupply', () => {
        it("should validate the initial balance with success", async () => {
            const result = await contract.balanceOf.call(owner);
            assert.strictEqual(result.toNumber(), INITIAL_SUPPLY);
        });

        it("should validate the token's name", async () => {
            const name = await contract.name.call()
            assert.strictEqual(name, "Knowledger")
        });

        it("should validate the token's symbol", async () => {
            const symbol = await contract.symbol.call()
            assert.strictEqual(symbol, "KLD")
        });

        it("should validate the initial supply with success", async () => {
            const result = await contract.totalSupply();
            assert.strictEqual(result.toNumber(), INITIAL_SUPPLY);
        });
    });

    describe('.transfer', () => {
        it("should transfer token with success to user1", async () => {
            const balance = await contract.balanceOf.call(user1);
            assert.strictEqual(balance.toNumber(), 0);
            const event = await contract.transfer(user1, 1, { from: owner });
            const transferEvent = event.logs.find(log => log.event === TRANSFER_EVENT_NAME).args;
            expect(transferEvent.from).to.eq(owner);
            expect(transferEvent.to).to.eq(user1);
            expect(transferEvent.value.toNumber()).to.eq(1);
        });

        it("check balances with the previous transfer to user1", async () => {
            const newBalance = await contract.balanceOf.call(user1);
            const ownerBalance = await contract.balanceOf.call(owner);
            assert.strictEqual(ownerBalance.toNumber(), INITIAL_SUPPLY - 1);
            assert.strictEqual(newBalance.toNumber(), 1);
        });

        it("should transfer token with success to user2", async () => {
            const balance = await contract.balanceOf.call(user2);
            assert.strictEqual(balance.toNumber(), 0);
            const event = await contract.transfer(user2, 1, { from: owner });
            const transferEvent = event.logs.find(log => log.event === TRANSFER_EVENT_NAME).args;
            expect(transferEvent.from).to.eq(owner);
            expect(transferEvent.to).to.eq(user2);
            expect(transferEvent.value.toNumber()).to.eq(1);
        });

        it("check balances with the previous transfer to user2", async () => {
            const newBalance = await contract.balanceOf.call(user2);
            const ownerBalance = await contract.balanceOf.call(owner);
            assert.strictEqual(ownerBalance.toNumber(), INITIAL_SUPPLY - 2);
            assert.strictEqual(newBalance.toNumber(), 1);
        });
    });
});

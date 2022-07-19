const { expect } = require("chai")
const { v4: uuid } = require("uuid");
const KnowledgerTimelock = artifacts.require("Timelock");
// const web3 = require('web3');
const Time = require('../utils/time');
const TruffleUtils = require('../utils/truffle');

require("chai")
    .use(require("chai-as-promised"))
    .should();

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("KnowledgerTimelock", function ([admin, proposer1, proposer2, executor1, executor2, target]) {

    const SCHEDULE_EVENT_NAME = "CallScheduled";
    const EXECUTED_EVENT_NAME = "CallExecuted";
    const MIN_DELAY = 5;
    const METADATA = Buffer.from("test");
    const PREDECESSOR = web3.utils.asciiToHex(uuid().substring(0, 10));
    const SALT = web3.utils.asciiToHex(uuid().substring(0, 10));

    let contract;

    before(async () => {
        contract = await KnowledgerTimelock.deployed();
    });

    describe(".getMinDelay", () => {
        it("should retrieve the min delay with success", async () => {
            const minDelay = await contract.getMinDelay.call();
            expect(minDelay.toNumber()).to.eq(MIN_DELAY);
        });
    });

    describe('schedule and execute', () => {
        let id;
        const value = 10;

        describe(".schedule", () => {
            it("should schedule an operation containing a single transaction", async () => {
                const result = await contract.schedule(target, value, METADATA, PREDECESSOR, SALT, MIN_DELAY, { from: proposer1 });
                const event = result.logs.find(log => log.event === SCHEDULE_EVENT_NAME).args;
                id = event.id;
                expect(event.id).to.not.eq(null);
                expect(event.index.toNumber()).to.eq(0);
                expect(event.target).to.eq(target);
                expect(event.value.toNumber()).to.eq(value);
                expect(web3.utils.hexToAscii(event.data)).to.eq(METADATA.toString());
                expect(web3.utils.toUtf8(event.predecessor)).to.eq(web3.utils.toUtf8(PREDECESSOR));
                expect(event.delay.toNumber()).to.eq(MIN_DELAY);
            });
    
            it('should check with success that the new operation was scheduled and exists', async () => {
                expect(await contract.isOperation.call(id)).to.eq(true);
                expect(await contract.isOperationPending.call(id)).to.eq(true);
                expect(await contract.isOperationReady.call(id)).to.eq(false);
                expect(await contract.isOperationDone.call(id)).to.eq(false);
            });
    
            it(`shouldn't allow schedule an operation because it already exists`, async () => {
                await contract.schedule(target, value, METADATA, PREDECESSOR, SALT, MIN_DELAY, { from: proposer1 })
                    .should.be.rejectedWith(/operation already scheduled/);
            });
    
            it(`shouldn't allow schedule an operation because it doesn't achieve the minimum delay`, async () => {
                await contract.schedule(target, value + 1, METADATA, PREDECESSOR, SALT, MIN_DELAY - 1, { from: proposer1 })
                    .should.be.rejectedWith(/insufficient delay/);
            });
    
            it(`shouldn't allow schedule an operation for a non granted address`, async () => {
                await contract.schedule(target, value, METADATA, PREDECESSOR, SALT, MIN_DELAY, { from: executor1 })
                    .should.be.rejectedWith(/is missing role/);
            });
        });
    
        describe(".execute", () => {
            before(async () => {
                const oldBlock = await web3.eth.getBlock('latest');
                await TruffleUtils.advanceBlockAfterSomeSeconds(web3, MIN_DELAY + 1);
                const block = await web3.eth.getBlock('latest');
                const timestampOperation = await contract.getTimestamp.call(id);
                console.log(oldBlock.timestamp);
                console.log(block.timestamp);
                console.log(timestampOperation.toNumber());
            });

            it("should execute an operation containing a single transaction", async () => {
                const result = await contract.execute(target, value, METADATA, PREDECESSOR, SALT, { from: executor1 });
                const event = result.logs.find(log => log.event === EXECUTED_EVENT_NAME).args;
                expect(event.id).to.not.eq(id);
                expect(event.index.toNumber()).to.eq(0);
                expect(event.target).to.eq(target);
                expect(event.value.toNumber()).to.eq(value);
                expect(web3.utils.hexToAscii(event.data)).to.eq(METADATA.toString());
                expect(web3.utils.toUtf8(event.predecessor)).to.eq(web3.utils.toUtf8(PREDECESSOR));
            });
    
            it('should check with success that the new operation was executed and exists', async () => {
                expect(await contract.isOperation.call(id)).to.eq(true);
                expect(await contract.isOperationPending.call(id)).to.eq(true);
                expect(await contract.isOperationReady.call(id)).to.eq(true);
                expect(await contract.isOperationDone.call(id)).to.eq(false);
            });
    
            it(`shouldn't allow execute an operation for a non granted address`, async () => {
                await contract.execute(target, value, METADATA, PREDECESSOR, SALT, { from: proposer1 })
                    .should.be.rejectedWith(/is missing role/);
            });
        });
    });

});

const KnowledgerTimelock = artifacts.require("Timelock");

module.exports = function (deployer, network, [_, proposer1, proposer2, executor1, executor2]) {
  deployer.deploy(KnowledgerTimelock, 5, [proposer1, proposer2], [executor1, executor2]);
};

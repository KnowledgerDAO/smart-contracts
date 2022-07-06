const KnowledgerTreasure = artifacts.require("Treasure");

module.exports = function (deployer) {
  deployer.deploy(KnowledgerTreasure);
};

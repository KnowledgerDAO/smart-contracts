const KnowledgerToken = artifacts.require("Knowledger");

module.exports = function (deployer) {
  deployer.deploy(KnowledgerToken, 1000000);
};

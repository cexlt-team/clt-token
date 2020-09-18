const CLTReward = artifacts.require('CLTReward');

module.exports = function(deployer) {
  deployer.deploy(CLTReward);
};
const Unipool = artifacts.require('Unipool');

module.exports = function(deployer) {
  deployer.deploy(Unipool);
};
var Migrations = artifacts.require("./Migrations.sol");
var TokenPaymentChannel = artifacts.require('./TokenPaymentChannel.sol');

module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(TokenPaymentChannel);
};

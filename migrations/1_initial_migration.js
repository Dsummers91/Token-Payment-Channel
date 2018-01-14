var Migrations = artifacts.require("./Migrations.sol");
var TokenPaymentChannel = artifacts.require('./TokenPaymentChannel.sol');
const Token = artifacts.require('ERC20.sol');

module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(TokenPaymentChannel);
};
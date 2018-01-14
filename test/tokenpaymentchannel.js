const TokenPaymentChannel = artifacts.require('./TokenPaymentChannel.sol');
const ERC20 = artifacts.require('./ERC20.sol');


contract('TokenPaymentChannel', async (accounts) => {
  let token, contract;
  let dappOwner = accounts[9];

  before(async () => {
    contract = await TokenPaymentChannel.new({ from: dappOwner });
    token = await ERC20.new(100e18, "Token", 18, "TKN");
    await token.approve(contract.address, 100e18);
  })

  it('should be able to create a channel', async () => {
    let tokenAmount = 5e18;
    let channelHash = await contract.openChannel.call(token.address, tokenAmount);
    await contract.openChannel(token.address, tokenAmount);

    let channel = await contract.channel(channelHash);

    console.log(channel);
    let contractTokenBalance = await token.balanceOf(contract.address);
    console.log(contractTokenBalance);
  });
});
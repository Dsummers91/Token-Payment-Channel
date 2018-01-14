/// @title Token Payment Channel

pragma solidity ^0.4.18;

contract Token {
  function transfer(address, uint256) returns (bool) {}
  function transferFrom(address, address, uint256) returns (bool) {}
}

contract TokenPaymentChannel {
  address owner;
  mapping(bytes32 => Channel) channels;

  struct Channel {
    address tokenAddress;
    uint256 tokenAmount;
    bool isClosed;
    address participant;
  }

  function TokenPaymentChannel() public {
    owner = msg.sender;
  }

  /**
    @notice Participant must approve token contract to transfer tokens prior to opening channel
    @dev Opens a payment channel keeping the tokens within this contract as escrow
   */
  function openChannel(address _tokenAddress, uint256 _tokenAmount, uint8 _v, bytes32 _r, bytes32 _s) 
    public returns (bytes32 channelHash) 
  {
    bytes32 _channelHash = keccak256(_tokenAddress, _tokenAmount, msg.sender);
    require(Token(_tokenAddress).transferFrom(msg.sender, this, _tokenAmount));
    channels[_channelHash] = Channel(_tokenAddress, _tokenAmount, false, msg.sender);
    require(ecrecover(keccak256("\x19Ethereum Signed Message:\n32", _channelHash), _v, _r, _s) == owner);
    return _channelHash;
  }

  /**
    @dev Closes payment channel and sends token to owner, and refunds participant for remaining amount
    @param _channelHash  Hash of channel information
    @param _refundAmount Amount sent back to participant
    @param _channelCloseHash hash of all input from this function signed by both participants
    @param _v elliptic curve signature V
    @param _r elliptic curve signature R
    @param _s elliptic curve signature S
   */
  function closeChannel(bytes32 _channelHash, uint256 _refundAmount, bytes32 _channelCloseHash, uint8 _v, bytes32 _r, bytes32 _s) {
    bytes32 _hash = keccak256(_channelHash, _refundAmount);
    require(_channelCloseHash == _hash);
    require(ecrecover(keccak256("\x19Ethereum Signed Message:\n32", _hash), _v, _r, _s) == msg.sender);
    Channel _channel = channels[_channelHash];
    require(Token(_channel.tokenAddress).transfer(_channel.participant, _refundAmount));
    require(Token(_channel.tokenAddress).transfer(owner, _channel.tokenAmount - _refundAmount));
  }

  /**
    @notice Channel will be successfully voided after a certain number of blocks
    @dev Allows participant to void channel
   */
  function voidChannel() {
    
  }

  /**
    @dev After alotted time has passed since voidChannel has been called without 
   */
  function finalizeVoidChannel() {

  }

  /**
    @notice Since owner has a signed hash from participant, can take his word as law
    @dev If Owner has a signed hash from participant and he tries to void channel, owner can counter
   */
  function counterVoidChannel() {

  }

   /**
    @dev returns channel information
    */
  function channel(bytes32 _channelHash) public view returns (address, uint256, bool, address) {
    Channel _channel = channels[_channelHash];
    return (_channel.tokenAddress, _channel.tokenAmount, _channel.isClosed, _channel.participant);
  }

  function getChannelHash(address _tokenAddress, uint256 _tokenAmount, address _account) public view returns(bytes32) {
    return keccak256(_tokenAddress, _tokenAmount, _account);
  }


  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }

  modifier onlyParticipant(bytes32 _channelHash) {
    require(msg.sender == owner);
    _;
  }
}
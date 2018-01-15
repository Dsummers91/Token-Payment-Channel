/// @title Token Payment Channel

pragma solidity ^0.4.18;

contract Token {
  function transfer(address, uint256) public returns (bool) {}
  function transferFrom(address, address, uint256) public returns (bool) {}
}

contract TokenPaymentChannel {
  address owner;
  mapping(bytes32 => Channel) channels;

  struct Channel {
    address tokenAddress;
    uint256 tokenAmount;
    State state;
    address participant;
  }

  enum State {
    Open,
    Pending,
    Closed
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
    channels[_channelHash] = Channel(_tokenAddress, _tokenAmount, State.Open, msg.sender);
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
  function closeChannel(bytes32 _channelHash, uint256 _refundAmount, bytes32 _channelCloseHash, uint8 _v, bytes32 _r, bytes32 _s) 
    public onlyParticipant(_channelHash) returns (bool success)
  {
    require(ecrecover(keccak256("\x19Ethereum Signed Message:\n32", _channelCloseHash), _v, _r, _s) == owner);
    bytes32 _hash = keccak256(_channelHash, _refundAmount);
    Channel storage _channel = channels[_channelHash];
    _channel.state = State.Closed;
    require(_channelCloseHash == _hash || (_channelCloseHash == _channelHash && _refundAmount == _channel.tokenAmount));
    require(Token(_channel.tokenAddress).transfer(_channel.participant, _refundAmount));
    require(Token(_channel.tokenAddress).transfer(owner, _channel.tokenAmount - _refundAmount));
    return true;
  }

  /**
    @notice Channel will be successfully voided after a certain number of blocks
    @dev Allows participant to void channel
   */
  function voidChannel() public {
    
  }

  /**
    @dev After alotted time has passed since voidChannel has been called without 
   */
  function finalizeVoidChannel() public {

  }

  /**
    @notice Since owner has a signed hash from participant, can take his word as law
    @dev If Owner has a signed hash from participant and he tries to void channel, owner can counter
   */
  function counterVoidChannel() public {

  }

   /**
    @dev returns channel information
    */
  function channel(bytes32 _channelHash) public view returns (address, uint256, State, address) {
    Channel _channel = channels[_channelHash];
    return (_channel.tokenAddress, _channel.tokenAmount, _channel.state, _channel.participant);
  }

  function getChannelHash(address _tokenAddress, uint256 _tokenAmount, address _account) public view returns(bytes32) {
    return keccak256(_tokenAddress, _tokenAmount, _account);
  }

  function getChannelCloseHash(bytes32 _channelHash, uint256 _refundAmount) public view returns(bytes32) {
    return keccak256(_channelHash, _refundAmount);
  }


  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }

  modifier onlyParticipant(bytes32 _channelHash) {
    require(msg.sender == channels[_channelHash].participant);
    _;
  }
}
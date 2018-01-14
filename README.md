# Token-Payment-Channel
Offchain ERC20 Payment Channel for Dapps

For Dapps that require the token as a utility for ongoing use of the dapp

Each transaction is a two-party arrangement between an owner and participant. 


### How it works
In order to create a channel the participant will need approve the contract to transfer tokens to open the channel
1. Participant opens a channel and send tokens to the contract as escrow
2. Participant uses Dapp, and signs a hash(offchain) each time he does something that requires tokens
3. Once he finished, participants notifies owner that he wants to close the channel
4. Owner sends transaction to close channel, and owner receives tokens used, and participant receives whats leftover

If Participant wants to close channel without notifying owner, he may void the channel with most recent signed transaction.
if Owner disagrees with the transaction, owner may send a transaction that includes a participant signed hash, that certifies participant agreed on an amount in the past


If Owner wants to close channel he may do so at anytime because he has signed transaction from participant at all times.

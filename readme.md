# GeoETH Smart Contracts

## Description
This repository contains smart contracts for GeoETH, a Dapp for geocaching.

## Contracts

### AdventureFactory
This contract contains a function to mint new journey smart contracts. It also maintains an array of all journeys that have been created from it to be queried by the frontend.

#### Functions

`createNewAdventure`: a function that takes the arguments necessary to create a new journey smart contract. These arguments include a name, a description, the salt used in hashing secrets, an array of hashed secrets, a corresponding array of integer latitudes, a corresponding array of integer longitudes, and a corresponding array of string hints. Calling the function will create and deploy a new journey contract. The function is also payable. To add ETH to the journey contract as a reward, one simply adds ETH value to the function call transaction and it is transferred to the new contract. Once the contract is created, its address is stored in an array called `adventures`.

Views:

`getAdventures`: returns the array of journey contracts that have been created.

### Adventure
This contract is the template for creating new journeys. 

#### Functions
`constructor`: initializes the contract when a new instance is invoked. key variables are stored and an array of caches is created.

`submitClaim`: function for claim submission. The user will submit (via the frontend) a hash of the (secrets + sender address). The claim is stored in an array, and a mapping is created from claim to sender.

`submitProof`: function for verifying claims. The user passes to the function an array of raw secrets obtained from the various caches. The function reconstructs what the claim should have been given the sender and submitted secrets. It also checks that the hash of each (secret + revealed salt) matches the secrets provided in the contract initialization. If the submission matches a claim previously submiited by the user and the original secrets, the user wins. The contract state is set to resolved = true and any ETH in the contract is transferred to the user.

Views:

`getDetails`: returns an array of key parameters for the contract: name, creator, description, salt, caches, resolved, and contract balance.
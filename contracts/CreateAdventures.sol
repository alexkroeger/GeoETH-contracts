pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

contract AdventureFactory {
    
    // store created contracts in an array
    address[] public adventures; 

    function createNewAdventure(string _name, string _description, uint _salt, bytes32[] _secrets, uint[] _lats, uint[] _longs, string[] _hints) public payable returns (address) {
        Adventure a = new Adventure(msg.sender, _name, _description, _salt, _secrets, _lats, _longs, _hints);
        address(a).transfer(msg.value);
        adventures.push(a);
        return a;
    }

    function getAdventures() public view returns (address[]) {
        return adventures;
    }
}

contract Adventure {
    // Adventure Vars
    string name;
    string description;
    address creator;
    uint salt;
    bool resolved;
    uint payout;

    // Events
    // event if a proof is verified--this will resolve the adventure
    event ProofVerified(address _winner, uint _payout);

    // Cache struct 
	struct Cache {
        bytes32 secret;
        uint lat;
        uint long;
        string hint;
    }
    struct Claim {
        address claimer;
        bytes32 claim;
    }
    struct Proof {
        address prover;
        bytes32 proof;
    }
    Cache[] public caches;
    Claim[] public claims;
    Proof[] public proofs;

    mapping (bytes32 => address) claimToClaimer;

    constructor(address _creator, string _name, string _description, uint _salt, bytes32[] _secrets, uint[] _lats, uint[] _longs, string[] _hints) public payable {
    	name = _name;
    	description = _description;
    	salt = _salt;
    	creator = _creator;
    	resolved = false;

    	uint arrayLength = _secrets.length;

    	for (uint i=0; i<arrayLength; i++) {
            caches.push(Cache(_secrets[i], _lats[i], _longs[i], _hints[i]));
        }
    }

    uint numcaches = caches.length;

    function () public payable {}

    // submit hashed claim of secrets + address
    function submitClaim(bytes32 _claim) public {
        require(msg.sender != creator);
        claims.push(Claim(msg.sender, _claim));
        claimToClaimer[_claim] = msg.sender;
    }

    function submitProof(uint[] _secrets) public returns (bool) {
        require(resolved == false);
        bytes32 proof;
        proof = keccak256(abi.encodePacked(_secrets, msg.sender));
        proofs.push(Proof(msg.sender, proof));

        bool match_caches = true;

    	for (uint i=0; i<numcaches; i++) {
            if(keccak256(abi.encodePacked(_secrets[i], salt)) != caches[i].secret) {
                match_caches = false;
            }
        }

        if (claimToClaimer[proof] == msg.sender && match_caches == true) {
            resolved = true;
            payout = address(this).balance;
            msg.sender.transfer(payout);
            emit ProofVerified(msg.sender, payout);
            return true;
        }
        else {
            return false;
        }
    }

    function getDetails() public view returns(string, address, string, uint, Cache[], bool, uint) {
        return (name, creator, description, salt, caches, resolved, address(this).balance);
    }
}

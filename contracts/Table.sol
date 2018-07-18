pragma solidity ^0.4.23;

import "./Casino.sol";
import "./CasinoToken.sol";
import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./ERC223/ERC223Receiver.sol";

contract Table is ERC223Receiver {
    using SafeMath for uint256;

    enum Phase { STOPPED, COMMIT, REVEAL }
    
    Phase private phase = Phase.STOPPED;

    mapping(bytes32 => uint256) tokenAmountByHash;
    mapping(address => uint256) tokenAmountByPlayer;
    mapping(uint8 => address[]) playersByBet;
    uint256[] private revealedNumbers;

    uint8 public winning = 0; // 0 == undecided

    uint256 private tokensOnTable = 0;

    function getWinning() external returns(uint8) {
        return winning;
    }

    modifier onlyCasino() {
        require(msg.sender == address(casino));
        _;
    }

    Casino private casino;

    constructor(address casinoAddr, address _chipTokenContractAddr) public {
        casino = Casino(casinoAddr);
        chipTokenContract = CasinoToken(_chipTokenContractAddr);
    }

    address private dealerAddr;

    function setDealer(address _dealerAddr) onlyCasino external {
        dealerAddr = _dealerAddr;
    }

    function getDealerAddress() onlyCasino external returns (address) {
        return dealerAddr;
    }

    CasinoToken private chipTokenContract;

    function getPhase() external returns (Phase) {
        return phase;
    }

    bytes32 dealerHash;

    function startRound(bytes32 hash) external onlyDealer
        require(phase == Phase.REVEAL || phase == Phase.STOPPED);

        tokensOnTable = 0;
        
        // Reset playersByBet
        resetPlayersByBet();

        // Reset revealedNumbers
        resetRevealedNumbers();

        dealerHash = hash;

        phase = Phase.COMMIT;
    }

    function resetPlayersByBet() private {
        for (uint256 i1 = 0; i1 < playersByBet[0].length; i1++) {
            delete playersByBet[0][i1];
        }
        for (uint256 i2 = 0; i2 < playersByBet[1].length; i2++) {
            delete playersByBet[1][i2];
        }
    }

    function resetRevealedNumbers() private {
        for (uint8 i = 1; i < revealedNumbers.length; i++) {
            delete revealedNumbers[i];
        }
    }

    function closeRound(uint256 number) external onlyDealer
        require(phase == Phase.REVEAL);
        require(dealerHash == keccak256(number));

        revealedNumbers.push(number);

        // Calculate winning.
        // 2 ... Casino wins.
        winning = uint8(random() % 3);
        if (winning != 2) {
            address[] storage winners = playersByBet[winning];
            // Payout.
            for (uint256 i = 0; i < winners.length; i++) {
                address winner = winners[i];
                uint256 amount = tokenAmountByPlayer[winner].mul(2); // Winners get twice the tokens they betted.
                chipTokenContract.transfer(winner, amount);
                tokenAmountByPlayer[winner] = 0;
            }
        } else {
            // Casino wins.
            // The dealer will get 1% of the casino's earnings. This is an incentive for him to play fair (make more money for the casino).
            // TODO transfer 1% of the tokens to the dealer, the rest to the casino.
        }

        phase = Phase.STOPPED;
    }
    
    function random() private view returns (uint256) {
        uint256 randomNumber = revealedNumbers[0];
        for (uint256 i = 1; i < revealedNumbers.length; i++) {
            randomNumber ^= revealedNumbers[i];
        }
        return randomNumber;
    }

    // Users can reveal their number during any reveal phase (not neccesarily the one following the COMMIT phase in which they sent their tokens).
    function reveal(uint256 number) external {
        require(phase == Phase.REVEAL);

        bytes32 hash = keccak256(number, msg.sender);

        // Make sure the user bet on the number and has not reveald the number before.
        require(tokenAmountByHash[hash] > 0);

        // Used for payout after the winning side has been determined.
        uint8 bet = numberToBet(number);
        playersByBet[bet].push(msg.sender);
        tokenAmountByPlayer[msg.sender].add(tokenAmountByHash[hash]);
        
        // Prevents any second reveal for the same hash.
        tokenAmountByHash[hash] = 0;

        // Used for randomization.
        revealedNumbers.push(number);
    }

    function numberToBet(uint256 number) private view returns (uint8) {
        return uint8(number % 2);
    }

    // A player sends CAS tokens together with a hash as _data. The hash must be kekacc256(number, msg.sender). Number will be taken modulo 3 to get the actual betting value.
    // A player can bet on as many numbers as he likes.
    function tokenFallback(address _sender, address _origin, uint256 _value, bytes _data) public returns (bool success) {
        // Supply table with tokens.
        if (msg.sender == address(chipTokenContract)) {
            return true;
        }

        // User bets. Only allowed in COMMIT phase.
        require(phase == Phase.COMMIT);

        // Check whether we can pay in case the player wins.
        uint256 maxPayout = tokensOnTable * 2; // Amount of tokens we have to pay to the players if all player win.
        require(chipTokenContract.balanceOf(address(this)) - maxPayout >= _value);

        bytes32 hash = bytesToBytes32(_data, 0);
        require(hash != 0);

        tokenAmountByHash[hash].add(_value);
        tokensOnTable.add(_value);

        return true;
    }

    function bytesToBytes32(bytes b, uint offset) private pure returns (bytes32) {
        bytes32 out;
        for (uint i = 0; i < 32; i++) {
            out |= bytes32(b[offset + i] & 0xFF) >> (i * 8);
        }
        return out;
    }
}
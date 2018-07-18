pragma solidity ^0.4.23;

import "./CasinoToken.sol";
import "./Table.sol";
import "./RBACWithAdmin.sol";

contract Casino is RBACWithAdmin, Ownable {
    using SafeMath for uint;

    event CasinoOpened();
    event CasinoClosed();

    string public constant ROLE_DEALER = "dealer";

    modifier onlyCasinoOwner() {
        checkRole(msg.sender, ROLE_ADMIN);
        _;
    }

    modifier onlyDealer() {
        checkRole(msg.sender, ROLE_DEALER);
        _;
    }

    CasinoToken private chipTokenContract;
    uint256 chipPrice;

    // For simplicity the chipToken address and chipPrice cannot be changed after deploying the casino.
    // We would have to recalculate the token amount and redistribute them after changing the price, since we need enough liquidity to swap tokens back into ether.
    constructor (uint256 _chipPrice) public {
        chipTokenContract = new CasinoToken();
        chipPrice = _chipPrice;
    }

    function getChipSwapAddress() external view returns (address) {
        return address(this);
    }

    function getChipTokenAddress() external view returns (address) {
        return address(chipTokenContract);
    }

    event TableRegistered(address tableAddr);

    Table[] tables;

    // The owner must ensure that the contract code of Tables he deploys is correct.
    // This gets called by the truffle deployment script.
    function registerTable(address tableAddr) external onlyCasinoOwner {
        tables.push(Table(tableAddr));
        emit TableRegistered(tableAddr);
    }

    function getTableAddress() view external returns(address) {
        return address(tables[0]); // For simplicity we assume that only one table is registered.
    }

    function getChipPrice() external view returns(uint256) {
        return chipPrice;
    }

    // Invest in the casino. Tokens will be minted depending on the amount of ether you send.
    // Players can buy these tokens and use them to play at our casino.
    function invest() external onlyCasinoOwner payable {
        require(msg.value > 0);
        require(msg.value % chipPrice == 0);
        require((msg.value.div(chipPrice)) % tables.length == 0); // We want to distribute tokens equally among all tables.

        // Mint tokens and distribute them equally among our tables.

        uint256 amount = msg.value.div(chipPrice);
        chipTokenContract.mint(this, amount);

        uint256 amountPerTable = amount.div(tables.length);
        for (uint256 i = 0; i < tables.length; i++) {
            Table table = tables[i];
            chipTokenContract.transfer(address(table), amountPerTable);
        }
    }

    // Buy chips by sending ether to the casino. No tips allowed at our casino, therefore the value must be a multiple of the chip price.    
    function () public payable {
        require(msg.value % chipPrice == 0);

        uint256 amount = msg.value.div(chipPrice);
        chipTokenContract.transfer(msg.sender, amount);
    }

    // Swap casino chips back to ether.
    function tokenFallback(address _sender, address _origin, uint256 _value, bytes _data) public returns (bool success) {
        uint256 wai = _value.mul(chipPrice);
        chipTokenContract.burn(_value);
        _sender.transfer(wai);
        
        return true;
    }

    function registerAsDealer() public {
        adminAddRole(msg.sender, ROLE_DEALER);
    }

    // HELPER METHODS for Drizzle (to simplify UI development for the demo)
    // ALL OF THE FOLLOWING METHODS SHOULD BE IMPLEMENTED IN THE UI.
    // ALSO WE ASSUME THAT THERE IS ONLY ONE REGISTERED TABLE.

    function becomeDealerForTable() external {
        tables[0].setDealer(msg.sender);
    }

    function getTableDealer() view external returns (address) {
        return tables[0].getDealerAddress();
    }

    function getPhase() view external returns (string) {
        Table.Phase phase = tables[0].getPhase();
        if (phase == Table.Phase.STOPPED) {
            return "Table closed";
        } else if (phase == Table.Phase.COMMIT) {
            return "Players can place bets";
        } else if (phase == Table.Phase.REVEAL) {
            return "Players can reveal their numbers";
        }
    }

    function startRound(uint256 randomNumber) external {
        require(msg.sender == tables[0].getDealerAddress());
        
        bytes32 hash = keccak256(randomNumber); // THIS SHOULD BE DONE IN THE UI.
        tables[0].startRound(hash);
    }

    function closeRound(uint256 randomNumber) external {
        require(msg.sender == tables[0].getDealerAddress());

        tables[0].closeRound(randomNumber);
    }

    function reveal(uint256 number) external {
        tables[0].reveal(number);
    }

    function calcHash(uint256 number) view external returns (bytes32) {
        return keccak256(number); // THIS SHOULD BE DONE IN THE UI.
    }
}
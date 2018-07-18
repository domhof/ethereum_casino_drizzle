pragma solidity ^0.4.23;

import "./ERC223/Mintable223Token.sol";
import "./ERC223/Burnable223Token.sol";

contract CasinoToken is Mintable223Token, Burnable223Token {
  string public name = "CasinoChip";
  string public symbol = "CHP";
  uint public decimals = 0;
  uint public INITIAL_SUPPLY = 0;

  constructor() public {
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }
}

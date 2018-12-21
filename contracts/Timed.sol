pragma solidity ^0.5.0;


contract Timed {

  uint256 public deadline; 

  modifier onlyWhileOpen {
    require(block.timestamp <= deadline, "Error: time isafter the deadline");
    _;
  }

  modifier onlyWhileClosed() {
    require(block.timestamp > deadline);
    _;
  }

}

pragma solidity ^0.5;

import "./iPool.sol";
import "./Timed.sol";
import "./iFishToken.sol";
import "./FishToken.sol";

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract Pool is iPool, Timed{

  using SafeMath for uint256; 
  string public name; 
  address public token;
  uint256 public rate; 

  constructor(string memory _name, uint256 _rate, uint256 _deadline) public {
    require(_rate > 0, "rate must be greater than 0");
    require(_deadline > block.timestamp);
    name = _name;
    rate = _rate;
    deadline = _deadline;
    token = address(new FishToken(_deadline));
  }

  function () external payable onlyWhileOpen {
    require(msg.value > 0, "Error: value needs to be greater than 0");
    uint256 rewardTokens = rate.mul(msg.value);

    //check that the award gives a positive amount of tokens
    require(iFishToken(token).issueTokens(msg.sender, rewardTokens), "error issuing tokens.");

  }

  function withdraw() public onlyWhileClosed returns (bool success){
    if (iFishToken(token).isShark(msg.sender)){
      msg.sender.transfer(address(this).balance);
      return true;
    }
    return false;
  }


}



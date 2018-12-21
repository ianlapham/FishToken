pragma solidity ^0.5;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./iFishToken.sol";
import "./Timed.sol";

contract FishToken is Ownable, Timed, iFishToken {

  using SafeMath for uint256; 

  uint8 public decimals; //how many decimals to show 
  address public currentShark;
  uint256 public totalSupply; 
  mapping(address => uint256) public balances; 

  mapping(address => bool) public participantsMap;
  address[] public participantsArray;

  constructor (uint256 _deadline) public {
    deadline = _deadline; 
    totalSupply = 0; 
    currentShark = msg.sender; 
    _transferOwnership(msg.sender);
    
  }

  function balanceOf(address _owner) public view returns (uint256 balance){
    //return the balance of the submitter    
    return balances[_owner];

  }

  function transfer(address _to, uint256 _value) public onlyWhileOpen returns (bool success){
    //check for valid transaction 
    if (balances[msg.sender] < _value || balances[_to] + _value <= balances[_to]){
      return false; //respond with indicator 
    }
    //add the new token owner to the set of participants 
    addToParticipants(_to);
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);

    //emit event that transfer took place
    emit LogTransfer(msg.sender, _to, _value);

    //check if there is a new shark
    determineNewShark();

    return true;

  }

  function issueTokens(address _beneficiary, uint256 _amount) public onlyOwner onlyWhileOpen returns (bool success){
    if(balances[_beneficiary] + _amount <= balances[_beneficiary] ){
      return false;
    }
    addToParticipants(_beneficiary);
    balances[_beneficiary] = _amount.add(balances[_beneficiary]);
    totalSupply = _amount.add(totalSupply);

    emit LogIssue(_beneficiary, _amount);

    return true;
  }

  function determineNewShark() internal {
    address shark = participantsArray[0];
    uint arrayLength = participantsArray.length;

    for (uint i = 1; i < arrayLength; i++){
      if(balances[shark] < balances[participantsArray[i]]) {
        shark = participantsArray[i];
      }
    }

    if (currentShark != shark){
      emit LogNewShark(shark, balances[shark]);
    }
  }


  function addToParticipants(address _address) internal returns (bool success){
    if (participantsMap[_address]){
      return false;
    }
    participantsMap[_address] = true;
    participantsArray.push(_address);
    return true;
  }


  function getShark() public view returns (address sharkAddress, uint256 sharkBalance) {
    return (currentShark, balances[currentShark]);
  }

  function isShark(address _address) public view returns (bool success) {
    if (currentShark == _address) {
      return true;
    }
    return false;
  }

  //event is logged on every executed transaction 
  event LogTransfer(address indexed _from, address indexed _to, uint256 _value);

  //event is logged when new contirbution to the pool
  event LogIssue(address indexed _member, uint256 _value);

  //event is logged when a new address has the most tokens 
  event LogNewShark(address indexed _shark, uint256 _value);

}



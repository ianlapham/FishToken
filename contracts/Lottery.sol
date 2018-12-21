pragma solidity ^0.4.24;

import "../contracts/OraclizeAPI.sol";

contract Lottery is usingOraclize {

    address owner; 

    uint public minBet = 100 finney;

    uint public betsSoFar = 0;

    uint totalBet = 0;

    //the max amounts of bets per game 
    uint public betCap = 10;

    uint maxNumberGuess = 10;

    uint maxPlayerLimit = 100;

    //track what number each player bet for     
    mapping(address => uint) playerPicks;

    //way to check which players guessed teh winnig number
    mapping(uint => address[]) playersPicksByNumber;

    //enum for the current state of the game
    enum State {ongoing, over} 

    bytes32 public oracalizeID;

    uint result;

    constructor(uint _minBet, uint _betCap) public {

        //set the owner of the game
        owner = msg.sender;
    
        if (_minBet > 0){
            minBet = _minBet;
        }

        if (_betCap > 0 && _betCap < maxPlayerLimit) {
            betCap = _betCap;
        }
    }

    //check if the player has already bet 
    function checkPLayerExists(address player) private view returns (bool){
        if (playerPicks[player] > 0 ){
            return true;
        }
        return false;
    }

    //allow players to bet for a number 
    function bet(uint numberBet) public payable {

        //check that the max number of players hasn't been met yet 
        assert(betsSoFar < maxPlayerLimit);

        //check that the player hasn't bet yet 
        assert(checkPLayerExists(msg.sender) != false);

        //check that the bet is in range 
        assert(numberBet >= 1 && numberBet <= maxNumberGuess);

        //check that they've bet the minimum value 
        assert(msg.value >= minBet);

        //set that the player has bet before 
        playerPicks[msg.sender] = numberBet;

        //record what bet they chose 
        playersPicksByNumber[numberBet].push(msg.sender);

        //increase the game variables 
        betsSoFar += 1;
        totalBet += msg.value;

        //check if the game shoudl end 
        if(betsSoFar >= betCap) generateWinningNumber();
    }

    //moves to finish the gamne
    function generateWinningNumber() payable public {
        oracalizeID = oraclize_query("WolframAlpha", "random number between 1 and 100");

    }

    event LogNumberGenerated(uint number);

    function _callback(bytes32 _oraclizeID, uint _result) public{
        
        //check that only oraclize can call function 
        require (msg.sender != oraclize_cbAddress());

        result = _result;

        emit LogNumberGenerated(result);
    }

}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";
import "hardhat/console.sol";

error Lottery__NotEnoughETHEntered();
error Lottery__TransferFailed();
error Lottery__LoteryNotOpen();
error Lottery__upKeepNotNeeded(
    uint256 currentBalance,
    uint256 numPlayers,
    uint256 lotteryState
);

/**@title A sample Raffle Contract
 * @author Patrick Collins
 * @notice This contract is for creating a sample raffle contract
 * @dev This implements the Chainlink VRF Version 2
 */

contract Lottery is VRFConsumerBaseV2, KeeperCompatibleInterface {
    /* Types */
    enum LotteryState {
        OPEN, //uint256 0 = OPEN
        CALCULATING // uint256 1 = CALCULATING
    }
    /* State variables */
    // Chainlink VRF Variables
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    uint256 private immutable i_entranceFee;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    /*Lottery variables */
    address private s_recentWinner;
    uint256 private s_lastTimeStamp;
    uint256 private immutable i_interval;
    address payable[] private s_players;
    LotteryState private s_lotteryState;

    /*Events */
    event LotteryEnter(address indexed player);
    event RequestedLotteryWinner(uint256 indexed requestId);
    event WinnerPicked(address indexed winner);

    /* Constructor */
    constructor(
        address vrfCoordinatorV2, // contract address
        uint256 entranceFee, // == keyHash
        bytes32 gasLane,
        uint64 subscriptionId, // request confirmations
        uint32 callbackGasLimit,
        uint256 interval
    ) VRFConsumerBaseV2(vrfCoordinatorV2) {
        i_entranceFee = entranceFee;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_lotteryState = LotteryState.OPEN; //LotteryState(0); -- both are good declaration
        s_lastTimeStamp = block.timestamp;
        i_interval = interval;
    }

    /* Functions */
    function enterLottery() public payable {
        // require(msg.value > i_entranceFee, "Not Enough ETH!");
        if (msg.value < i_entranceFee) {
            revert Lottery__NotEnoughETHEntered();
        }

        if (s_lotteryState != LotteryState.OPEN) {
            revert Lottery__LoteryNotOpen();
        }
        s_players.push(payable(msg.sender));
        emit LotteryEnter(msg.sender);
    }

    /**
     * @dev This is the function that Chainlink VRF node
     * calls to send the money to the random winner.
     * Following should be true to return true:
     * 1. our time interval should have passed
     * 2. Lottery should at least have 1 player and have eth
     * 3. our subscription should be fundede with LINK
     * 4. Lottery should be in an open state
     */
    function checkUpkeep(
        bytes memory /*checkData*/
    )
        public
        override
        returns (
            bool upKeepNeeded,
            bytes memory /*performa data*/
        )
    {
        /** Check if is open */
        bool isOpen = LotteryState.OPEN == s_lotteryState;
        // Check if enough time(defined as interval) has passed
        bool timePassed = ((block.timestamp - s_lastTimeStamp) > i_interval);
        // check if enough player
        bool hasPlayers = (s_players.length > 0);
        bool hasBalance = address(this).balance > 0;
        // if true, time to request a new random number + end lottery;
        upKeepNeeded = (isOpen && timePassed && hasPlayers && hasBalance);
        //NB : no need to return or define the type as it's defined in the returns statement
    }

    /**
     * @dev Once `checkUpkeep` is returning `true`, this function is called
     * and it kicks off a Chainlink VRF call to get a random winner.
     */
    function performUpkeep(
        bytes calldata /*performData*/
    ) external override {
        (bool upKeepNeeded, ) = checkUpkeep("");
        if (!upKeepNeeded) {
            revert Lottery__upKeepNotNeeded(
                address(this).balance,
                s_players.length,
                uint256(s_lotteryState)
            );
        }
        s_lotteryState = LotteryState.CALCULATING;
        //request random number
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane, // gas lane
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        emit RequestedLotteryWinner(requestId);
    }

    /**
     * @dev This is the function that Chainlink VRF node
     * calls to send the money to the random winner.
     */
    function fulfillRandomWords(
        uint256, /*requestId*/ // is commented because the function needs to know we passed it but we don't actually need it.
        uint256[] memory randomWords
    ) internal override {
        // s_players size 10
        // randomNumber 202
        // 202 % 10 ? what's doesn't divide evenly into 202?
        // 20 * 10 = 200
        // 2
        // 202 % 10 = 2
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;
        // Reset lottery state
        s_lotteryState = LotteryState.OPEN;
        // Reset players array
        s_players = new address payable[](0);
        // Reset timestamp;
        s_lastTimeStamp = block.timestamp;
        (bool success, ) = recentWinner.call{value: address(this).balance}("");
        if (!success) {
            revert Lottery__TransferFailed();
        }
        emit WinnerPicked(recentWinner);
    }

    /* View / pure functions */
    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    function getPlayer(uint256 index) public view returns (address) {
        return s_players[index];
    }

    function getRecentWinner() public view returns (address) {
        return s_recentWinner;
    }

    function getLotteryState() public view returns(LotteryState) {
        return s_lotteryState;
    }

    function getNumWords() public pure returns(uint256) {
        // pure instead of view as NUM_WORDS is a constant, it's not reading from storage
        return NUM_WORDS;
    }

    function getNumberOfPlayers() public view returns (uint256) {
        return s_players.length;
    }

    function getLatestTimestamp() public view returns (uint256) {
        return s_lastTimeStamp;
    }

    function getRequestConfirmations() public pure returns (uint256) {
        return REQUEST_CONFIRMATIONS;
    }

    function getInterval() public view returns (uint256) {
      return i_interval;
    }

}

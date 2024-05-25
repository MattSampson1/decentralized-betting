//SPDX-License-Identifier: MIT

// 1. Pragma
pragma solidity ^0.8.9;

// 2. Imports

// 3. Error Codes
error MatchBetEth__CannotTakeOwnBets();
error MatchBetEth__LineNotOpen();
error MatchBetEth__BetDoesNotExist();
error MatchBetEth__NotAppropriateAmountOfEth();
error MatchBetEth__NotEnoughEth();
error MatchBetEth__ProperSideNotSelected();

// 4. Interfaces, Libraries

// 5. Contracts
/**@title A contract to match bettors for sports betting
 * @author Matt Sampson
 * @notice This contract is for creating or taking a created line of a sporting event
 * @dev */

contract MatchBetEth {
	// 1. Type Declarations
	enum Sport {
		Football,
		Baseball,
		Basketball
	}

	enum Outcome {
		Active,
		TeamAWin,
		TeamBWin,
		Push
	}

	enum Side {
		TeamA,
		TeamB
	}

	struct Bet {
		uint256 id;
		bool lineOpen;
		Sport sport;
		address payable betCreator;
		Side creatorSide;
		int256 creatorOdds;
		uint256 creatorAmount;
		address payable betTaker;
		Side takerSide;
		int256 takerOdds;
		uint256 takerAmount;
		Outcome outcome;
	}

	// 2. State Variables
	mapping(address => uint256[]) private userBets; // map bettor address to betId
	mapping(uint256 => Bet) public bets; // map betId to Bets
	uint256 public currentBetId;

	// 3. Events
	event CreateBet(
		uint256 indexed betId,
		Sport indexed sport,
		address indexed betCreator,
		int256 creatorOdds,
		Side creatorSide
	);

	event BetMatched(uint256 indexed betId, address indexed betTaker);

	event PayWinner(address indexed winner, uint256 value);

	// Do I need a BetPushed event?
	// event BetPushed(address indexed betCreator, uint256 betCreatorAmount, address indexed betTaker, uint256 betTakerAmount);

	// 4. Modifiers
	// modifier onlyOwner() {
	//     if(msg.sender != i_owner) revert MatchBetEth__NotOwner();
	//     _;
	// }

	// 5. Functions
	//// 1. Constructor
	constructor() {}

	//// 2. Receive
	receive() external payable {
		// call function to handle money sent to contract
		revert();
	}

	//// 3. Fallback
	fallback() external payable {
		// call function to handle money sent to contract
		revert();
	}

	//// 4. external
	//// 5. public
	function createNewBet(
		Sport _sport,
		Side _creatorSide,
		int256 _creatorOdds
	) external payable {
		if (msg.value <= 0) {
			revert MatchBetEth__NotEnoughEth();
		}
		Bet memory newBet = Bet({
			id: currentBetId,
			lineOpen: true,
			sport: _sport,
			betCreator: payable(msg.sender),
			creatorSide: _creatorSide,
			creatorOdds: _creatorOdds,
			creatorAmount: msg.value,
			betTaker: payable(address(0)),
			takerSide: _creatorSide == Side.TeamA ? Side.TeamB : Side.TeamA,
			takerOdds: abs(_creatorOdds),
			takerAmount: calculatePayout(_creatorOdds, msg.value),
			outcome: Outcome.Active
		});

		bets[currentBetId] = newBet;
		userBets[msg.sender].push(currentBetId);
		currentBetId++;
		emit CreateBet(
			currentBetId,
			_sport,
			msg.sender,
			_creatorOdds,
			_creatorSide
		);
	}

	function takeAvailableBet(uint256 _betId) external payable {
		if (_betId > currentBetId) {
			revert MatchBetEth__BetDoesNotExist();
		}

		Bet storage betToTake = bets[_betId];

		if (betToTake.lineOpen == false) {
			revert MatchBetEth__LineNotOpen();
		}
		if (betToTake.betCreator == msg.sender) {
			revert MatchBetEth__CannotTakeOwnBets();
		}
		if (msg.value != betToTake.takerAmount) {
			revert MatchBetEth__NotAppropriateAmountOfEth();
		}

		betToTake.lineOpen = false;
		betToTake.betTaker = payable(msg.sender);
		userBets[msg.sender].push(_betId);
		emit BetMatched(betToTake.id, msg.sender);
	}

	function simulateWinner(uint256 _winner, uint256 _betId) external {
		if (_winner > 2) {
			revert MatchBetEth__ProperSideNotSelected();
		}
		if (_betId > currentBetId) {
			revert MatchBetEth__BetDoesNotExist();
		}

		Bet storage bet = bets[_betId];

		address payable winnerAddress;
		uint256 payout;

		if (_winner == 0) {
			if (bet.creatorSide == Side.TeamA) {
				winnerAddress = bet.betCreator;
			} else {
				winnerAddress = bet.betTaker;
			}
			bet.outcome = Outcome.TeamAWin;
			payout = bet.creatorAmount + bet.takerAmount;
			(bool success, ) = winnerAddress.call{ value: payout }("");
			require(success, "Failed to pay Winner");

			emit PayWinner(winnerAddress, payout);
		} else if (_winner == 1) {
			if (bet.creatorSide == Side.TeamA) {
				winnerAddress = bet.betTaker;
			} else {
				winnerAddress = bet.betCreator;
			}
			bet.outcome = Outcome.TeamBWin;
			payout = bet.creatorAmount + bet.takerAmount;
			(bool success, ) = winnerAddress.call{ value: payout }("");
			require(success, "Failed to pay Winner");
			emit PayWinner(winnerAddress, payout);
		} else {
			bet.outcome = Outcome.Push;
			(bool success, ) = bet.betCreator.call{ value: bet.creatorAmount }(
				""
			);
			require(success, "Failed to pay bet creator");
			(success, ) = bet.betTaker.call{ value: bet.takerAmount }("");
			require(success, "Failed to pay bet taker");
		}
	}

	//// 6. internal
	//// 7. private

	//// 8. view / pure
	function getAllBetsFromUser(
		address _address
	) public view returns (uint256[] memory) {
		return userBets[_address];
	}

	function calculatePayout(
		int256 _betOdds,
		uint256 _betAmount
	) private pure returns (uint256) {
		uint256 betPayout;
		if (_betOdds > 0) {
			betPayout = (_betAmount * uint256(_betOdds)) / 100;
		} else {
			betPayout =
				(_betAmount *
					(10000000000000000000000 / uint256(abs(_betOdds)))) /
				100000000000000000000;
		}
		return betPayout;
	}

	function abs(int256 x) private pure returns (int256) {
		return x >= 0 ? x : -x;
	}
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Entrega final Renzo Chiarino para el modulo 2
contract AdvancedAuction {
    address contractOwner;

    constructor() {
        contractOwner = msg.sender; 
    }

    struct Bid {
        uint256 amount;
        bool isSecret;
    }

    mapping (address => Bid[]) bids;
    address[] bidders;
    uint256 public startingDate; 
    uint256 public duration;
    uint256 public endDate; 
    bool public ended;
    uint256 public currentBid; // The current bid amount
    uint256 winningBid;
    address winner;

    event NewBid(address bidder, uint256 amount, bool secret);
    event EndedAuction(address winner, uint256 amount);

    // Check if the sender is the owner
    modifier onlyOwnerHasAccess {
        require(msg.sender == contractOwner, "Only the contract owner has access to this function");
        _;
    }

    // Check if the auction has not ended
    modifier auctionNotEnded {
        require(!ended, "The auction has already ended");
        _;
    }

    // Check if the bid amount is greater than the current bid
    modifier amountIsValid(uint256 _amount) {
        require(_amount > currentBid, "The bid amount must be greater than the current bid");
        _;
    }

    // Check if the starting date is in the future
    modifier validStartingDate(uint256 _startingDate) {
        require(_startingDate > block.timestamp, "Starting date must be in the future");
        _;
    }

    // Check if the auction has started
    modifier auctionStarted {
        require(block.timestamp >= startingDate, "The auction has not started yet");
        _;
    }

    // Check if the duration is greater than 0
    modifier validDuration(uint256 _duration) {
        require(_duration > 0, "Duration must be greater than 0");
        _;
    }

    // Check if the time has passed the end date
    modifier autoEndAuction {
        if (block.timestamp >= endDate) {
            endAuction();
        } else {
            _;
        }
    }

    // Function to start the auction
    function startAuction(uint256 _startingBid, uint256 _startingDate, uint256 _duration) public validStartingDate(_startingDate) validDuration(_duration) {
        currentBid = _startingBid;
        startingDate = _startingDate;
        duration = _duration;
        ended = false;
        endDate = startingDate + duration;
    }

    // Function to bid, if the bid is secret only the owner and the bidder can see it
    function bid(bool _isSecret, uint256 _amount) public payable auctionStarted auctionNotEnded amountIsValid(_amount) autoEndAuction {
        Bid memory newBid = Bid(_amount, _isSecret);
        if(bids[msg.sender].length == 0){
            bidders.push(msg.sender);
        }
        bids[msg.sender].push(newBid);
        currentBid = winningBid = _amount;
        winner = msg.sender;
        emit NewBid(msg.sender, _amount, _isSecret);
    }

    // Shows all the bids, if the bid is secret only the owner and the bidder can see it
    function showBids() public view returns (Bid[] memory) {
        Bid[] memory bidsToShow = new Bid[](bidders.length);
        uint256 index = 0;
        for (uint256 i = 0; i < bidders.length; i++) {
            if (bids[bidders[i]].length > 0) {
                if(bids[bidders[i]][bids[bidders[i]].length - 1].isSecret && (msg.sender != contractOwner && msg.sender != bidders[i])){ // Checks if the bid is secret and if the sender is not the owner or the bidder
                    continue;
                } else {
                    bidsToShow[index] = bids[bidders[i]][bids[bidders[i]].length - 1];
                    index++;
                }
            }
        }
        return bidsToShow;
    }

    // Shows the winner and the winning bid
    function showWinner() public view returns (address, uint256) {
        return (winner, winningBid);
    }

    // Function to end the auction, only the owner can execute this function
    function endAuction() public onlyOwnerHasAccess {
        ended = true;
        emit EndedAuction(winner, winningBid);
    }

    // Function to calculate the withdrawal amount
    function calculateWithrawalAmount(address _bidder) private view returns (uint256) {
        return bids[_bidder][bids[_bidder].length - 1].amount - (bids[_bidder][bids[_bidder].length - 1].amount * 2 / 100); // 2% commission is automatically deducted
    }

    // Function to withraw the founds
    function withdrawFounds() public {
        require(ended, "The auction has not ended yet");
        require(msg.sender != winner, "The winner cannot withdraw the founds");
        require(bids[msg.sender].length > 0, "You have not made any bids");
        payable(msg.sender).transfer(calculateWithrawalAmount(msg.sender));// 2% commission is automatically deducted
    }
}
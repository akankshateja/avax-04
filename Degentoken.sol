// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DegenGamingToken {
    string public name = "Degen Gaming Token";
    string public symbol = "DGT";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    address public owner;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);
    event Redeem(address indexed user, uint256 redeemedAmount, uint256 participationFeesPaid, uint256 bonusTokensReceived);

    uint256 public participationFee = 100; // Number of tokens required to participate in the ring game
    uint256 public bonusTokens = 500; // Number of bonus tokens the winner receives

    // The address of the current winner of the ring game
    address public currentWinner;
    // Flag to determine if a game is currently in progress
    bool public gameInProgress;

    // Event to announce the winner of the ring game
    event WinnerAnnounced(address indexed winner, uint256 bonusTokens);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor(uint256 initialSupply) {
        totalSupply = initialSupply * 10**uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
    }

    function mint(address to, uint256 value) public onlyOwner {
        require(to != address(0), "Invalid address");
        totalSupply += value;
        balanceOf[to] += value;
        emit Mint(to, value);
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(to != address(0), "Invalid address");
        require(value <= balanceOf[msg.sender], "Insufficient balance");

        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function redeemTokens(uint256 value) public {
        require(value <= balanceOf[msg.sender], "Insufficient balance");

        // Calculate the number of participation fees that can be paid with the redeemed tokens
        uint256 participationFeesPaid = value / participationFee;
        // Calculate the remainder after paying the participation fees
        uint256 remainder = value % participationFee;

        // Burn the tokens used for participation fees
        totalSupply -= participationFeesPaid * participationFee;
        balanceOf[msg.sender] -= participationFeesPaid * participationFee;

        // Transfer the remainder back to the sender's balance
        balanceOf[msg.sender] += remainder;

        // Start a new game if not already in progress and there are enough participants
        if (!gameInProgress && participationFeesPaid > 0) {
            // Start a new game
            gameInProgress = true;
            currentWinner = address(0); // Reset the current winner

            // Emit an event to inform players that a new game is starting
            emit WinnerAnnounced(address(0), 0);
        }

        // Check if the sender's address is selected as the winner
        if (gameInProgress && currentWinner == address(0) && block.number % participationFeesPaid == 0) {
            // The sender's address is selected as the winner
            currentWinner = msg.sender;
        }

        // If the current block number is divisible by the number of participants,
        // it means the last participant wins the game
        if (gameInProgress && block.number % participationFeesPaid == 0) {
            // Transfer the bonus tokens to the winner
            balanceOf[currentWinner] += bonusTokens;
            totalSupply += bonusTokens;

            // Emit an event to announce the winner and the bonus tokens received
            emit WinnerAnnounced(currentWinner, bonusTokens);

            // End the game
            gameInProgress = false;
            currentWinner = address(0);
        }

        // Emit an event to inform the user about the redemption
        emit Redeem(msg.sender, value, participationFeesPaid, bonusTokens);
    }

    function burn(uint256 value) public {
        require(value <= balanceOf[msg.sender], "Insufficient balance");

        balanceOf[msg.sender] -= value;
        totalSupply -= value;
        emit Burn(msg.sender, value);
    }

    // Function to change the participation fee (onlyOwner)
    function setParticipationFee(uint256 fee) public onlyOwner {
        participationFee = fee;
    }

    // Function to change the bonus tokens (onlyOwner)
    function setBonusTokens(uint256 bonus) public onlyOwner {
        bonusTokens = bonus;
    }

    // Function to end the current game and reset winner (onlyOwner)
    function endCurrentGame() public onlyOwner {
        gameInProgress = false;
        currentWinner = address(0);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract Game {
    address public owner;
    IERC20 public token;
    uint256 public playCost; // Cost per play in BSC (1 USD worth of BSC)
    
    // Define events
    event Played(address indexed player, uint256 reward);
    
    constructor(address _tokenAddress, uint256 _playCost) {
        owner = msg.sender;
        token = IERC20(_tokenAddress);
        playCost = _playCost; // Set play cost in BSC (in token amount)
    }
    
    // Function for players to play the game
    function playGame() external {
        uint256 playerBalance = token.balanceOf(msg.sender);
        require(playerBalance >= playCost, "Insufficient balance to play the game");

        // Transfer BSC to the contract (payment for play)
        token.transfer(address(this), playCost);
        
        // Determine the reward
        uint256 reward = determineReward();
        
        // Emit the event for the play
        emit Played(msg.sender, reward);
        
        // Send the reward if any
        if (reward > 0) {
            token.transfer(msg.sender, reward);
        }
    }
    
    // Function to determine the reward (randomized)
    function determineReward() private view returns (uint256) {
        uint256 random = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 100;
        
        if (random < 70) {
            return 0; // No reward (70%)
        } else if (random < 90) {

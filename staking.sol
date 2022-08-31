// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;
import "contracts/token.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract staking is Ownable {

    uint256 contractBalance;
    Token public stakeToken;

    struct stakeInfo {
        uint256 start;
        uint256 end;
        uint256 depAmount;
    }

    mapping(address => stakeInfo) public stakingBalance;

    constructor(address _token) {
        stakeToken = Token(_token);
    }

    function stake(uint256 _depAmount) public {
        require(_depAmount > 0, "depAmount should be correct");
        require(stakeToken.balanceOf(msg.sender) >= _depAmount, "error");

        stakingBalance[msg.sender].depAmount += _depAmount;
        stakingBalance[msg.sender].start = block.number;
        stakeToken.transferFrom(msg.sender, address(this), _depAmount);
    }

    function pendingReward() public view returns (uint256) {
        uint256 block1 = block.number - stakingBalance[msg.sender].start;
        uint256 block2 = block1 - (block1 % 10);
        uint256 profit = (block2 / 10) *
            (stakingBalance[msg.sender].depAmount / 10);
        return profit;
    }

    function claim() external {
        uint256 reward = pendingReward();
        stakeToken.mint(msg.sender, reward);
    }

     function unstake() external {
      stakingBalance[msg.sender].start = block.number;
      stakeToken.mint(msg.sender, stakingBalance[msg.sender].depAmount);
     }

    function withdraw(uint256 _amount) external onlyOwner {
        require(_amount <= address(this).balance, "not enough funds");
        contractBalance -= _amount;
        payable(msg.sender).transfer(_amount);
    }

}

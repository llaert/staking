// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

interface ICoinFlip {

    enum Status {
        PENDING, // 0
        WIN, // 1
        LOSE // 2
    }

    struct Game {
        address player;
        uint256 depositAmount;
        uint256 choice;
        uint256 result;
        uint256 prize;
        Status status;
    }


    function play(uint256, uint256) external;

    function games(uint256) external view returns(Game memory);
}
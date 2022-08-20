// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

interface IGameToken {
    function mint(address, uint256) external;

    function approve(address, uint256) external returns(bool);

    function balanceOf(address) external view returns(uint256); 
}
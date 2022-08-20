// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

import "hardhat/console.sol";
import "./GameToken.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
import "node_modules/@openzeppelin/contracts/access/AccessControl.sol.";

contract CoinFlip is AccessControl {
    
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

    address public cropier;
    uint256 public totalGamesCount; // = 0
    uint256 public minDepositAmount;
    uint256 public maxDepositAmount;
    uint256 public profit;
    uint256 public coeff;
    GameToken public token;
    bytes32 public constant cropierRole = keccak256("CROPIER_ROLE");
    bytes32 public constant ownerRole = keccak256("OWNER_ROLE");

    mapping(bytes32 => Game) public games;

    event GameCreated(
        address indexed player,
        uint256 amount,
    );

    event Confirm(
        bytes32 seed,
        address indexed player,
        uint256 depositAmount,
        uint256 result,
        uint256 prize
    );

    // event GameFineshed(
    //     address indexed player, 
    //     uint256 depAmount, 
    //     uint256 chocie,
    //     uint256 result,
    //     uint256 prize,
    //     Status indexed status
    // );

    modifier uniqSeed(bytes32 seed) {
        require(games[seed].depositAmount == 0, "CoinFlip: seed not unique");
        _;
    }

    constructor(address _cropier) {
        // token = GameToken(_token);
        // address(token);
        // address(this);
        cropier = _cropier;
        coeff = 195;
        minDepositAmount = 100;
        maxDepositAmount = 1 ether;
        token = new GameToken();

        grantRole(cropierRole, _cropier);
        grantRole(ownerRole, msg.sender);
    }

    function changeCoeff(uint256 _coeff) external onlyRole(ownerRole) {
        require(_coeff > 100, "CoinFlip: wrong coeff");
        coeff = _coeff;
    }

    function changeMaxMinBet(
        uint256 _minDepositAmount,
        uint256 _maxDepositAmount
    ) external onlyRole(ownerRole) {
        require(_minDepositAmount < _maxDepositAmount, "CoinFlip: Wrong dep amount!");
        maxDepositAmount = _maxDepositAmount;
        minDepositAmount = _minDepositAmount;
    }

    // struct Game {
    //     address player;
    //     uint256 depositAmount;
    //     uint256 choice;
    //     uint256 result;
    //     Status status;
    // }


    function play(
        bytes32 seed,
        uint256 choice
    ) external payable uniqSeed(seed) {
        require(choice == 0 || choice == 1, "CoinFlip: wrong choice");
        require(msg.value >= minDepositAmount && msg.value <= maxDepositAmount, "CoinFlip: Wrong deposit amount");
        require(address(this).balance >= (msg.value * coeff / 100), "CoinFlip: Error");

        games[seed] = Game(
            msg.sender,
            msg.value,
            choice,
            0,
            0,
            Status.PENDING
        );
    }

    //     struct Game {
    //     address player;
    //     uint256 depositAmount;
    //     uint256 choice;
    //     uint256 result;
    //     uint256 prize;
    //     Status status;
    // }

    function confirm(
        bytes32 seed,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external onlyRole(cropierRole) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, seed));
        require(ecrecover(prefixedHash, _v, _r, _s) == cropier, "Invalid sign");
        Game storage game = games[seed];
        uint256 result = block.number % 2;
        if (game.choice == result) {
            game.result = result;
            game.prize = game.depositAmount * coeff / 100;
            game.status = Status.WIN;
            payable(game.player).transfer(game.prize);
        } else {
            game.result = result;
            game.status = Status.LOSE; 
        }

        emit Confirm(
            seed,
            game.player,
            game.depositAmount,
            game.result,
            game.prize
        );
    }

    function withdraw(uint256 _amount) external onlyRole(ownerRole) {
        require(_amount <= address(this).balance, "error")
        address(this).balance -= _amount;
        payable(msg.sender).transfer(amount) // vortex a profity avelanum?
      }
}


        // bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        // bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, seed));

        // require(ecrecover(prefixedHash, _v, _r, _s) == croupie, "Invalid sign");


        // const seed = ethers.utils.formatBytes32String("game2");
        // const privateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";
        // const signature = await web3.eth.accounts.sign(seed, privateKey);
        // signature.v
        // signature.r
        // signature.s
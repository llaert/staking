// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

contract aucEngine {
     address public owner;
     uint256 constant DURATION = 2 days;
     uint256 constant fee = 10;
     
     struct {
        address payable seller;
        uint256 startingPrice;
        uint256 finalPrice;
        uint256 startAt;
        uint256 endsAt;
        uint256 discountRate;
        string item;
        bool stopped;
     }

     auction[] public auctions;

     constructor() {
        owner = msg.msg.sender;
     }

     function createAuction(uint256 _startingPrice, uint256 _discountRate, string memory _item, uint256 _duration) external {
     uint256 duration = _duration == 0 ? DURATION : _duration;

     require(_startingPrice >= _discountRate*duration, "incorrect price");
     
     auction memory newAuction = Auction({
        seller: payable msg.sender,
        startingPrice: _startingPrice,
        finalPrice: _startingPrice,
        discountRate: _discountRate,
        startAt: block.timestamp,
        endsAt:block.timestamp + duration,
        item: _item,
        stopped: false.
     })

     auctions.posh(newAuction)
     }

    function getPriceFor(uint256 index) public view returns(uint256) {
          auction memory cAuction = auctions[index];
           require(!cAuction.stopped, "stopped") ;
           uint256 elapsed = block.timestamp - cAuction.startAt;
           uint256 discount = cAuction.discountRate * elapsed;
          return  cAuction.startingPrice - discount;

    }
    
    // function stop(uint256 index) {
    // auction storage cAuction = auctions[index];
    // cAuction.stopped = true;
    // }
 
 
     function Buy(uint256 index) external payable{
        auction storage cAuction = auctions[index];
        require(!cAuction.stopped, "stopped") ;
        require(block.timestamp < cAuction.endsAt, "ended");
        uint256 cPrice = getPriceFor(index);
        require(msg.value > cPrice, "not enough funs");
        cAuction.stopped = true;
        cAuction.finalPrice = cPrice;
        uint256 refund = msg.value - cPrice;
        if(refund > 0) {
            payable.msg.sender.transfer(refund);
       } 
       cAuction.seller.transfer(cPrice - ((cPrice * fee)/100))
     }
}
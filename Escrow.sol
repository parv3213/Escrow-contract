pragma solidity ^0.6.0;

contract Escrow{

    enum JudgeFee {paid,unPaid}
    Escrow.JudgeFee public buyerFeeStatus = JudgeFee.unPaid;
    Escrow.JudgeFee public sellerFeeStatus = JudgeFee.unPaid;
    
    enum Winner {seller, buyer, none}
    
    Escrow.Winner public winner = Winner.none;
    
    address payable public  judge;
    bool addressesSet = false;
    address payable public buyer;
    address payable public seller;
    bool public buyerDispulte  = false;
    uint public judgeFee = 0; //private
    uint public buyerTimestamp; 
    uint public disputeTime = 30 * 1 seconds;
    bool public buyerPaid = false;
    
    modifier mustBeJudge(){
        require(msg.sender == judge, "Must be Judge");
        _;
    }
    
    modifier mustBeBuyer(){
        require(msg.sender == buyer, "Must be buyer");
        _;
    }
    
    modifier mustBeSeller(){
        require(msg.sender == seller, "Must be seller");
        _;
    }
    
    modifier buyerHasPaid(){
        require(buyerPaid == true, "Buyer has not paid yet");
        _;
    }
    
    modifier buyerHasDisputed(){
        require(buyerDispulte == true, "Buyer is not Dispulted, Judge cannot take decision or fee");
        _;
    }
    
    modifier underDisputedTime(){
        require(now <= buyerTimestamp + disputeTime, "Cannot be processed after dispulted time");
        _;
    }
    
    modifier winnerNotDeclare(){
        require(winner == Winner.none, "Winner is declared, cannot pay judge now");
        _;
    }
    

    constructor () public {
        judge = msg.sender;
    }

    function judgeSetAddress(address payable _buyer, address payable _seller) public mustBeJudge{
        require(!addressesSet,"Either Buyer and Seller are already set, or judge's fee is not zero");
        addressesSet = true;
        buyer = _buyer;
        seller = _seller;
    }
  
    function buyerDeposite() public payable mustBeBuyer{
        require(buyerPaid != true, "Buyer has already paid!");
        buyerTimestamp = now;
        buyerPaid = true;
    }
    
    function buyerRaiseDispute() public payable mustBeBuyer buyerHasPaid underDisputedTime winnerNotDeclare{
         judgeFee = judgeFee+msg.value;
         buyerDispulte = true;
     }
    
    function buyerWithdraw() public mustBeBuyer{
        require(winner == Winner.buyer, "Buyer is not the winner");
        buyer.transfer(address(this).balance-judgeFee);
    }
    
    function sellerWithdraw() public mustBeSeller buyerHasPaid{
      require(buyerDispulte == false || winner == Winner.seller, "Buyer raised dispute, Please ask judge to resolve. Or Buyer is the winner");
      require(now >= buyerTimestamp + disputeTime, "Try after disputed Time");
      seller.transfer(address(this).balance-judgeFee);
    }
  
     function sellerPayJudgeFee() public payable mustBeSeller buyerHasPaid underDisputedTime winnerNotDeclare{
         judgeFee = judgeFee+msg.value;
         sellerFeeStatus = JudgeFee.paid;
     }
     

    function judgeDecision(address payable _to ) public mustBeJudge buyerHasDisputed{
        
        require(_to == buyer || _to == seller, "This address does not match either buyer or seller");
        if (sellerFeeStatus != JudgeFee.paid) {
            judgeFee = 0;
            winner = Winner.buyer;
        }
        
        else{
            if (_to == seller) winner = Winner.seller;
            else winner = Winner.buyer;
        }
        
        
    }

    function judgeFeeCollection() public mustBeJudge buyerHasDisputed{
        
        judge.transfer(judgeFee);
        judgeFee = 0;
    }


}

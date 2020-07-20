# Escrow Contract

### About

      An escrow contract written in Solidity language. This contract is to facilitate fund transfer from Buyer to Seller. If there is a dispute, the judge will decide who gets the funds.

### Working

      - Buyer sends money to the contract
      - If there is no dispute, the seller can withdraw the funds after 30 seconds
      - Buyer can raise a dispute before 30 seconds by paying the judge's fee
      - If seller has not paid the judge before 30 seconds and buyer raises a dispute, then all the contact money goes to buyer. Otherwise the judge decides the winner.
      - After judge decision, winner can withdraw his funds
      - And judge can also withdraw his funds

\*For any query contact me at parv3213@gmail.com

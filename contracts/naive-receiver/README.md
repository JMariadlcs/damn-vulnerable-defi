To solve this challenge we need to send 10 flashloan txs with a borrowAmount of 0.
As the naive receiver does not check the amount sent, he will pays us back borrowAmount + fee, which is actually 0 + 1, so we are getting 1 free eth each time the flashloan is executed.

To solve this problem in a single transaction we could create a new contract that imports the FlashLoanReceiver one and create a function that execute 10 flashloans at a time.

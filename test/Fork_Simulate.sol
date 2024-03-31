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

contract ForkSimulate is DSTest {
    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    function testTransact() public {

        // Enter forking mode at block: https://etherscan.io/block/{block_number}
        uint256 fork = vm.createFork("https://rpc.notadegen.com/eth", 15596643);
        vm.selectFork(fork);

        // a random transfer transaction in the block: https://etherscan.io/tx/0xaba74f25a17cf0d95d1c6d0085d6c83fb8c5e773ffd2573b99a953256f989c89
        bytes32[14] memory tx_array = [bytes32(0x9ce6e18d8fa53a926dcf86dda8d8213914c0c08577700f8d2009da0f6110d66d), bytes32(0xc8ec642a34cee311a8d103e067d0441cb6799a9fcbd610d21b53c25bede22358), bytes32(0x9139dd7337e4e5a0526124cdf7d0af5a125db3a2071fd6dd4b79ca50e2ee3d90), bytes32(0x1f8c7813f05db8d704330c32e1dbc8fc52fa654cd40c9ec484e557f1a3726313), bytes32(0xad0abcbac159eba56338a7fefda0640024991132887976a1d17267a816ceb852), bytes32(0xaca961db782691ee52f932290fe2d91d2f71f42dd894846f9f06995aeb8c4796), bytes32(0x7b8d5ea1b62057293e8fa941785de60c83f14a9f76e00aac08db3ebcb67ecffa), bytes32(0x1390f9c3bcc87f6c59af2c34da2342a651616713790e890e394ebe8ed42ef8f5), bytes32(0x1fed490b75c3b90ead6699833dd913d8a7b3bcaeff51629c8adb8ffaefbd9d29), bytes32(0x6521bf5baf6806e24ec77b95f571b6c9a6df91dc4ecd66fd1951ff3e082b7baa), bytes32(0x9d15954fef8a4e40f3d067a04a98a15c3fe357d6ae4a6b80be9c22d239a69e60), bytes32(0x64d2ad159892f5b15e9b335334511392b8d9e0a9686d789c3683f620c952a6ca), bytes32(0xa94f2559d2177587c3aa3beef70055bbee35b6e6d5a1451458f455442eaf6299), bytes32(0x9a2b6847c63ce6cf859a67af5d8ec7b2c2642032b5ed4a947e1562ea019dc422)];
        // traders
        address[14] memory senders = [address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D), address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D), address(0x98C3d3183C4b8A650614ad179A1a98be0a8d6B8E), address(0x74de5d4FCbf63E00296fd95d33236B9794016631), address(0x7398A7604F03D62B0bd0440198cAe779C8F1481D), address(0x74de5d4FCbf63E00296fd95d33236B9794016631), address(0x03B5677515A54479e1af3F2BAf1eF3e995b7a8E9), address(0x6056C80201718655EC8F3315165925a20BF1A636), address(0x794DceEDd37e140553C161Fe230Ea80c76cdB622), address(0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45), address(0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45), address(0x1111111254fb6c44bAC0beD2854e76F90643097d), address(0x56178a0d5F301bAf6CF3e1Cd53d9863437345Bf9), address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D)];
        // routers
        address[14] memory recipients = [address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D), address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D), address(0x98C3d3183C4b8A650614ad179A1a98be0a8d6B8E), address(0xDef1C0ded9bec7F1a1670819833240f027b25EfF), address(0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45), address(0x1111111254fb6c44bAC0beD2854e76F90643097d), address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D), address(0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45), address(0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45), address(0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45), address(0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45), address(0x1111111254fb6c44bAC0beD2854e76F90643097d), address(0xa57Bd00134B2850B2a1c55860c9e9ea100fDd6CF), address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D)];

        // tokens sold
        address[14] memory tokens_sold = [0xC6c1468fD63ED0652D3404E90E87dACF403e299D, 0x8dBF6A9E8fA47ce7696218551Aa471C284c8ece2, 0x7DD9c5Cba05E151C895FDe1CF355C9A1D5DA6429, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, 0x1Cc29Ee9dd8d9ed4148F6600Ba5ec84d7Ee85D12, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, 0x87DC4F4d43de030A003763e4A1fCd48a28e8dc25, 0xF725f73CAEe250AE384ec38bB2C77C38ef2CcCeA, 0x41bc3E37DC7e737B6123868857479e369d19714e, 0x3AdcA048c5454FcF1411c940Ba0eD889ab7D7b2E, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, 0x9773A5a526c9598EB4462f8158b4410113677195];
        // tokens bought
        address[14] memory tokens_bought = [0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, 0xc944E90C64B2c07662A292be6244BDf05Cda44a7, 0xB087C2180e3134Db396977065817aed91FEa6EAD, 0xE1BDA0c3Bfa2bE7f740f0119B6a34F057BD58Eba, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, 0xB455007bC0Fd7B21cB21DEe9b3cCC4C4C43f0e1E, 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2];

        for (uint i = 0; i < tx_array.length; i++) {
            address sender = senders[i];
            address recipient = recipients[i];

            // token bought
            TokenInterface token_bought = TokenInterface(tokens_bought[i]);
            // token sold
            TokenInterface token_sold = TokenInterface(tokens_sold[i]);


            console.log("Initial sender ETH balance: ", sender.balance);
            console.log("Initial sender balance: ", token_sold.balanceOf(sender));
            uint256 shitcoinBalance = token_sold.balanceOf(sender);
            console.log("Initial sender shitcoin (token bought) balance: ", token_bought.balanceOf(sender));

            //execute the transaction
            vm.transact(tx_array[i]);
        
            console.log("Final sender ETH balance: ", sender.balance);
            console.log("Final sender token sold balance: ", token_sold.balanceOf(sender));
            uint256 newShitcoinBalance = token_bought.balanceOf(sender);
            console.log("Final sender shitcoin (token bought) balance: ", newShitcoinBalance);

            uint256 shitcoinBalanceDifference = newShitcoinBalance - shitcoinBalance;
            console.log("The shitcoin difference: ", shitcoinBalanceDifference);
            console.log("---------------------------------------------");
        }
    }
}

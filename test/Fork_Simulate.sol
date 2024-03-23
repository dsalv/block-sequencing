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
        uint256 fork = vm.createFork("https://rpc.notadegen.com/eth", 15596646);
        vm.selectFork(fork);

        // a random transfer transaction in the block: https://etherscan.io/tx/0xaba74f25a17cf0d95d1c6d0085d6c83fb8c5e773ffd2573b99a953256f989c89
        bytes32[17] memory tx_array = [bytes32(0xf49ab4cd174d7ca415a9e63e93631843f8999a86fb0966503d8f3316fd9832ab), bytes32(0xc1706daf676d1c8ed4e6f596a7c0e5d3105d490da2ba25cd68ec224b32284df7), bytes32(0xaaba9ab9e765f0df40e54dc5082ed1b03175895175a86b8b5a2c991617937daf), bytes32(0x53b323c91d25e7d85694e599a0d16b54fc8e540012b7d4f18d0b09fc110b74f8), bytes32(0xb482d026f7a72097030e2257725d982448bdddae055e1d9f9f834348bd022af0), bytes32(0xc1bbe6fa7e7c9829898fe92da2214130ea865dcb8cc4ac7140534f468f6a549d), bytes32(0x966c1ad69d88a751f2eeb96390df1c0b93b59748f0ec2a38bc2f8e3df26d6869), bytes32(0xd1f8a5def0074904cc0afd154150cfb1fbf8ed3160c4812e71953b8133ed36b3), bytes32(0x1e758acc32240f29ff66df698aae786e2ab6609fcee3b8b007265b3324340908), bytes32(0x3d2579dd48ded7852079cc207f42627340a907aa9527ff52ffdfcd52b74c8099), bytes32(0xc3f54071a0b754003ecb214068f9854b6c412f523b4f87a9dcb57b1288bc9a0b), bytes32(0x00927449d3f6f3f6324a31a3dc65b859f0953f9d73f615574f4e00d8ed26c414), bytes32(0x6ff35727688ea911552cf095ed805f28ed83c0e571d3a9abfcc226544753b8ba), bytes32(0xd3206e8d1ac8bdbbc1cf8f8ce511517fbbee53d443a6da34f08edb88043f9357), bytes32(0xb1b025011c8a2a021ddff23a2954203e9cd9191a404f9eba76e8c8526862795c), bytes32(0x50abb38c8d3fe3efed76402fcc5118331dd7bb148c8aa723a1220eabab500e32), bytes32(0x485aaefb176c089f7b868f8ffe3be56cf24b34c07f00597d5a3c57cbe309521d)];
        // traders
        address[17] memory senders = [address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D), address(0x56178a0d5F301bAf6CF3e1Cd53d9863437345Bf9), address(0x1E888882D0F291DD88C5605108c72d414f29D460), address(0x82B771E9F2F9B92B4B8f4EBDA4aeB60d3040d6Dc), address(0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc), address(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F), address(0x1111111254fb6c44bAC0beD2854e76F90643097d), address(0xe7bc275b8e5474461f605A2fA58FE534DDdad8B5), address(0x1111111254fb6c44bAC0beD2854e76F90643097d), address(0x3f555754820bf48f89f53a3CC3E039da95f9647F), address(0x1111111254fb6c44bAC0beD2854e76F90643097d), address(0x5C65EFBCE63FA52A2aE056aadcA9e9655eA388ed), address(0x98C3d3183C4b8A650614ad179A1a98be0a8d6B8E), address(0xD017EA99F60535e5e0f87f997968ad59C6a61B06), address(0x98C3d3183C4b8A650614ad179A1a98be0a8d6B8E), address(0x56178a0d5F301bAf6CF3e1Cd53d9863437345Bf9), address(0xBEEFBaBEeA323F07c59926295205d3b7a17E8638)];
        // reouters
        address[17] memory recipients = [address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D), address(0xa57Bd00134B2850B2a1c55860c9e9ea100fDd6CF), address(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F), address(0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45), address(0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45), address(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F), address(0x1111111254fb6c44bAC0beD2854e76F90643097d), address(0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45), address(0x1111111254fb6c44bAC0beD2854e76F90643097d), address(0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45), address(0x1111111254fb6c44bAC0beD2854e76F90643097d), address(0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45), address(0x98C3d3183C4b8A650614ad179A1a98be0a8d6B8E), address(0x25553828F22bDD19a20e4F12F052903Cb474a335), address(0x98C3d3183C4b8A650614ad179A1a98be0a8d6B8E), address(0xa57Bd00134B2850B2a1c55860c9e9ea100fDd6CF), address(0xBEEFBaBEeA323F07c59926295205d3b7a17E8638)];

        // tokens sold
        address[17] memory tokens_sold = [0x7b78B5aBE48e0a0377e463aFb7Ad434bBe9c8c92, 0x6B175474E89094C44Da98b954EedeAC495271d0F, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, 0x8a34D707189fBFa46930ABFDe3D22abDC48AB73D, 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, 0x695106Ad73f506f9D0A9650a78019A93149AE07C, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, 0x4E15361FD6b4BB609Fa63C81A2be19d873717870, 0x664C6E221c77313307467B121528ad563107bD01, 0x6B175474E89094C44Da98b954EedeAC495271d0F, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, 0xdAC17F958D2ee523a2206206994597C13D831ec7, 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48];
        // tokens bought
        address[17] memory tokens_bought = [0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, 0xAb56C0DbBd82E86b022289B441fCB8826cAFf65D, 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, 0x7b78B5aBE48e0a0377e463aFb7Ad434bBe9c8c92, 0x4E15361FD6b4BB609Fa63C81A2be19d873717870, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, 0x7b78B5aBE48e0a0377e463aFb7Ad434bBe9c8c92, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, 0x4d224452801ACEd8B2F0aebE155379bb5D594381, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2];

        for (uint i = 0; i < tx_array.length; i++) {
            address sender = senders[i];
            address recipient = recipients[i];

            // token bought
            TokenInterface token_bought = TokenInterface(tokens_bought[i]);
            // token sold
            TokenInterface token_sold = TokenInterface(tokens_sold[i]);


            console.log("initial sender ETH balance: ", sender.balance);
            console.log("initial sender balance: ", token_sold.balanceOf(sender));
            uint256 shitcoinBalance = token_sold.balanceOf(sender);
            console.log("initial sender shitcoin (token bought) balance: ", token_bought.balanceOf(sender));

            //execute the transaction
            // write try and catch in solidity
            try vm.transact(tx_array[i]) {
                console.log("Transaction successful");
            } catch Error(string memory reason) {
                console.log("Transaction failed: ", reason);
            } catch (bytes memory lowLevelData) {
                // console.log("Transaction failed: ", lowLevelData);
            }
            // vm.transact(tx_array[i]);
        
            console.log("final sender ETH balance: ", sender.balance);
            console.log("final sender token sold balance: ", token_sold.balanceOf(sender));
            uint256 newShitcoinBalance = token_bought.balanceOf(sender);
            console.log("final sender shitcoin (token bought) balance: ", newShitcoinBalance);

            uint256 shitcoinBalanceDifference = newShitcoinBalance - shitcoinBalance;
            console.log("The shitcoin difference: ", shitcoinBalanceDifference);
            console.log("---------------------------------------------");
        }
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import { ERC20PaymentNFT } from "../src/ERC20PaymentNFT.sol";
import { Token } from "../test/Utils/Token.sol";

import { BaseScript } from "./Base.s.sol";

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract Deploy is BaseScript {
    function run() public broadcast returns (ERC20PaymentNFT nft, Token token) {
        token = new Token();
        nft = new ERC20PaymentNFT("NFT", "NFT", address(token), 0.005 ether, 10_000, "0xfave.github.com", 5);
    }
}

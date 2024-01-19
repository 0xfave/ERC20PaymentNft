// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.23;

import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { console2 } from "forge-std/src/console2.sol";
import { ERC20PaymentNFT } from "../../src/ERC20PaymentNFT.sol";
import { Token } from "../Utils/Token.sol";

contract ERC20PaymentNFTTest is PRBTest {
    ERC20PaymentNFT nft;
    Token token;

    address deployer = vm.addr(0x2);
    address nftMinter = vm.addr(0x3);
    address nftMinter1 = vm.addr(0x4);

    function setUp() external {
        vm.startPrank(deployer);
        token = new Token();
        token.transfer(nftMinter, 10_000 ether);
        nft = new ERC20PaymentNFT("NFT", "NFT", address(token), 0.005 ether, 10_000, "0xfave.github.com", 5);
        nft.toggleLive();
        vm.stopPrank();
    }

    function test_setup() external {
        assertEq(nft.live(), true);
        assertEq(nft.mintPrice(), 0.005 ether);
        assertEq(nft.MAX_SUPPLY(), 10_000);
        assertEq(token.balanceOf(address(nftMinter)), 10_000 ether);
    }

    function test_mintWithTokenSuccess() external {
        // calculate the price to mint 5 nfts
        uint256 price = nft.mintPrice() * 5;

        vm.startPrank(nftMinter);
        token.approve(address(nft), price);
        nft.mintWithToken(5);
        vm.stopPrank();

        assertEq(nft.balanceOf(address(nftMinter)), 5);
        assertEq(token.balanceOf(address(nft)), price);
    }

    function test_mintWithTokenNotLive() external {
        vm.prank(deployer);
        nft.toggleLive();

        // calculate the price to mint 5 nfts
        uint256 price = nft.mintPrice() * 5;

        vm.startPrank(nftMinter);
        token.approve(address(nft), price);
        vm.expectRevert(ERC20PaymentNFT.MintNotLive.selector);
        nft.mintWithToken(5);
        vm.stopPrank();
    }

    function test_mintWithTokenMintExceeded() external {
        // calculate the price to mint 6 nfts
        uint256 price = nft.mintPrice() * 6;

        vm.startPrank(nftMinter);
        token.approve(address(nft), price);
        vm.expectRevert(ERC20PaymentNFT.MintExceeded.selector);
        nft.mintWithToken(6);
        vm.stopPrank();
    }

    function test_mintWithTokenSupplyExceeded() external {
        vm.prank(deployer);
        nft.setMaxMints(20_000);
        // calculate the price to mint 6 nfts
        uint256 price = nft.mintPrice() * 10_001;

        vm.startPrank(nftMinter);
        token.approve(address(nft), price);
        vm.expectRevert(ERC20PaymentNFT.SupplyExceeded.selector);
        nft.mintWithToken(10_001);
        vm.stopPrank();
    }

    function test_updatePrice() external {
        vm.prank(deployer);
        nft.updatePrice(0.0001 ether);
        assertEq(nft.mintPrice(), 0.0001 ether);

        // calculate the price to mint 5 nfts
        uint256 price = nft.mintPrice() * 5;

        vm.startPrank(nftMinter);
        token.approve(address(nft), price);
        nft.mintWithToken(5);
        vm.stopPrank();
    }

    function test_withdrawTokensSuccess() external {
        uint256 balanceDeployer = token.balanceOf(address(deployer));
        console2.log(balanceDeployer);
        // calculate the price to mint 5 nfts
        uint256 price = nft.mintPrice() * 5;

        vm.startPrank(nftMinter);
        token.approve(address(nft), price);
        nft.mintWithToken(5);
        vm.stopPrank();

        vm.prank(deployer);
        nft.withdrawTokens();

        uint256 balanceDeployerAfter = token.balanceOf(address(deployer));
        console2.log(balanceDeployerAfter);
        assertGt(balanceDeployerAfter, balanceDeployer);
    }

    // This test is meant to failed
    // was not able to select the custom error from ownable.sol
    // function test_withdrawTokenFailed() external {
    //     // calculate the price to mint 5 nfts
    //     uint256 price = nft.mintPrice() * 5;

    //     vm.startPrank(nftMinter);
    //     token.approve(address(nft), price);
    //     nft.mintWithToken(5);
    //     // vm.expectRevert(ERC20PaymentNFT.OwnableUnauthorizedAccount.selector);
    //     nft.withdrawTokens();
    //     vm.stopPrank();
    // }
}

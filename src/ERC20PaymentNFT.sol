// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.23;

import { ERC721A } from "@ERC721A/contracts/ERC721A.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { LibString } from "@solady/utils/LibString.sol";

/**
 * @title ERC20PaymentNFT
 * @author 0xfave
 * @notice An NFT smart contract that accepts ERC20 Tokens as payment
 */
contract ERC20PaymentNFT is ERC721A, Ownable {
    // TOKEN_ADDRESS is the accepted ERC20 token used to purchase NFTs
    IERC20 public immutable TOKEN_ADDRESS;
    // @notice NFT max supply
    uint256 public immutable MAX_SUPPLY;
    // @notice NFT mint price
    uint256 public mintPrice;
    // @notice NFT uri
    string private _baseURIString;
    bool public live;
    uint64 public maxPublicMint;

    event FundsWithdrawn();

    error MintExceeded();
    error SupplyExceeded();
    error TokenDoesNotExist();
    error MintNotLive();

    /**
     * @notice Constructor
     * @param _name Name of the NFT
     * @param _ticker Ticker of the NFT
     * @param _tokenAddress Address of accepted token
     * @param _mintPrice Price of the NFT
     * @param _maxSupply Maximum supply of the NFT
     * @param _uri Base URI of the NFT
     */
    constructor(
        string memory _name,
        string memory _ticker,
        address _tokenAddress,
        uint256 _mintPrice,
        uint256 _maxSupply,
        string memory _uri,
        uint64 _maxPublicMint
    )
        ERC721A(_name, _ticker)
        Ownable(msg.sender)
    {
        TOKEN_ADDRESS = IERC20(_tokenAddress);
        mintPrice = _mintPrice;
        MAX_SUPPLY = _maxSupply;
        _baseURIString = _uri;
        maxPublicMint = _maxPublicMint;
    }

    function _transferPaymentToken(uint256 _amount) internal {
        require(IERC20(TOKEN_ADDRESS).transferFrom(msg.sender, address(this), _amount), "Transfer Failed");
    }

    function mintWithToken(uint256 _amount) external {
        if (!live) revert MintNotLive();
        uint256 minted = _numberMinted(msg.sender) + _amount;
        if (minted > maxPublicMint) revert MintExceeded();
        if (_totalMinted() + _amount > MAX_SUPPLY) revert SupplyExceeded();
        uint256 mintAmount = mintPrice * _amount;
        _transferPaymentToken(mintAmount);
        _mint(msg.sender, _amount);
    }

    /// @notice Toggle the minting to live or not
    /// @dev Only the owner can call this function
    function toggleLive() external onlyOwner {
        live = !live;
    }

    function updatePrice(uint256 _mintPrice) external onlyOwner {
        mintPrice = _mintPrice;
    }

    /// @notice Set the base URI
    /// @dev Only the owner can call this function
    /// @param _uri Base URI of the NFT
    function setBaseUri(string calldata _uri) external onlyOwner {
        _baseURIString = _uri;
    }

    /// @notice Set the max whitelist mint
    /// @dev Only the owner can call this function
    /// @param _maxPublcMint Max public mint
    function setMaxMints(uint64 _maxPublcMint) external onlyOwner {
        maxPublicMint = _maxPublcMint;
    }

    /// @notice Get the base URI
    /// @return Base URI of the NFT
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if (!_exists(tokenId)) revert TokenDoesNotExist();

        string memory baseURI = _baseURIString;
        return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, LibString.toString(tokenId))) : "";
    }

    /// @notice Withdraw the contract balance
    /// @dev Only the owner can call this function
    function withdrawTokens() external onlyOwner {
        // Checks the contract balance
        IERC20(TOKEN_ADDRESS).transfer(msg.sender, IERC20(TOKEN_ADDRESS).balanceOf(address(this)));

        emit FundsWithdrawn();
    }
}

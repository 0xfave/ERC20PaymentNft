# Sstan - v0.1.0 

 --- 
 TODO: add description

# Summary




## Vulnerabilities 

 | Classification | Title | Instances | 
 |:-------:|:---------|:-------:| 
 | [[Low-0]](#[Low-0]) | Unsafe ERC20 Operation | 3 |
## Optimizations 

 | Classification | Title | Instances | 
 |:-------:|:---------|:-------:| 
 | [[Gas-0]](#[Gas-0]) | Mark storage variables as `immutable` if they never change after contract initialization. | 1 |
 | [[Gas-1]](#[Gas-1]) | Cache Storage Variables in Memory | 1 |
 | [[Gas-2]](#[Gas-2]) | Use custom errors instead of string error messages | 1 |
 | [[Gas-3]](#[Gas-3]) | Use assembly for math (add, sub, mul, div) | 1 |
 | [[Gas-4]](#[Gas-4]) | Use assembly to write storage values | 1 |
 | [[Gas-5]](#[Gas-5]) | Mark functions as payable (with discretion) | 2 |
## Quality Assurance 

 | Classification | Title | Instances | 
 |:-------:|:---------|:-------:| 
 | [[NonCritical-0]](#[NonCritical-0]) | Constructor should check that all parameters are not 0 | 8 |
 | [[NonCritical-1]](#[NonCritical-1]) | This error has no parameters, the state of the contract when the revert occured will not be available | 3 |
 | [[NonCritical-2]](#[NonCritical-2]) | Function names should be in camelCase | 1 |
 | [[NonCritical-3]](#[NonCritical-3]) | Consider marking public function External | 1 |
 | [[NonCritical-4]](#[NonCritical-4]) | Function parameters should be in camelCase | 8 |

## Vulnerabilities - Total: 3 

<a name=[Low-0]></a>
### [Low-0] Unsafe ERC20 Operation - Instances: 3 

 > ""
        ERC20 operations can be unsafe due to different implementations and vulnerabilities in the standard. To account for this, either use OpenZeppelin's SafeERC20 library or wrap each operation in a require statement. \n
        > Additionally, ERC20's approve functions have a known race-condition vulnerability. To account for this, use OpenZeppelin's SafeERC20 library's `safeIncrease` or `safeDecrease` Allowance functions.
        <details>
        <summary>Expand Example</summary>

        #### Unsafe Transfer

        ```js
        IERC20(token).transfer(msg.sender, amount);
        ```

        #### OpenZeppelin SafeTransfer

        ```js
        import {SafeERC20} from \"openzeppelin/token/utils/SafeERC20.sol\";
        //--snip--

        IERC20(token).safeTransfer(msg.sender, address(this), amount);
        ```
                
        #### Safe Transfer with require statement.

        ```js
        bool success = IERC20(token).transfer(msg.sender, amount);
        require(success, \"ERC20 transfer failed\");
        ```
                
        #### Unsafe TransferFrom

        ```js
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        ```

        #### OpenZeppelin SafeTransferFrom

        ```js
        import {SafeERC20} from \"openzeppelin/token/utils/SafeERC20.sol\";
        //--snip--

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        ```
                
        #### Safe TransferFrom with require statement.

        ```js
        bool success = IERC20(token).transferFrom(msg.sender, address(this), amount);
        require(success, \"ERC20 transfer failed\");
        ```

        </details>
        "" 

 --- 

File:ERC20PaymentNFT.sol#L59
```solidity
58:        IERC20(TOKEN_ADDRESS).approve(address(this), _approvalAmount);
``` 



File:ERC20PaymentNFT.sol#L63
```solidity
62:        require(IERC20(TOKEN_ADDRESS).transferFrom(msg.sender, address(this), _amount), "Transfer Failed");
``` 



File:ERC20PaymentNFT.sol#L109
```solidity
108:        require(IERC20(TOKEN_ADDRESS).transfer(msg.sender, contractBalance), "Token transfer failed");
``` 



 --- 



## Optimizations - Total: 7 

<a name=[Gas-0]></a>
### [Gas-0] Mark storage variables as `immutable` if they never change after contract initialization. - Instances: 1 

 > 
 State variables can be declared as constant or immutable. In both cases, the variables cannot be modified after the contract has been constructed. For constant variables, the value has to be fixed at compile-time, while for immutable, it can still be assigned at construction time. 
 The compiler does not reserve a storage slot for these variables, and every occurrence is inlined by the respective value. 
 Compared to regular state variables, the gas costs of constant and immutable variables are much lower. For a constant variable, the expression assigned to it is copied to all the places where it is accessed and also re-evaluated each time. This allows for local optimizations. Immutable variables are evaluated once at construction time and their value is copied to all the places in the code where they are accessed. For these values, 32 bytes are reserved, even if they would fit in fewer bytes. Due to this, constant values can sometimes be cheaper than immutable values. 
 - Savings: ~2103 
 

 --- 

File:ERC20PaymentNFT.sol#L19
```solidity
18:    uint64 public maxPublicMint;
``` 



 --- 

<a name=[Gas-1]></a>
### [Gas-1] Cache Storage Variables in Memory - Instances: 1 

 > 
  - Savings: ~0 
 

 --- 

File:ERC20PaymentNFT.sol#L79
```solidity
78:        live = !live;
``` 



File:ERC20PaymentNFT.sol#L79
```solidity
78:        live = !live;
``` 



 --- 

<a name=[Gas-2]></a>
### [Gas-2] Use custom errors instead of string error messages - Instances: 1 

 > 
 Using custom errors will save you gas, and can be used to provide more information about the error. - Savings: ~57 
 

 --- 

File:ERC20PaymentNFT.sol#L63
```solidity
62:        require(IERC20(TOKEN_ADDRESS).transferFrom(msg.sender, address(this), _amount), "Transfer Failed");
``` 



File:ERC20PaymentNFT.sol#L107
```solidity
106:        require(contractBalance > 0, "No funds available for withdrawal.");
``` 



File:ERC20PaymentNFT.sol#L109
```solidity
108:        require(IERC20(TOKEN_ADDRESS).transfer(msg.sender, contractBalance), "Token transfer failed");
``` 



 --- 

<a name=[Gas-3]></a>
### [Gas-3] Use assembly for math (add, sub, mul, div) - Instances: 1 

 > 
 Use assembly for math instead of Solidity. You can check for overflow/underflow in assembly to ensure safety. If using Solidity versions < 0.8.0 and you are using Safemath, you can gain significant gas savings by using assembly to calculate values and checking for overflow/underflow. - Savings: ~60 
 

 --- 

File:ERC20PaymentNFT.sol#L67
```solidity
66:        uint256 minted = _numberMinted(msg.sender) + _amount;
``` 



File:ERC20PaymentNFT.sol#L69
```solidity
68:        if (_totalMinted() + _amount > MAX_SUPPLY) revert SupplyExceeded();
``` 



File:ERC20PaymentNFT.sol#L70
```solidity
69:        uint256 mintAmount = rate * _amount;
``` 



 --- 

<a name=[Gas-4]></a>
### [Gas-4] Use assembly to write storage values - Instances: 1 

 > 
 You can save a fair amount of gas by using assembly to write storage values. - Savings: ~66 
 

 --- 

File:ERC20PaymentNFT.sol#L53
```solidity
52:        _baseURIString = _uri;
``` 



File:ERC20PaymentNFT.sol#L54
```solidity
53:        maxPublicMint = _maxPublicMint;
``` 



File:ERC20PaymentNFT.sol#L55
```solidity
54:        rate = _rate;
``` 



File:ERC20PaymentNFT.sol#L79
```solidity
78:        live = !live;
``` 



File:ERC20PaymentNFT.sol#L83
```solidity
82:        rate = _newRate;
``` 



File:ERC20PaymentNFT.sol#L90
```solidity
89:        _baseURIString = _uri;
``` 



 --- 

<a name=[Gas-5]></a>
### [Gas-5] Mark functions as payable (with discretion) - Instances: 2 

 > 
 You can mark public or external functions as payable to save gas. Functions that are not payable have additional logic to check if there was a value sent with a call, however, making a function payable eliminates this check. This optimization should be carefully considered due to potentially unwanted behavior when a function does not need to accept ether. - Savings: ~24 
 

 --- 

File:Foo.sol#L5
```solidity
4:    function id(uint256 value) external pure returns (uint256) {
``` 



File:ERC20PaymentNFT.sol#L66
```solidity
65:    function mintWithToken(uint256 _amount) external {
``` 



File:ERC20PaymentNFT.sol#L78
```solidity
77:    function toggleLive() external onlyOwner {
``` 



File:ERC20PaymentNFT.sol#L82
```solidity
81:    function updateRate(uint256 _newRate) external onlyOwner {
``` 



File:ERC20PaymentNFT.sol#L89
```solidity
88:    function setBaseUri(string calldata _uri) external onlyOwner {
``` 



File:ERC20PaymentNFT.sol#L95
```solidity
94:    function tokenURI(uint256 tokenId) public view override returns (string memory) {
``` 



File:ERC20PaymentNFT.sol#L104
```solidity
103:    function withdrawTokens() external onlyOwner {
``` 



 --- 



## Quality Assurance - Total: 21 

<a name=[NonCritical-0]></a>
### [NonCritical-0] Constructor should check that all parameters are not 0 - Instances: 8 

 > Consider adding a require statement to check that all parameters are not 0 in the constructor 

 --- 

File:ERC20PaymentNFT.sol#L37
```solidity
36:    constructor(
37:        string memory _name,
38:        string memory _ticker,
39:        address _tokenAddress,
40:        uint256 _mintPrice,
41:        uint256 _maxSupply,
42:        uint256 _rate,
43:        string memory _uri,
44:        uint64 _maxPublicMint
45:    )
46:        ERC721A(_name, _ticker)
47:        Ownable(msg.sender)
48:    {
``` 



File:ERC20PaymentNFT.sol#L37
```solidity
36:    constructor(
37:        string memory _name,
38:        string memory _ticker,
39:        address _tokenAddress,
40:        uint256 _mintPrice,
41:        uint256 _maxSupply,
42:        uint256 _rate,
43:        string memory _uri,
44:        uint64 _maxPublicMint
45:    )
46:        ERC721A(_name, _ticker)
47:        Ownable(msg.sender)
48:    {
``` 



File:ERC20PaymentNFT.sol#L37
```solidity
36:    constructor(
37:        string memory _name,
38:        string memory _ticker,
39:        address _tokenAddress,
40:        uint256 _mintPrice,
41:        uint256 _maxSupply,
42:        uint256 _rate,
43:        string memory _uri,
44:        uint64 _maxPublicMint
45:    )
46:        ERC721A(_name, _ticker)
47:        Ownable(msg.sender)
48:    {
``` 



File:ERC20PaymentNFT.sol#L37
```solidity
36:    constructor(
37:        string memory _name,
38:        string memory _ticker,
39:        address _tokenAddress,
40:        uint256 _mintPrice,
41:        uint256 _maxSupply,
42:        uint256 _rate,
43:        string memory _uri,
44:        uint64 _maxPublicMint
45:    )
46:        ERC721A(_name, _ticker)
47:        Ownable(msg.sender)
48:    {
``` 



File:ERC20PaymentNFT.sol#L37
```solidity
36:    constructor(
37:        string memory _name,
38:        string memory _ticker,
39:        address _tokenAddress,
40:        uint256 _mintPrice,
41:        uint256 _maxSupply,
42:        uint256 _rate,
43:        string memory _uri,
44:        uint64 _maxPublicMint
45:    )
46:        ERC721A(_name, _ticker)
47:        Ownable(msg.sender)
48:    {
``` 



File:ERC20PaymentNFT.sol#L37
```solidity
36:    constructor(
37:        string memory _name,
38:        string memory _ticker,
39:        address _tokenAddress,
40:        uint256 _mintPrice,
41:        uint256 _maxSupply,
42:        uint256 _rate,
43:        string memory _uri,
44:        uint64 _maxPublicMint
45:    )
46:        ERC721A(_name, _ticker)
47:        Ownable(msg.sender)
48:    {
``` 



File:ERC20PaymentNFT.sol#L37
```solidity
36:    constructor(
37:        string memory _name,
38:        string memory _ticker,
39:        address _tokenAddress,
40:        uint256 _mintPrice,
41:        uint256 _maxSupply,
42:        uint256 _rate,
43:        string memory _uri,
44:        uint64 _maxPublicMint
45:    )
46:        ERC721A(_name, _ticker)
47:        Ownable(msg.sender)
48:    {
``` 



File:ERC20PaymentNFT.sol#L37
```solidity
36:    constructor(
37:        string memory _name,
38:        string memory _ticker,
39:        address _tokenAddress,
40:        uint256 _mintPrice,
41:        uint256 _maxSupply,
42:        uint256 _rate,
43:        string memory _uri,
44:        uint64 _maxPublicMint
45:    )
46:        ERC721A(_name, _ticker)
47:        Ownable(msg.sender)
48:    {
``` 



 --- 

<a name=[NonCritical-1]></a>
### [NonCritical-1] This error has no parameters, the state of the contract when the revert occured will not be available - Instances: 3 

 > Consider adding parameters to the error to provide more context when a transaction fails 

 --- 

File:ERC20PaymentNFT.sol#L24
```solidity
23:    error MintExceeded();
``` 



File:ERC20PaymentNFT.sol#L25
```solidity
24:    error SupplyExceeded();
``` 



File:ERC20PaymentNFT.sol#L26
```solidity
25:    error TokenDoesNotExist();
``` 



 --- 

<a name=[NonCritical-2]></a>
### [NonCritical-2] Function names should be in camelCase - Instances: 1 

 > Ensure that function definitions are declared using camelCase 

 --- 

File:Foo.sol#L5
```solidity
4:    function id(uint256 value) external pure returns (uint256) {
``` 



 --- 

<a name=[NonCritical-3]></a>
### [NonCritical-3] Consider marking public function External - Instances: 1 

 > If a public function is never called internally, it is best practice to mark it as external. 

 --- 

File:ERC20PaymentNFT.sol#L95
```solidity
94:    function tokenURI(uint256 tokenId) public view override returns (string memory) {
``` 



 --- 

<a name=[NonCritical-4]></a>
### [NonCritical-4] Function parameters should be in camelCase - Instances: 8 

 > Ensure that function parameters are declared using camelCase 

 --- 

File:Foo.sol#L5
```solidity
4:    function id(uint256 value) external pure returns (uint256) {
``` 



File:ERC20PaymentNFT.sol#L38
```solidity
37:        string memory _name,
``` 



File:ERC20PaymentNFT.sol#L39
```solidity
38:        string memory _ticker,
``` 



File:ERC20PaymentNFT.sol#L43
```solidity
42:        uint256 _rate,
``` 



File:ERC20PaymentNFT.sol#L44
```solidity
43:        string memory _uri,
``` 



File:ERC20PaymentNFT.sol#L62
```solidity
61:    function _transferPaymentToken(uint256 _amount) internal {
``` 



File:ERC20PaymentNFT.sol#L66
```solidity
65:    function mintWithToken(uint256 _amount) external {
``` 



File:ERC20PaymentNFT.sol#L89
```solidity
88:    function setBaseUri(string calldata _uri) external onlyOwner {
``` 



 --- 



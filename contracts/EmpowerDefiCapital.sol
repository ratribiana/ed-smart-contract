// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./EmpowerDefiToken.sol";
import "./EmpowerDefiNFT.sol";

contract EmpowerDefiCapital is Ownable {
    EmpowerDefiToken public mokiToken;
    EmpowerDefiNFT public nft;
    address public usdcAddress;
    address public adminWallet;

    struct Loan {
        uint256 id;
        address loanOwner;
        uint256 interestRate;
        uint256 totalReserves;
        uint256 remainingReserves;
        bool isForSale;
        uint256 sellAmount;
        bool isAvailable;
    }

    struct Borrower {
        uint256 id;
        address borrowerAddress;
        uint256 balance;
    }

    uint256 private loanId = 1;
    uint256 public mokiRate = 70000000000000000;
    uint256 public fNftTradingRate = 10;

    uint256 public platformEarnings = 0;

    mapping(uint256 => Loan) public loans;
    mapping(uint256 => Borrower) public borrower;

    // Mapping to check the borrowed amount of an address
    mapping(address => uint256) public loanBalance;

    // Mapping to track the deposited reserves of an address
    mapping(address => uint256) public reserves;

    // Mapping to track the earnings of a lender
    mapping(address => uint256) public claimableAmount;

    event LoanCreated(
        address indexed loanOwner,
        uint256 indexed loanId,
        uint256 interestRate,
        uint256 totalReserves,
        uint256 remainingReserves
    );
    event LoanUnavailable(address indexed loanOwner, uint256 indexed loanIndex);
    event ReservesBorrowed(
        address indexed borrower,
        address indexed lender,
        uint256 indexed loanIndex,
        uint256 amount
    );
    event EarningsReceived(address, uint256);
    event PaymentSent(address, address, uint256);
    event EarningsWithdrawn(uint256, uint256);
    event UserWithdrawal(address, uint256);
    event AdminWalletUpdated(address);
    event RateUpdated(uint256);
    event FNftForSale(uint256, bool, address, uint256);
    event fNftSold(uint256, address, address, uint256);

    constructor(
        address _usdcTokenAddress,
        address _nftAddress,
        address _mokiTokenAddress
    ) {
        require(_usdcTokenAddress != address(0), "Invalid token address");
        require(_mokiTokenAddress != address(0), "Invalid token address");
        require(_nftAddress != address(0), "Invalid NFT address");

        usdcAddress = _usdcTokenAddress;
        nft = EmpowerDefiNFT(_nftAddress);
        mokiToken = EmpowerDefiToken(_mokiTokenAddress);
    }

    function createReserves(uint256 _interestRate, uint256 _reserves) external {
        require(_interestRate > 0, "Interest rate must not be zero");
        require(_reserves > 0, "Reserves must not be zero");
        loans[loanId] = Loan(
            loanId,
            msg.sender,
            _interestRate,
            _reserves,
            _reserves,
            false,
            0,
            true
        );

        // Deposit the USDC from the user to the contract
        IERC20 usdcToken = IERC20(usdcAddress);
        usdcToken.transferFrom(msg.sender, address(this), _reserves);

        // Update the reserves mapping
        reserves[msg.sender] = _reserves;

        emit LoanCreated(
            msg.sender,
            loanId,
            _interestRate,
            _reserves,
            _reserves
        );
        loanId++;
    }

    function borrow(uint256 _loanIndex, uint256 _amount) external {
        require(loans[_loanIndex].isAvailable, "Loan no longer available");
        require(_amount > 0, "Borrow amount should be greater than 0");
        require(
            loans[_loanIndex].remainingReserves >= _amount,
            "Reserve is too low"
        );
        loans[_loanIndex].remainingReserves -= _amount;
        borrower[_loanIndex] = Borrower(_loanIndex, msg.sender, _amount);

        address loanOwner = loans[_loanIndex].loanOwner;

        // Transfer the USDC
        IERC20 usdcToken = IERC20(usdcAddress);

        usdcToken.transferFrom(address(this), msg.sender, _amount);
        // Issue a Transfer NFT to lender
        nft.safeTransferFrom(nft.owner(), loanOwner, _loanIndex);

        loanBalance[msg.sender] = _amount;

        // Burn the credit token of the borrowe
        mokiToken.burnFrom(msg.sender, _amount);

        emit ReservesBorrowed(msg.sender, loanOwner, _loanIndex, _amount);
    }

    /**
     * @dev Allows the borrower to pay back their loan and fees to the lender and platform. Calculates the
     * interest on the loan based on the current balance and interest rate. The payment amount is transferred
     * from the borrower's wallet to the contract, and then to the lender's wallet. The platform fee is also
     * transferred to the contract, and the earnings are tracked for the platform. Finally, the mappings for
     * the loan balance, reserves, and claimable amounts are updated.
     *
     * Requirements:
     * - `_amount` must be greater than zero
     *
     * @param _loanIndex The index of the loan being paid back
     * @param _amount The amount being paid back by the borrower
     */
    function pay(uint256 _loanIndex, uint256 _amount) external {
        uint256 balance = borrower[_loanIndex].balance;
        uint256 interest = SafeMath.div(
            SafeMath.mul(balance, loans[_loanIndex].interestRate),
            100
        );

        // Calculated platform fee
        uint256 fee = (_amount * mokiRate) / 100;

        // Total payable amount plus interest
        uint256 amtPayable = balance + interest;

        require(_amount > 0, "No zero payment allowed");

        // Transfer the fee to the contract as part of platform earnings
        IERC20 usdcToken = IERC20(usdcAddress);
        usdcToken.transferFrom(msg.sender, address(this), fee);

        // Update the claimable platform's USDC balance
        platformEarnings += fee;
        emit EarningsReceived(msg.sender, fee);

        // Transfer the payment back to the lender
        usdcToken.transferFrom(
            msg.sender,
            loans[_loanIndex].loanOwner,
            amtPayable
        );
        // Append the `amtPayable` value to the claimable amount of lender
        claimableAmount[loans[_loanIndex].loanOwner] += amtPayable;
        emit PaymentSent(msg.sender, loans[_loanIndex].loanOwner, amtPayable);

        // Update the balance mapping to reflect the updated balance of borrower
        loanBalance[msg.sender] -= amtPayable;

        // Update the loans mapping to reflect the updated reserves of a loan
        loans[_loanIndex].remainingReserves += _amount;

        // Update the reserves mapping to reflect the total deposit of a lender
        reserves[loans[_loanIndex].loanOwner] += _amount;
    }

    /**
     * @dev Allows the contract owner to withdraw the platform earnings in USDC tokens
     * Emits an `EarningsWithdrawn` event with the current timestamp and the amount of platform earnings withdrawn.
     * Requirements:
     * - The contract owner can only withdraw if there are earnings available
     * - The contract must have sufficient allowance to transfer the USDC tokens
     */
    function withdrawAdminEarnings() external onlyOwner {
        require(platformEarnings > 0, "Nothing to withdraw");
        IERC20 usdcToken = IERC20(usdcAddress);
        usdcToken.transferFrom(address(this), adminWallet, platformEarnings);
        emit EarningsWithdrawn(block.timestamp, platformEarnings);
    }

    function sellFnft(uint256 _loanIndex, uint256 _sellAmount) external {
        require(
            msg.sender == loans[_loanIndex].loanOwner,
            "You are not the owner of this lend ID"
        );

        loans[_loanIndex].isForSale = true;
        loans[_loanIndex].sellAmount = _sellAmount;
        emit FNftForSale(_loanIndex, true, msg.sender, _sellAmount);
    }

    function buyFnft(uint256 _loanIndex) external {
        require(loans[_loanIndex].isForSale, "This FNft is not for sale");

        address currentOwner = loans[_loanIndex].loanOwner;
        uint256 fNftPrice = loans[_loanIndex].sellAmount;
        uint256 tradingFee = (fNftPrice * fNftTradingRate) / 100;

        IERC20 usdcToken = IERC20(usdcAddress);

        require(
            usdcToken.transfer(address(this), tradingFee),
            "Trading fee payment failed"
        );
        // Transferring USDC from current owner to msg.sender as a form of payment
        require(
            usdcToken.transfer(currentOwner, fNftPrice),
            "USDC payment failed"
        );
        // Emitting event to signify updates on platform's earnings
        emit EarningsReceived(msg.sender, tradingFee);

        // Updating the reserves mappings
        reserves[msg.sender] += loans[_loanIndex].totalReserves;
        reserves[currentOwner] -= loans[_loanIndex].totalReserves;

        // Update the loanOwner of the Loan ID
        loans[_loanIndex].loanOwner = msg.sender;

        // Update the following fields:
        loans[_loanIndex].isForSale = false; // Resetting this to not for sale
        loans[_loanIndex].sellAmount = 0; // Resetting the sell amount to 0

        emit FNftForSale(_loanIndex, false, msg.sender, 0);

        // Transfer the fNFT to msg.sender
        nft.safeTransferFrom(currentOwner, msg.sender, _loanIndex);
        // Checks to make sure that fNFT transfer was successful
        require(
            nft.ownerOf(_loanIndex) == currentOwner,
            "fNFT transfer failed"
        );

        emit fNftSold(
            _loanIndex,
            msg.sender,
            currentOwner,
            loans[_loanIndex].sellAmount
        );
    }

    /**
     * @notice Allows a user to withdraw their claimable earnings in USDC tokens
     * @dev Emits a `UserWithdrawal` event with the address of the user and the amount of earnings withdrawn
     * @dev Requirements:
     *      - The user must have deposited reserves
     *      - The user must have claimable earnings available for withdrawal
     */
    function withdrawUserEarnings() external {
        // Ensure that the user has deposited reserves
        require(reserves[msg.sender] > 0, "No deposited reserves");

        // Ensure that the user has claimable earnings available for withdrawal
        require(claimableAmount[msg.sender] > 0, "Nothing to withdraw");

        // Create an instance of the USDC token contract
        IERC20 usdcToken = IERC20(usdcAddress);

        // Calculate the amount of earnings to withdraw
        uint256 amount = claimableAmount[msg.sender];

        // Transfer the USDC tokens from the contract to the user's address
        usdcToken.transferFrom(address(this), msg.sender, amount);

        // Emit an event to log the withdrawal details
        emit UserWithdrawal(msg.sender, amount);
    }

    function markLoanAsUnavailable(uint256 loanIndex) external {
        if (
            // Making sure onlyOwner and loan owner can run this function
            msg.sender == this.owner() || msg.sender == loans[loanId].loanOwner
        ) {
            loans[loanId].isAvailable = false;
            emit LoanUnavailable(msg.sender, loanIndex);
        }
    }

    /**
     * @notice Sets an allowance for USDC token to spend a certain amount of USDC token.
     * @param _amount The amount of tokens to allow the USDC contract to spend.
     * @dev Only the owner of the contract can set the allowance.
     */
    function setAllowance(uint256 _amount) external onlyOwner {
        IERC20 usdcToken = IERC20(usdcAddress);
        IERC20(usdcToken).approve(address(this), _amount);
    }

    function setAdminWallet(address _newAddress) external onlyOwner {
        require(_newAddress != address(0), "Invalid wallet address");
        adminWallet = _newAddress;
        emit AdminWalletUpdated(_newAddress);
    }

    function setUsdcAddress(address _newUsdcAddress) external onlyOwner {
        require(_newUsdcAddress != address(0), "Invalid token address");
        usdcAddress = _newUsdcAddress;
    }

    function setMokiTokenAddress(address _tokenAddress) external onlyOwner {
        require(_tokenAddress != address(0), "Invalid token address");
        mokiToken = EmpowerDefiToken(_tokenAddress);
    }

    function setMokiRate(uint256 _newRate) external onlyOwner {
        mokiRate = _newRate;
        emit RateUpdated(_newRate);
    }

    function setNftAddress(address _nftAddress) external onlyOwner {
        require(_nftAddress != address(0), "Invalid NFT address");
        nft = EmpowerDefiNFT(_nftAddress);
    }

    function getRemainingReserves(
        uint256 _loanIndex
    ) external view returns (uint256) {
        return loans[_loanIndex].remainingReserves;
    }

    function getLoansCount() external view returns (uint256) {
        return loanId - 1;
    }
}

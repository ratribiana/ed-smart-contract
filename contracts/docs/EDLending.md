# [`EDLending.sol` Smart contract](/contracts/EDLending.sol)

## Here's how it works:

A user can create a loan by calling the `createReserves` function and specifying the interest rate and the amount of USDC they want to deposit as reserves. The function creates a new loan object and stores it in the loans mapping. The user also needs to approve the smart contract to transfer USDC from their account to the smart contract before calling this function.

Another user can borrow USDC by calling the `borrow` function and specifying the index of the loan they want to borrow from, as well as the amount of USDC they want to borrow. The function checks that the loan is available (i.e., not already fully borrowed), that the amount they want to borrow is less than or equal to the remaining reserves of the loan, and that the user has approved the smart contract to transfer USDC from their account to the smart contract before proceeding. If these conditions are met, the function transfers the USDC from the smart contract to the borrower and transfers the NFT that corresponds to the loan from the lender to the borrower.

The borrower can pay back the USDC they borrowed plus interest and a platform fee by calling the `pay` function and specifying the index of the loan they want to repay and the amount of USDC they want to repay. The function calculates the amount of interest and fee to charge, transfers the USDC from the borrower to the smart contract, adds the fee to the platform balance, and transfers the remaining USDC to the lender.

The lender can mark the loan as unavailable by calling the `markLoanAsUnavailable` function, which sets the `isAvailable` flag of the loan to false. Only the owner of the smart contract or the owner of the loan can call this function.

The smart contract uses the OpenZeppelin library to import the Ownable, IERC20, and IERC721 contracts. It also imports two other contracts, EmpowerDefiToken and EmpowerDefiNFT, which are not included in the code snippet provided.

## Dependencies

This smart contract relies on the following:

- `@openzeppelin/contracts/access/Ownable.sol`
- `@openzeppelin/contracts/token/ERC20/IERC20.sol`
- `@openzeppelin/contracts/token/ERC721/IERC721.sol`
- `EmpowerDefiToken.sol`
- `EmpowerDefiNFT.sol`

## Usage

### `createReserves(uint256 _interestRate, uint256 _reserves) external`

This function is used to create reserves. It takes two arguments:

- `_interestRate`: The interest rate for the loan.
- `_reserves`: The amount of reserves to create.

Example:

```
import Web3 from 'web3';
import contractAbi from './contractAbi.json';

const web3 = new Web3('https://mainnet.infura.io/v3/YOUR_PROJECT_ID');
const contractAddress = '0x123456789ABCDEF';
const contractInstance = new web3.eth.Contract(contractAbi, contractAddress);

const createReserves = async (interestRate, reserves) => {
  await contractInstance.methods.createReserves(interestRate, reserves).send({ from: YOUR_ACCOUNT_ADDRESS });
}
```

### `borrow(uint256 _loanIndex, uint256 _amount) external`

This function is used to borrow from a loan. It takes two arguments:

- `_loanIndex`: The index of the loan to borrow from.
- `_amount`: The amount to borrow.

Example:

```
import Web3 from 'web3';
import contractAbi from './contractAbi.json';

const web3 = new Web3('https://mainnet.infura.io/v3/YOUR_PROJECT_ID');
const contractAddress = '0x123456789ABCDEF';
const contractInstance = new web3.eth.Contract(contractAbi, contractAddress);

const BorrowForm = ({ contract }) => {
  const [amount, setAmount] = useState("");
  const [loanId, setLoanId] = useState("");

  const handleBorrow = async (event) => {
    event.preventDefault();
    try {
      const tx = await contract.borrow(ethers.utils.parseEther(amount), loanId);
      await tx.wait();
      alert("Successfully borrowed from the loan!");
    } catch (err) {
      console.error(err);
      alert("Failed to borrow from the loan");
    }
  };

  return (
    <form onSubmit={handleBorrow}>
      <label>
        Amount to borrow (in USDC):
        <input
          type="text"
          value={amount}
          onChange={(event) => setAmount(event.target.value)}
        />
      </label>
      <br />
      <label>
        Loan ID:
        <input
          type="text"
          value={loanId}
          onChange={(event) => setLoanId(event.target.value)}
        />
      </label>
      <br />
      <button type="submit">Borrow</button>
    </form>
  );
};

export default BorrowForm;

```

### `pay(uint256 _loanIndex, uint256 _amount) external`

This function is used to pay back a loan. It takes two arguments:

- `_loanIndex`: The index of the loan to pay back.
- `_amount`: The amount to pay back.

Example:

```
import { useState } from "react";
import { ethers } from "ethers";
import { YOUR_CONTRACT_ADDRESS, YOUR_CONTRACT_ABI } from "./contractInfo";

function PayLoan() {
  const [loanIndex, setLoanIndex] = useState("");
  const [amount, setAmount] = useState("");

  const handleLoanIndexChange = (event) => {
    setLoanIndex(event.target.value);
  };

  const handleAmountChange = (event) => {
    setAmount(event.target.value);
  };

  const handlePayLoan = async () => {
    try {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      await window.ethereum.enable();
      const signer = provider.getSigner();

      const contract = new ethers.Contract(
        YOUR_CONTRACT_ADDRESS,
        YOUR_CONTRACT_ABI,
        signer
      );

      // Call the pay function on the contract
      const tx = await contract.pay(loanIndex, amount);

      console.log("Transaction hash:", tx.hash);
    } catch (error) {
      console.error(error);
    }
  };

  return (
    <div>
      <h2>Pay Loan</h2>
      <label>
        Loan Index:
        <input type="text" value={loanIndex} onChange={handleLoanIndexChange} />
      </label>
      <label>
        Amount:
        <input type="text" value={amount} onChange={handleAmountChange} />
      </label>
      <button onClick={handlePayLoan}>Pay Loan</button>
    </div>
  );
}

export default PayLoan;

```

### `markLoanAsUnavailable(uint256 loanIndex) external`

This function is used to mark a loan as unavailable. It takes one argument:

- `loanIndex`: The index of the loan to mark as unavailable.

## Events

This smart contract emits the following events:

### `LoanCreated(address indexed loanOwner, uint256 indexed loanId, uint256 interestRate, uint256 totalReserves, uint256 remainingReserves)`

This event is emitted when a loan is created.

### `LoanUnavailable(address indexed loanOwner, uint256 indexed loanIndex)`

This event is emitted when a loan is marked as unavailable.

### `ReservesBorrowed(address indexed borrower, address indexed lender, uint256 indexed loanIndex, uint256 amount)`

This event is emitted when reserves are borrowed from a loan.

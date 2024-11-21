// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Multiescrow {
    struct Depositor {
        address depositorAddress;
        uint256 amount;
    }

    struct Beneficiaries {
        address beneficiaryAddress;
        uint256 withdrawAmount;
        bool isbnf;
    }

    struct Transaction {
        address from;
        address to;
        uint256 amount;
    }

    Transaction[] public listoftransactions;

    Beneficiaries[] public listofbeneficiaries;
    Depositor public depositor;

    modifier onlyDepositor() {
        require(msg.sender == depositor.depositorAddress, "Only depositor can call this function ");
        _;
    }

    modifier onlyBeneficiary(uint256 bnfId) {
        require(listofbeneficiaries[bnfId].beneficiaryAddress == msg.sender, "only beneficiary can call this function");
        _;
    }

    modifier checkForBlacklist(uint256 bnfId) {
        require(listofbeneficiaries[bnfId].beneficiaryAddress == msg.sender, "only beneficiary can call this function");
        require(listofbeneficiaries[bnfId].isbnf == true, "only whitelisted beneficiary can call this function");
        _;
    }

    function depositAmount() public payable {
        depositor.amount = msg.value;
        depositor.depositorAddress = msg.sender;
        Transaction storage newTransaction = listoftransactions.push();
        newTransaction.amount = msg.value;
        newTransaction.from = msg.sender;
        newTransaction.to = address(this);
    }

    function addBeneficiary(address newBeneficiaryAddress, uint256 newwithdrawAmount) public onlyDepositor {
        Beneficiaries storage newBeneficiary = listofbeneficiaries.push();
        newBeneficiary.beneficiaryAddress = newBeneficiaryAddress;
        newBeneficiary.withdrawAmount = newwithdrawAmount;
        newBeneficiary.isbnf = true;
    }

    function withdrawAmount(uint256 bnfId, uint256 newwithdrawAmount)
        public
        payable
        onlyBeneficiary(bnfId)
        checkForBlacklist(bnfId)
    {
        Beneficiaries storage beneficiary = listofbeneficiaries[bnfId];
        uint256 amount = beneficiary.withdrawAmount;
        if (amount > newwithdrawAmount) {
            payable(msg.sender).transfer(newwithdrawAmount);
            Transaction storage newTransaction = listoftransactions.push();
            newTransaction.amount = newwithdrawAmount;
            newTransaction.from = msg.sender;
            newTransaction.to = address(this);
        } else {
            beneficiary.isbnf = false;
        }
    }

    function blacklistBeneficiary(uint256 bnfId) public onlyDepositor {
        Beneficiaries storage beneficiary = listofbeneficiaries[bnfId];
        beneficiary.isbnf = false;
    }

    function withdrawBnfAmount(uint256 bnfId) public payable onlyDepositor {
        Beneficiaries storage beneficiary = listofbeneficiaries[bnfId];
        require(beneficiary.isbnf = false, "Only can withdraw blacklisted beneficiary amount");
        payable(msg.sender).transfer(beneficiary.withdrawAmount);
        Transaction storage newTransaction = listoftransactions.push();
        newTransaction.amount = beneficiary.withdrawAmount;
        newTransaction.from = msg.sender;
        newTransaction.to = address(this);
    }

    function getAllTransactions() public view returns (Transaction[] memory) {
        return listoftransactions;
    }

    function getATransactions(uint256 transactionId) public view returns (Transaction memory) {
        return listoftransactions[transactionId];
    }

    function isBlacklisted(uint256 bnfId) public view returns (bool) {
        Beneficiaries storage beneficiary = listofbeneficiaries[bnfId];
        return beneficiary.isbnf;
    }
}

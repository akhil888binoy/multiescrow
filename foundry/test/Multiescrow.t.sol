// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "../src/Multiescrow.sol";

contract MultiescrowTest is Test {
    Multiescrow public multiescrow;

    address public depositor = address(1);
    address public beneficiary1 = address(2);
    address public beneficiary2 = address(3);

    function setUp() public {
        multiescrow = new Multiescrow();

        vm.deal(depositor, 10 ether);
        vm.deal(beneficiary1, 1 ether);
        vm.deal(beneficiary2, 1 ether);
    }

    function testDepositAmount() public {
        vm.startPrank(depositor);
        uint256 depositAmount = 5 ether;

        multiescrow.depositAmount{value: depositAmount}();

        (address depositorAddress, uint256 amount) = multiescrow.depositor();
        assertEq(depositorAddress, depositor);
        assertEq(amount, depositAmount);

        Multiescrow.Transaction memory txn = multiescrow.getATransactions(0);
        assertEq(txn.from, depositor);
        assertEq(txn.to, address(multiescrow));
        assertEq(txn.amount, depositAmount);

        vm.stopPrank();
    }

    function testAddBeneficiary() public {
        vm.startPrank(depositor);
        uint256 withdrawAmount = 1 ether;

        multiescrow.depositAmount{value: 5 ether}();
        multiescrow.addBeneficiary(beneficiary1, withdrawAmount);

        (address addr, uint256 amount, bool isWhitelisted) = multiescrow.listofbeneficiaries(0);
        assertEq(addr, beneficiary1);
        assertEq(amount, withdrawAmount);
        assertTrue(isWhitelisted);

        vm.stopPrank();
    }

    function testBlacklistBeneficiary() public {
        vm.startPrank(depositor);

        uint256 depositAmount = 5 ether;
        uint256 withdrawAmount = 1 ether;

        multiescrow.depositAmount{value: depositAmount}();
        multiescrow.addBeneficiary(beneficiary1, withdrawAmount);

        multiescrow.blacklistBeneficiary(0);

        assertFalse(multiescrow.isBlacklisted(0));

        vm.stopPrank();
    }
}

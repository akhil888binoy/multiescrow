// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {Multiescrow} from "../src/Multiescrow.sol";

contract MultiescrowTest is Test {
    Multiescrow public multiescrow;

    function setUp() public {
        multiescrow = new Multiescrow();
    }

    function testDeposit() public {}
}

//SPDX-License_Identifier:MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";

import {FundMe} from "../../src/FundMe.sol";

import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    DeployFundMe deployFundMe;
    address USER = makeAddr("user");
    uint256 constant VALUE = 10e18;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollorIsFive() external view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwner() external view {
        assertEq(fundMe.getOwner(), msg.sender);
        console.log("AddressThis", address(this));
        console.log("MSGSENDER", msg.sender);
        console.log("Owner", fundMe.getOwner());
    }

    function testPriceFeedVersionIsAccurate() external view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testMinimumETH() external {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundedEnough() external {
        vm.prank(USER);
        fundMe.fund{value: VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, VALUE);
    }

    function testGetFunder() external {
        vm.prank(USER);
        fundMe.fund{value: 1 ether}();
        address funder = fundMe.getFunder(0);
        bytes32 value = vm.load(address(fundMe), bytes32(uint256(1)));
        console.log("VALUEEEEEEEEEEEE");
        console.logBytes32(value);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() external {
        vm.deal(address(fundMe), 10 ether);

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        assertEq(address(fundMe).balance, 0);
    }

    function testOnlyOwnerCanWithdrawCheapWithdraw() external {
        vm.deal(address(fundMe), 10 ether);

        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithdraw();

        assertEq(address(fundMe).balance, 0);
    }

    function testWithdrawFail() external {
        vm.deal(address(fundMe), 10 ether);
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithGas() external {
        vm.deal(address(fundMe), 10 ether);
        vm.deal(address(fundMe.getOwner()), 1 ether);
        uint256 fundMeIntialBalance = address(fundMe).balance; //10 ether
        uint256 ownerIntialBalance = address(fundMe.getOwner()).balance;

        vm.prank(fundMe.getOwner());
        // vm.txGasPrice(1); it sets the gas price for the rest of the execution
        fundMe.withdraw();

        assertEq(
            fundMeIntialBalance,
            address(fundMe.getOwner()).balance - ownerIntialBalance
        );
    }
}

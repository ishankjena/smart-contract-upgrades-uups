// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Test} from "forge-std/Test.sol";
import {BoxV1} from "../src/BoxV1.sol";
import {BoxV2} from "../src/BoxV2.sol";
import {DeployBox} from "../script/DeployBox.s.sol";
import {UpgradeBox} from "../script/UpgradeBox.s.sol";

contract DeployAndUpgradeTest is Test {
	DeployBox public deployer;
	UpgradeBox public upgrader;
	address public OWNER = makeAddr("owner");

	address public proxy;
	
	function setUp() public {
		deployer = new DeployBox();
		upgrader = new UpgradeBox();
		proxy = deployer.run(); // proxy points to boxV1 initially
	}

	function testProxyInitiallyBoxV1() public {
		vm.expectRevert();
		// this should not work if proxy is BoxV1
		BoxV2(proxy).setNumber(9);
	}

	function testUpgrades() public {
		// deploy new version
		BoxV2 box2 = new BoxV2();
		// upgrade proxy to version 2
		upgrader.upgradeBox(proxy, address(box2));
		uint256 expectedValue = 2;
		assert(expectedValue==BoxV2(proxy).version());

		BoxV2(proxy).setNumber(7);
		assert(BoxV2(proxy).getNumber()==7);
	}
}	
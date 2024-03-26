// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {BoxV1} from "../src/BoxV1.sol";
import {BoxV2} from "../src/BoxV2.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract UpgradeBox is Script{
	function run() external returns(address) {
		address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("ERC1967Proxy", block.chainid);
		
		vm.startBroadcast();
		BoxV2 newImplementaion = new BoxV2();
		vm.stopBroadcast();
		address proxy = upgradeBox(mostRecentlyDeployed, address(newImplementaion));
		return proxy;
	}

	function upgradeBox(address proxyAddress, address newImplementaion) public returns(address) {
		vm.startBroadcast();
		// get the most recently deployed implementation's proxy
		BoxV1 proxy = BoxV1(proxyAddress);
		// point proxy to new implementation contract address
		proxy.upgradeToAndCall(address(newImplementaion), "");
		vm.stopBroadcast();
		return address(proxy);
	}
}
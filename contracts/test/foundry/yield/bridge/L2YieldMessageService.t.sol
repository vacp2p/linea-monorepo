// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.19;

import { Test } from "forge-std/Test.sol";
import { L2MessageService } from "../../../../src/messaging/l2/L2MessageService.sol";
import { L2YieldMessageService } from "../../../../src/yield/bridge/L2YieldMessageService.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { IPermissionsManager } from "../../../../src/security/access/interfaces/IPermissionsManager.sol";
import { IPauseManager } from "../../../../src/security/pausing/interfaces/IPauseManager.sol";

contract L2YieldMessageServiceTest is Test {
    L2YieldMessageService yieldMessageService;
    address defaultAdmin = makeAddr("defaultAdmin");
    
    function setUp() public {
        L2YieldMessageService implementation  = new L2YieldMessageService();
        bytes memory initializer = abi.encodeWithSelector(L2MessageService.initialize.selector, 
            86400,
            100 ether,
            defaultAdmin,
            new IPermissionsManager.RoleAddress[](0),
            new IPauseManager.PauseTypeRole[](0),
            new IPauseManager.PauseTypeRole[](0)
        );
        ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), initializer);
        yieldMessageService = L2YieldMessageService(address(proxy));
    }

    function test_RevertWhenValueIsGreaterThanZero() public {
        vm.expectRevert("L2YieldMessageService__InvalidValue()");
        yieldMessageService.claimMessage(
            makeAddr("from"),
            makeAddr("to"),
            0,
            1,
            payable(defaultAdmin),
            hex"00",
            0
        );
    }
}

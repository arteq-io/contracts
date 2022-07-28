/*
 * This file is part of the contracts written for artèQ Investment Fund (https://github.com/arteq-io/contracts).
 * Copyright (c) 2022 artèQ (https://arteq.io)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
// SPDX-License-Identifier: GNU General Public License v3.0

pragma solidity 0.8.1;

// import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

import "../../arteq-tech/contracts/vaults/VaultsConfig.sol";
import "../../arteq-tech/contracts/diamond/DiamondV1.sol";
import "./minter/MinterLib.sol";
import "./arteQCollectionV2Config.sol";

/// @author Kam Amini <kam.cpp@gmail.com> <kam@arteq.io>
///
/// @notice Use at your own risk

/* solhint-disable contract-name-camelcase */
contract TestCollectionV2Diamond is DiamondV1 {

    string private _detailsURI;

    constructor(
        address taskManager,
        address[] memory admins,
        address[] memory tokenManagers,
        address[] memory vaultAdmins,
        address[] memory diamondAdmins
    ) DiamondV1(taskManager, diamondAdmins) {
        // Admin role
        for (uint i = 0; i < admins.length; i++) {
            RoleManagerLib._grantRole(admins[i], arteQCollectionV2Config.ROLE_ADMIN);
        }
        // Token Manager role
        for (uint i = 0; i < tokenManagers.length; i++) {
            RoleManagerLib._grantRole(tokenManagers[i], arteQCollectionV2Config.ROLE_TOKEN_MANAGER);
        }
        // Vault Admin role
        for (uint i = 0; i < vaultAdmins.length; i++) {
            RoleManagerLib._grantRole(vaultAdmins[i], VaultsConfig.ROLE_VAULT_ADMIN);
        }
        MinterLib._justMintTo(address(this)); // mint and reserve token #0
    }

    /* solhint-disable no-complex-fallback */
    fallback() external payable {
        address facet = _findFacet(msg.sig);
        /* solhint-disable no-inline-assembly */
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
                case 0 {
                    revert(0, returndatasize())
                }
                default {
                    return(0, returndatasize())
                }
        }
        /* solhint-enable no-inline-assembly */
    }

    /* solhint-disable no-empty-blocks */
    receive() external payable {
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "./ExternalStorage.sol";
import "./AbilityStorage.sol";
import "./AbilityOwnerStorage.sol";

contract OwnedAbilityStorage is AbilityOwnerStorage, AbilityStorage, ExternalStorage {}
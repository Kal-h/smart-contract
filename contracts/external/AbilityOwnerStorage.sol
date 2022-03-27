// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

/**
 * @title AbilityOwnerStorage
 * @dev This contract keeps track of the abilityOwner owner
 */
contract AbilityOwnerStorage {
    // Owner of the contract
    address private _abilityOwner;

    /**
    * @dev Tells the address of the owner
    * @return the address of the owner
    */
    function abilityOwner() public view returns (address) {
        return _abilityOwner;
    }

    /**
    * @dev Sets the address of the owner
    */
    function setAbilityOwner(address newAbilityOwner) internal {
        _abilityOwner = newAbilityOwner;
    }

}
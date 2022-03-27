// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "./Ownable.sol";
import "./external/ExternalStorage.sol";


/**
 * @title Claimable
 * @dev Extension for the Ownable contract, where the ownership needs to be claimed.
 * This allows the new owner to accept the transfer.
 */
contract Claimable is ExternalStorage, Ownable {
    function pendingOwner() public view returns (address) {
        return addressStorage[keccak256("pendingOwner")];
    }

    /**
    * @dev Modifier throws if called by any account other than the pendingOwner.
    */
    modifier onlyPendingOwner() {
        require(msg.sender == pendingOwner());
        _;
    }

    /**
    * @dev Allows the current owner to set the pendingOwner address.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public override onlyOwner {
        require(newOwner != address(0));
        addressStorage[keccak256("pendingOwner")] = newOwner;
    }

    /**
    * @dev Allows the pendingOwner address to finalize the transfer.
    */
    function claimOwnership() public onlyPendingOwner {
        emit OwnershipTransferred(owner(), pendingOwner());
        addressStorage[keccak256("owner")] = addressStorage[keccak256("pendingOwner")];
        addressStorage[keccak256("pendingOwner")] = address(0);
    }
}
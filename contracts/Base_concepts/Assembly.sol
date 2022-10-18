// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

// Reference : https://ethervm.io/
contract Assembly {
    function foo() external {
        uint256 a;
        uint256 b;
        uint256 c;
        uint256 size;
        address addr = msg.sender;
        bytes memory data = new bytes(10);
        bytes32 dataB32;
        /*
         * := -> = in assembly
         * No ;
         * Can declare variable with let
         * declare the actions with op code ( here "add" )
         * mload -> load data from memory slot, pass it the address of the slot
         * mstore -> store something in memory 1st arg destination 2nd arg payload !! must fit in  256 bits
         *   -> Not persistent, only available during function execution
         * sstore -> store
         *   -> persistent after function execution
         * extcodesize -> return the size of the code in a specific ethereum address
         */
        assembly {
            // c := add(1, 2)
            // let a := mload(0x40)
            // mstore(a, 2)
            // sstore(a, 10)
            size := extcodesize(addr)
            // cast bytes to bytes32
            // can only be done with assembly
            dataB32 := mload(add(data, 32)) // why do we add 32 bytes here ?
            // first memory slot is the size of the bytes
            // data start actually at the second slot
        }

        if (size > 0) {
            return true; // if > 0 this is a smart contract address
        } else {
            return false; // if 0 this is a normal ethereum address
        }
    }

    function setData(uint256 newValue) public {
        assembly {
            sstore(0, newValue)
        }
    }

    function getData() public view returns (uint256) {
        assembly {
            let v := sload(0) // get data at slot 0 from above function
            mstore(0x80, v) // 0x80 = storage position
            return(0x80, 32) // return this data on format uint256 --> 32 bits
        }
    }
}

contract SendEth {
    address[2] owners = [
        0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,
        0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB
    ];

    function withdrawEth(address _to, uint256 _amount) external payable {
        bool success;
        assembly {
            for {
                let i := 0
            } lt(i, 2) {
                i := add(i, 1)
            } {
                let owner := sload(i)
                if eq(_to, owner) {
                    success := call(gas(), _to, _amount, 0, 0, 0, 0)
                }
            }
        }
        require(success, "failed to send ETH");
    }
}

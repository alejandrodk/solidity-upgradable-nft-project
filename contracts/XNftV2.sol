// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract XNftV2 is ERC1155URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _nftIds;

    enum NftClass {
        BACKGROUND,
        DUMMY,
        WEARABLE
    }
    mapping(uint256 => NftClass) private _classes;
    mapping(address => uint256) private _dummyOwners;

    string public name = "XNft-collection-V2";
    string public symbol = "XNftV2";

    constructor() ERC1155("") {}

    function mint(
        address recipient,
        string memory tokenURI,
        NftClass class
    ) public onlyOwner returns (uint256) {
        if (class == NftClass.DUMMY && _dummyOwners[recipient] > 0) {
            revert("Only one dummy per address allowed");
        }

        if (class == NftClass.DUMMY) {
            _dummyOwners[recipient] += 1;
        }

        _nftIds.increment();

        uint256 nftId = _nftIds.current();

        _mint(recipient, nftId, 1, "");
        _setURI(nftId, tokenURI);
        _classes[nftId] = class;

        return nftId;
    }

    function mintBatch(
        address recipient,
        uint256[] memory amounts,
        string[] memory tokenURIs,
        NftClass[] memory classes
    ) public onlyOwner {
        uint256[] memory nftIds;
        uint256 dummies = 0;

        for (uint256 i = 0; i < amounts.length; i++) {
            _nftIds.increment();
            nftIds[i] = _nftIds.current();
            if (classes[i] == NftClass.DUMMY) {
                dummies += amounts[i];
            }

            _setURI(nftIds[i], tokenURIs[i]);
            _classes[nftIds[i]] = classes[i];
        }

        require(dummies <= 1, "Only one dummy per address allowed");

        _mintBatch(recipient, nftIds, amounts, "");
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
        for (uint256 i = 0; i < ids.length; i++) {
            require(
                _classes[ids[i]] != NftClass.DUMMY,
                "Unable to transfer dummy"
            );
        }
    }
}

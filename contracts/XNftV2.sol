// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract XNftV2 is ERC1155URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _nftIds;

    mapping(uint256 => mapping(uint256 => address)) private _owners;

    uint256 public constant DUMMY = 1;
    uint256 public constant WEARABLE = 2;

    string public name = "XNft-collection-V2";
    string public symbol = "XNftV2";

    constructor() ERC1155("") {}

    function mint(
        address recipient,
        uint256 tokenId,
        uint256 amount,
        string memory tokenURI
    ) public onlyOwner returns (uint256) {
        require(_validIds(_asSingletonArr(tokenId)), "Invalid token ID");
        _nftIds.increment();

        uint256 nftId = _nftIds.current();

        _mint(recipient, tokenId, amount, "");
        _owners[tokenId][nftId] = recipient;
        _setURI(nftId, tokenURI);

        return nftId;
    }

    function mintBatch(
        address recipient,
        uint256[] memory tokenIds,
        uint256[] memory amounts,
        string[] memory tokenURIs
    ) public onlyOwner {
        require(_validIds(tokenIds), "Invalid token ID");

        _mintBatch(recipient, tokenIds, amounts, "");

        for (uint256 i = 0; i < tokenIds.length; i++) {
            _nftIds.increment();
            uint256 nftId = _nftIds.current();

            _owners[tokenIds[i]][nftId] = recipient;
            _setURI(nftId, tokenURIs[i]);
        }
    }

    function _validIds(uint256[] memory tokenIds) internal pure returns (bool) {
        bool isValid = true;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            isValid = tokenIds[i] == DUMMY || tokenIds[i] == WEARABLE;
        }
        return isValid;
    }

    function _asSingletonArr(uint256 element)
        internal
        pure
        returns (uint256[] memory)
    {
        uint256[] memory array = new uint256[](1);
        array[0] = element;
        return array;
    }
}

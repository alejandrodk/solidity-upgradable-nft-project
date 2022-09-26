// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract XNftV2 is ERC1155URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _nftIds;

    enum NftType {
        BACKGROUND,
        DUMMY,
        WEARABLE
    }

    mapping(uint256 => NftType) private _typesById;
    mapping(address => uint256) private _dummyOwners;

    string public constant name = "XNft-collection-V2";
    string public constant symbol = "XNftV2";

    constructor() ERC1155("") {}

    modifier notContractCall() {
        require(tx.origin == msg.sender, "The caller is another contract");
        _;
    }

    modifier validMintBatchArguments(
        uint256[] memory amounts,
        NftType[] memory nftTypes,
        string[] memory tokenURIs
    ) {
        require(
            amounts.length == nftTypes.length &&
                amounts.length == tokenURIs.length,
            "Mint argument arrays must have same size"
        );
        _;
    }

    function mint(
        address recipient,
        string memory tokenURI,
        NftType nftType
    ) public onlyOwner notContractCall returns (uint256) {
        if (nftType == NftType.DUMMY && _dummyOwners[recipient] > 0) {
            revert("Only one dummy per address allowed");
        }

        if (nftType == NftType.DUMMY) {
            _dummyOwners[recipient] += 1;
        }

        _nftIds.increment();

        uint256 nftId = _nftIds.current();

        _mint(recipient, nftId, 1, "");
        _setURI(nftId, tokenURI);
        _typesById[nftId] = nftType;

        return nftId;
    }

    function mintBatch(
        address recipient,
        uint256[] memory amounts,
        NftType[] memory nftTypes,
        string[] memory tokenURIs
    )
        public
        onlyOwner
        notContractCall
        validMintBatchArguments(amounts, nftTypes, tokenURIs)
    {
        uint256[] memory nftIds = new uint256[](amounts.length);
        uint256 dummies;

        for (uint256 i = 0; i < nftTypes.length; i++) {
            require(dummies < 1, "Only one dummy per address allowed");

            if (nftTypes[i] == NftType.DUMMY) {
                require(amounts[i] <= 1, "Only one dummy per address allowed");
                dummies += amounts[i];
            }
        }

        delete dummies;

        for (uint256 i = 0; i < amounts.length; i++) {
            _nftIds.increment();
            nftIds[i] = _nftIds.current();

            _setURI(nftIds[i], tokenURIs[i]);
            _typesById[nftIds[i]] = nftTypes[i];
        }

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
                _typesById[ids[i]] != NftType.DUMMY,
                "Unable to transfer dummy"
            );
        }
    }
}

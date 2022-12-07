import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("UpgradableNft V2 Contract", () => {
  async function deployContractFixture() {
    const [owner, user, sender, receiver, ...others] =
      await ethers.getSigners();
    const accounts = { owner, user, sender, receiver, others };

    const UNFTV2 = await ethers.getContractFactory("UNFTV2");
    const uNftv2 = await UNFTV2.deploy();

    return { contract: uNftv2, accounts };
  }

  describe("Deployment", () => {
    it("Should deploy contract successfully", async () => {
      const { contract } = await loadFixture(deployContractFixture);

      expect(contract).not.null;
    });
  });

  describe("#mint", () => {
    it("Should allow only contract owner calls", async () => {
      const { contract, accounts } = await loadFixture(deployContractFixture);
      const { user, receiver } = accounts;

      await expect(
        contract.connect(user).mint(receiver.address, "https://...", 1)
      ).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("Should revert if caller already has a dummy", async () => {
      const { contract, accounts } = await loadFixture(deployContractFixture);
      const { receiver } = accounts;

      // mint a first dummy
      await contract.mint(receiver.address, "https://...", 1);

      await expect(
        contract.mint(receiver.address, "...", 1)
      ).to.be.revertedWith("Only one dummy per address allowed");
    });

    it("Should mint successfully", async () => {
      const { contract, accounts } = await loadFixture(deployContractFixture);
      const { receiver } = accounts;

      await expect(contract.mint(receiver.address, "...", 1)).to.emit(
        contract,
        "TransferSingle"
      );
    });
  });

  describe("#mintBatch", () => {
    it("Should revert if arguments aren't of the same length", async () => {
      const { contract, accounts } = await loadFixture(deployContractFixture);
      const { receiver } = accounts;

      await expect(
        contract.mintBatch(receiver.address, [1, 2], [1], ["..."])
      ).to.be.revertedWith("Mint argument arrays must have same size");
    });

    it("Should allow only contract owner calls", async () => {
      const { contract, accounts } = await loadFixture(deployContractFixture);
      const { user, receiver } = accounts;

      await expect(
        contract.connect(user).mintBatch(receiver.address, [1], [1], ["..."])
      ).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("Should revert if caller already has a dummy", async () => {
      const { contract, accounts } = await loadFixture(deployContractFixture);
      const { receiver } = accounts;

      // mint a first dummy
      await contract.mint(receiver.address, "...", 1);

      await expect(
        contract.mintBatch(receiver.address, [1], [1], ["..."])
      ).to.be.revertedWith("Only one dummy per address allowed");
    });

    it("Should revert if caller try to mint more of one dummy", async () => {
      const { contract, accounts } = await loadFixture(deployContractFixture);
      const { receiver } = accounts;

      await expect(
        contract.mintBatch(receiver.address, [1, 1], [1, 1], ["...", "..."])
      ).to.be.revertedWith("Only one dummy per address allowed");

      await expect(
        contract.mintBatch(receiver.address, [2], [1], ["..."])
      ).to.be.revertedWith("Only one dummy per address allowed");
    });

    it("Should mint a batch successfully", async () => {
      const { contract, accounts } = await loadFixture(deployContractFixture);
      const { receiver } = accounts;

      await expect(
        contract.mintBatch(receiver.address, [1], [1], ["..."])
      ).to.emit(contract, "TransferBatch");
    });
  });

  describe("#_beforeTokenTransfer", async () => {
    it("Should block dummy transfers", async () => {
      const { contract, accounts } = await loadFixture(deployContractFixture);
      const { receiver, user } = accounts;

      await contract.mint(receiver.address, "...", 1);

      await expect(
        contract
          .connect(receiver)
          .safeTransferFrom(receiver.address, user.address, 1, 1, [])
      ).to.be.revertedWith("NFT of type Dummy are not transferable");
    });

    it("Should allow not dummy transfers", async () => {
      const { contract, accounts } = await loadFixture(deployContractFixture);
      const { receiver, user } = accounts;

      await contract.mint(receiver.address, "...", 1);
      await contract.mint(receiver.address, "...", 2);

      await expect(
        contract
          .connect(receiver)
          .safeTransferFrom(receiver.address, user.address, 2, 1, [])
      ).to.emit(contract, "TransferSingle");
    });
  });

  // TODO: testear llamadas desde otros contratos
});

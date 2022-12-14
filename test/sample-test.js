const { ethers } = require('hardhat');
const { expect } = require('chai');
const { BigNumber } = require('ethers');
const { utils } = require('ethers');

describe('Halfsam', function () {
	let Halfsam;
	let halfsamctr;
	let HalfsamFactory;
	let halfsamfactoryCtr;
	let alice;
	let bob;
	let owner;
	let aliceProxyContract;
	const price = 0.0005;

	beforeEach(async () => {
		[owner, alice, bob] = await ethers.getSigners();
		Halfsam = await ethers.getContractFactory('Halfsam');
		halfsamctr = await Halfsam.deploy(owner.address);
		await halfsamctr.deployed();

		HalfsamFactory = await ethers.getContractFactory('HalfsamFactory');
		halfsamfactoryCtr = await HalfsamFactory.deploy(halfsamctr.address, owner.address);
		await halfsamfactoryCtr.deployed();

		await halfsamfactoryCtr.connect(alice).createInstance(alice.address, 'ALICE', 'ALC');
		aliceProxyContract = await Halfsam.attach(await halfsamfactoryCtr.getProxy(alice.address));
	});

	it('Master Contract should match exampleNFTContract', async function () {
		expect(await halfsamfactoryCtr.masterContract()).to.equal(halfsamctr.address);
	});

	it("Should match alice's initial token data", async function () {
		expect(await aliceProxyContract.name()).to.equal('ALICE');
		expect(await aliceProxyContract.symbol()).to.equal('ALC');
	});

	it('Public mint', async function () {
		await aliceProxyContract
			.connect(alice)
			.initializeCollection(utils.parseEther(price.toString()), 50, 5, );
		await aliceProxyContract.connect(alice).setMintPermissions(true);
		const collectionInfo = await aliceProxyContract.collectionInfo();
		expect(utils.formatEther(collectionInfo.price)).to.equals(price.toString());
		expect(collectionInfo.isPublicSaleActive).to.equals(true);
		await aliceProxyContract
			.connect(alice)
			.mint(bob.address, { value: utils.parseUnits(price.toString()) });
		expect(await aliceProxyContract.balanceOf(bob.address)).to.equals(1);
		const balance = await aliceProxyContract.provider.getBalance(aliceProxyContract.address);
		expect(utils.formatEther(balance)).to.equals(price.toString());
	});
	it('Can initializeCollectin more than once', async function () {
		await aliceProxyContract
			.connect(alice)
			.initializeCollection(utils.parseEther(price.toString()), 50, 5, );

		await aliceProxyContract
			.connect(alice)
			.initializeCollection(
				utils.parseEther((price + 0.0001).toFixed(4).toString()),
				50,
				5,
				
			);
		const collectionInfo = await aliceProxyContract.collectionInfo();
		expect(utils.formatEther(collectionInfo.price)).to.equals(
			(price + 0.0001).toFixed(4).toString()
		);
	});
	it('Batch Mint', async function () {
		await aliceProxyContract
			.connect(alice)
			.initializeCollection(utils.parseEther(price.toString()), 50, 5, );
		await aliceProxyContract.connect(alice).setMintPermissions(true);
		await aliceProxyContract
			.connect(alice)
			.mintBatch(bob.address, 2, { value: utils.parseUnits((price * 2).toString()) });
		const counter = await aliceProxyContract.tokenCounter();
		expect(counter.toNumber()).to.equals(2);
	});
});

const { expect } = require('chai')
const { ethers, waffle } = require('hardhat')
const { expectRevert, time, snapshot } = require('@openzeppelin/test-helpers')

const toETH = amt => ethers.utils.parseEther(String(amt))
const txValue = amt => ({ value: toETH(amt) })
const ethVal = n => Number(ethers.utils.formatEther(n))
const num = n => Number(n)

const getBalance = async a => ethVal(await ethers.provider.getBalance(a.address))

function times(t, fn) {
  const out = []
  for (let i = 0; i < t; i++) out.push(fn(i))
  return out
}

const utf8Clean = raw => raw.replace(/data.*utf8,/, '')
const b64Clean = raw => raw.replace(/data.*,/, '')
const b64Decode = raw => Buffer.from(b64Clean(raw), 'base64').toString('utf8')
const getJsonURI = rawURI => JSON.parse(utf8Clean(rawURI))
const getSVG = rawURI => b64Decode(JSON.parse(utf8Clean(rawURI)).image)



const ONE_DAY = 60 * 60 * 24
const TEN_MINUTES = 60 * 10
const ZERO_ADDR = '0x0000000000000000000000000000000000000000'
const safeTransferFrom = 'safeTransferFrom(address,address,uint256)'

const contractBalance = contract => contract.provider.getBalance(contract.address)







let planter, rando, OneMillionTrees

describe('OneMillionTrees', () => {
  beforeEach(async () => {
    const signers = await ethers.getSigners()

    planter = signers[0]
    rando = signers[1]


    const OneMillionTreesFactory = await ethers.getContractFactory('OneMillionTrees', planter)

    OneMillionTrees = await OneMillionTreesFactory.deploy()
    await OneMillionTrees.deployed()

  })



  describe('OneMillionTrees', () => {
    it('plant/replant should work', async () => {
      await OneMillionTrees.connect(planter).plant(10)
      expect(await OneMillionTrees.connect(planter).ownerOf(0)).to.equal(OneMillionTrees.address)

      await OneMillionTrees.connect(planter).replant(0)

      expect(await OneMillionTrees.connect(planter).ownerOf(0)).to.equal(planter.address)
      await expectRevert(OneMillionTrees.connect(rando).replant(0), 'Tree has already been replanted')
    })

    it('burning should work', async () => {
      await OneMillionTrees.connect(planter).plant(10)
      expect(await OneMillionTrees.connect(planter).ownerOf(0)).to.equal(OneMillionTrees.address)

      await OneMillionTrees.connect(planter).replant(0)

      await expectRevert(
        OneMillionTrees.connect(rando).burn(0),
        'TransferCallerNotOwnerNorApproved()'
      )
      await OneMillionTrees.connect(planter).burn(0)

      expect(await OneMillionTrees.connect(planter).exists(0)).to.equal(false)
      expect(num(await OneMillionTrees.connect(planter).totalSupply())).to.equal(9)
    })

    it('only owner should be able to update uri contract', async () => {

      await OneMillionTrees.connect(planter).plant(30_000)
      // console.log(
      //   getSVG(await OneMillionTrees.connect(planter).tokenURI(0))
      // )

      await OneMillionTrees.connect(planter).setTokenURI(rando.address)
      await expectRevert(
        OneMillionTrees.connect(rando).setTokenURI(rando.address),
        'Ownable: caller is not the owner'
      )


    })

    it('planting a lot of trees should work', async () => {
      await OneMillionTrees.connect(planter).plant(30_000)

    })

    it('planting all the trees should work', async () => {
      for (let t = 0; t < 1_000_000; t += 10_000) {
        await OneMillionTrees.connect(planter).plant(10_000)
      }

      expect(await OneMillionTrees.connect(planter).ownerOf(0)).to.equal(OneMillionTrees.address)
      expect(num(await OneMillionTrees.connect(planter).totalSupply())).to.equal(1_000_000)
      await expectRevert(
        OneMillionTrees.connect(planter).plant(1),
        'Can only plant 1 million trees'
      )

      await OneMillionTrees.connect(rando).replant(0)
      await OneMillionTrees.connect(rando).burn(0)
      expect(num(await OneMillionTrees.connect(planter).totalSupply())).to.equal(999_999)

      await expectRevert(
        OneMillionTrees.connect(rando).plant(1),
        'Can only plant 1 million trees'
      )
    })
  })
})


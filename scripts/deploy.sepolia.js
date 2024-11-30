const { time } = require('@openzeppelin/test-helpers')


async function main() {

  const signers = await ethers.getSigners()

  const planter = signers[0]
  const rando = signers[1]


  const OneMillionTreesFactory = await ethers.getContractFactory('OneMillionTrees', planter)

  const OneMillionTrees = await OneMillionTreesFactory.deploy()
  await OneMillionTrees.deployed()
  await OneMillionTrees.connect(planter).plant(10_000)




  console.log(`OneMillionTrees:`, OneMillionTrees.address)

}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
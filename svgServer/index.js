
const express = require('express')
const hardhat = require('hardhat')

const app = express()

app.get('/', async (_, res) => {
  try {
    // will recompile if there are changes
    await hardhat.run('compile')


    const Renderer = await hardhat.ethers.getContractFactory('SVGRenderer')
    const renderer = await Renderer.deploy(Math.floor(Math.random() * 100000000))
    await renderer.deployed()

    console.log(renderer.address)
    const svg = await renderer.render(1, false)

    // Will refresh every 1 second
    res.send(`
      <html>
      <head>
        <style>
          * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
          }

          body {

          }

          svg {

          }
        </style>
      </head>
      <body>
      ${svg}
      </body>
      <style>body{margin:0;padding:0;}</style>

      </html>
    `)
  } catch (e) {
    // in case you grab compiler errors
    res.send(`
      <html>
        <head>

        </head>
          ${e}
      </html>
  `)
  }
})

const PORT = process.env.PORT || 5005
app.listen(PORT, () => {
  console.log(`Serving SVG on port ${PORT}`)
})
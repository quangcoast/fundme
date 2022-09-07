//import

const { network } = require("hardhat")
const { networkConfig } = require("../helper-config-hardhat")
const {
    developmentChains,
    DECIMAL,
    INITIAL_ANSWER,
} = require("../helper-config-hardhat")

const { verify } = require("../utils/verify")


module.exports = async ({ getNamedAccounts, deployments }) => {
    //const { getNameAcounts, deployments } = hre
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId


    let ethUsdPricefeedAddress

    if (developmentChains.includes(network.name)) {
        const ethUsdAggregator = await deployments.get("MockV3Aggregator")
        ethUsdPricefeedAddress = ethUsdAggregator.address
    } else {
        ethUsdPricefeedAddress = networkConfig[chainId]["ethUsdPriceFeed"]
    }
    log("----------------------------------------------------")
    log("Deploying FundMe and waiting for confirmations...")
    //log(`FundMe deployed at ${network.chainId}`)


    const fundMe = await deploy("FundMe", {
        from: deployer,
        log: true,
        args: [ethUsdPricefeedAddress], //pricefeed address
        waitConfirmations: network.config.blockConfirmations || 1,
    })
    log(`FundMe deployed at ${fundMe.address}`)
     log(`FundMe chain at ${network.name}`)

     if (!developmentChains.includes(network.name) && process.env.ETHSCAN_API) {
        //log(`never at ${fundMe.address}`)
        await verify(fundMe.address, [ethUsdPricefeedAddress])
    }
}

module.exports.tags = ["all", "fundme"]

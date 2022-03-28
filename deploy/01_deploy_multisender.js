const fs = require('fs')

module.exports = async ({
    getNamedAccounts,
    deployments,
    getChainId
}) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = await getChainId()

    log("----------------------------------------------------")
    const MultiSender = await deploy('MultiSender', {
        from: deployer,
        log: true
    })
    log(`You have deployed contract to ${MultiSender.address}`)
}

module.exports.tags = ['all']
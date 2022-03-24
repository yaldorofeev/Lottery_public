(async () => {
    try {
        console.log('Running deployWithEthers script...')
    
        const contractName = 'Lottery_ERC20.sol' // Change this for other contract

        const constructorArgs = []    // Put constructor args (if any) here for your contract

        const artifactsPath = `browser/contracts/artifacts/Lotto.json` // Change this for different path
    
        const metadata = JSON.parse(await remix.call('fileManager', 'getFile', artifactsPath))

        const signer = (new ethers.providers.Web3Provider(web3Provider)).getSigner()
    
        let factory = new ethers.ContractFactory(metadata.abi, metadata.data.bytecode.object, signer);
    
        let contract = await factory.deploy(constructorArgs);
    
        console.log('Contract Address: ', contract.address);
    
        // The contract is NOT deployed yet; we must wait until it is mined
        await contract.deployed()
        console.log('Deployment successful.')
    } catch (e) {
        console.log(e.message)
    }
})()
(async () => {
    try {
        console.log('Running buyWithEthers script...')
    
        const contractAddress = ''

        accountBuyer = 0x00 

        const tokenPrice = 100

        const artifactsPath = `browser/contracts/artifacts/Lotto.json`
    
        const metadata = JSON.parse(await remix.call('fileManager', 'getFile', artifactsPath))

        const signer = (new ethers.providers.Web3Provider(web3Provider)).getSigner()

        signer.getAddress().then(
            function(account) {
                accountBuyer = account;
                console.log('accountAddress : ', account);
            }
        );
    
        let contract = new ethers.Contract(contractAddress, metadata.abi, signer);
    
        console.log('Connect to contract : ', contract.address);

        contract.buyTokens({
            from: accountBuyer,
            value: tokenPrice,
            gas: 300000000
            }
        ).then(function(result) {
            console.log("Tokens bought...")
            }
        );
    
        console.log('Deployment successful.')
    } catch (e) {
        console.log(e.message)
    }
})()
(async () => {
    try {
        const artifactsPath = `browser/contracts/artifacts/Lotto.json` // Change this for different path

        const contractAddress = "0x763482C4CccbF0cA73fd8CED1200fB78DE506506"

        const ticketPrice = 10000000000000000

        const tickets = ["https://gateway.pinata.cloud/ipfs/QmUhKnkrUmi5y1UXfa3nEyV6rYfp1ejjkeBDMRaS5EbQCK",
                "https://gateway.pinata.cloud/ipfs/Qmc2vBojiqExYGZY2NVZ8ATbe8haLzdr9sECpXDKq3wi5A",
                "https://gateway.pinata.cloud/ipfs/QmWRq8jQEBfesDuGGGXEh5rJ8Wea4bADvu7UKrf4uetuwA",
                "https://gateway.pinata.cloud/ipfs/QmQ4AUd6v16nBDE6e6DWJjmQ2nJ2qRuRt3ywexqDLYBAGu",
                "https://gateway.pinata.cloud/ipfs/QmXthVu2Q1ZkRDWvc8pVZ6hKYizYLnGQRFaShCGAb4FgGf"]
        const limitTimeDay = 1

        const limitTimeDay22 = 1
        
        const signer = (new ethers.providers.Web3Provider(web3Provider)).getSigner()
    
        accountSeller = 0x00

        signer.getAddress().then(
                function(account) {
                    accountSeller = account
                    console.log('accountSellerAddress : ', account);
                }
            );
        
        const metadata = JSON.parse(await remix.call('fileManager', 'getFile', artifactsPath));

        let factory = new ethers.ContractFactory(metadata.abi, metadata.data.bytecode.object, signer);

        let contract = await factory.attach(contractAddress);

        console.log('Connect to contract : ', contract.address);

        console.log('Contract name: ', contract.name);

        contract.mintTickets(ticketPrice, tickets, limitTimeDay, {
                from: accountSeller,
                // gas: 300000000000  
                }
            ).then(function(result) {
                console.log("Tickets minted...")
                }
            );
        
            console.log('Mint successful.')
    }catch (e) {
        console.log(e.message)
    }
})()

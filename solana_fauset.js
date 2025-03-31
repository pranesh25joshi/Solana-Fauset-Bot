import axios from 'axios';

const Wallet_Address = "9cV3D54tgGDxwXZeKUPt634diseVQETo56HoHejy6tAA"

const requireSol =async()=>{
    try{
        const respose = await axios.get("https://faucet.solana.com/request", {
      recipient: Wallet_Address,
      network: "devnet", // Change to "testnet" if needed
    });
    console.log("Response: ", respose.data);
    }
    catch(err){
        console.log("Error: ", err);
    }
}

requireSol();
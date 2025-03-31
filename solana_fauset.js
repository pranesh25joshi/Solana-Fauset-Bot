import axios from 'axios';

const Wallet_Address = "9cV3D54tgGDxwXZeKUPt634diseVQETo56HoHejy6tAA"

const requireSol =async()=>{
    try{
        const response = await axios.post("https://faucet.solplay.de/api/claim", {
      wallet: Wallet_Address,
      network: "devnet",
    },{
        headers: {
          'Content-Type': 'application/json'
        }
      });
    console.log("Fauset Response: ", response.data);
    }
    catch(err){
        console.log("Error: ", err);
    }
}

requireSol().then(() => console.log("Faucet request completed")).catch(() => console.log("Faucet request failed"));
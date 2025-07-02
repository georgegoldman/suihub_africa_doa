// deno-lint-ignore-file no-explicit-any
import { SuiClient } from "npm:@mysten/sui/client";
import { Transaction } from "npm:@mysten/sui/transactions";
import { Ed25519Keypair } from 'npm:@mysten/sui/keypairs/ed25519';
import "jsr:@std/dotenv/load";

const client  = new  SuiClient({
  url: "https://fullnode.testnet.sui.io:443"
})

const tx = new Transaction();
const packageID = "0x437f57575e57ba293d33ecfb136df440d2400ed36d9fed508dae8ce70267f57f"
const module = "votting_dao"
const doa_address = "0x656b3028d191453490e913e44c1cdfc529dea606e99494b60eaf73d991e3cbf1"
// const func = "join_dao"
// const args = [
//   tx.pure.address("0xe608d4aa565e961f0aeb475d1cbb778d27770c5127938070b5e0fe4c37486d59"),
//   tx.pure.string('Goldman')
// ]



const mnemonics = Deno.env.get("MNUMONIC")
const keypair = Ed25519Keypair.deriveKeypair(mnemonics as string)
const addr = keypair.toSuiAddress()


// type CallbackFn = () => void;

async function runDaoOps(args: Array<any>, func: string): Promise<any>{

  tx.moveCall({
    target: `${packageID}::${module}::${func}`,
    arguments: args,  
  })

  // tx.setGasPayment([tx.pure.address("0x0000000000000000000000000000000000000000000000000000000000000002")])
  return await client.signAndExecuteTransaction({
    transaction: tx,
    signer: keypair,
    options: {
      showEffects: true
    }
  });

}


const join_dao = await runDaoOps(
  [
      tx.object(doa_address),
      tx.pure.string("goldman"),
      tx.pure.string("goldman is a user 1 member"),
      tx.pure.string("https://res.cloudinary.com/georgegoldman/image/upload/v1751472928/apple-touch-icon_flxjra.png"),
      tx.pure.address("0xd1a03a00c0f3064139bb8a90562618466d87b9df8d2e943707328a16e2060b20")
  ], 
    "join_dao"
)

console.log(join_dao)



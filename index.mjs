import { loadStdlib } from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';

const stdlib = loadStdlib(process.env);

const startingBalance = stdlib.parseCurrency(100);
const accAlice = await stdlib.newTestAccount(startingBalance)
const accBob1 = await stdlib.newTestAccount(startingBalance)
const accBob2 = await stdlib.newTestAccount(startingBalance)
const accBob3 = await stdlib.newTestAccount(startingBalance)
const accBob4 = await stdlib.newTestAccount(startingBalance)
const accBob5 = await stdlib.newTestAccount(startingBalance)
const accBob6 = await stdlib.newTestAccount(startingBalance)
const accBob7 = await stdlib.newTestAccount(startingBalance)
const accBob8 = await stdlib.newTestAccount(startingBalance)
const steveNFT = await stdlib.launchToken(accAlice, "steveNFT", "SNFT1", { supply: 1 });

const ctcAlice = accAlice.contract(backend);

const TokenBalance = async (acc, name) => {
  const amtNFT = await stdlib.balanceOf(acc, steveNFT.id);
  console.log(`${name} has ${amtNFT} of the NFT`);
};

const Bobs = async (whoi, num, ans) => {
  try {
    const ctc = whoi.contract(backend, ctcAlice.getInfo());
    whoi.tokenAccept(steveNFT.id)
    const ticketnum = parseInt(num)
    await ctc.apis.Bob.bobs_inputs(ticketnum, ans);

  } catch (error) {
    console.log(error);
  }

}


console.log('Starting backends...');
await TokenBalance(accAlice, 'Alice')
await TokenBalance(accBob1, 'Bob1')
await TokenBalance(accBob2, 'Bob2')
await TokenBalance(accBob3, 'Bob3')
await TokenBalance(accBob4, 'Bob4')
await TokenBalance(accBob5, 'Bob5')
await TokenBalance(accBob6, 'Bob6')
await TokenBalance(accBob7, 'Bob7')
await TokenBalance(accBob8, 'Bob8')

await Promise.all([
  backend.Alice(ctcAlice, {
    ...stdlib.hasRandom,
    startprogram: async () => {
      console.log(`Program has started`)
      return {
        nftid: steveNFT.id,
        maxnumtickets: parseInt(8),
      }
    },
    question: async () => {
      const question = 'What is my name: '
      console.log(` The question : ${question}`)
      return question
    },
    answer: async () => {
      const answer = 'Alice'
      return answer
    },
    displayhash: async (value) => {
      console.log(` The hashed value of winning number: ${value}`)
    },
    winningticketnum: parseInt(83)
  }),
  await Bobs(accBob1, 22, 'Alice'),
  await Bobs(accBob2, 32, 'Helen'),
  await Bobs(accBob3, 11, 'Alice'),
  await Bobs(accBob4, 5, 'Alice'),
  await Bobs(accBob5, 83, 'Alice'),
  await Bobs(accBob6, 82, 'Alice'),
  await Bobs(accBob7, 15, 'Alice'),
  await Bobs(accBob8, 19, 'Alice'),
]);
await TokenBalance(accAlice, 'Alice')
await TokenBalance(accBob1, 'Bob1')
await TokenBalance(accBob2, 'Bob2')
await TokenBalance(accBob3, 'Bob3')
await TokenBalance(accBob4, 'Bob4')
await TokenBalance(accBob5, 'Bob5')
await TokenBalance(accBob6, 'Bob6')
await TokenBalance(accBob7, 'Bob7')
await TokenBalance(accBob8, 'Bob8')


process.exit()

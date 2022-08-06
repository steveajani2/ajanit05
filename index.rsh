'reach 0.1';
const [isOutcome, BOBWINNER, NOWINNER] = makeEnum(2)
const getwinner = (num1, num2) => {
  if (num1 === num2) {
    return BOBWINNER
  } else {
    return NOWINNER
  }
}
const enterraffle = (val1, val2) => {
  if (val1 === val2) {
    return true
  } else {
    return false
  }
}
assert(getwinner(4, 4) == BOBWINNER)
assert(getwinner(3, 2) == NOWINNER)
assert(enterraffle('james', 'james') == true)
assert(enterraffle('james', 'john') == false)
export const main = Reach.App(() => {
  const Alice = Participant('Alice', {
    ...hasRandom,
    displayhash: Fun([Digest], Null),
    winningticketnum: UInt,
    startprogram: Fun([], Object({
      nftid: Token,
      maxnumtickets: UInt,
    })),
    question: Fun([], Bytes(100)),
    answer: Fun([], Bytes(100))

  });
  const Bob = API('Bob', {
    bobs_inputs: Fun([UInt, Bytes(100)], Null)
  });
  init();

  Alice.only(() => {
    const { nftid, maxnumtickets } = declassify(interact.startprogram())
  })
  Alice.publish(nftid, maxnumtickets)
  commit()
  Alice.only(() => {
    const _winningticketnum = interact.winningticketnum
    const [_commitwinningticketnum, _saltwinningticketnum] = makeCommitment(interact, _winningticketnum)
    const commitwinningticketnum = declassify(_commitwinningticketnum)
  })
  Alice.publish(commitwinningticketnum)
  commit()

  Alice.only(() => {
    const viewhashvalue = declassify(interact.displayhash(commitwinningticketnum))
  })
  Alice.publish(viewhashvalue)
  commit()
  Alice.only(() => {
    const _answer = interact.answer()
    const [_commitanswer, _saltanswer] = makeCommitment(interact, _answer)
    const commitanswer = declassify(_commitanswer)
  })
  Alice.publish(commitanswer)
  const storeval = new Map(Address, UInt)
  const storeanswers = new Map(Address, Bytes(100))
  const a = Bytes(100).pad('names')
  const [i, address_list, ticketsnumber_list, answers_list] =
    parallelReduce([0, Array_replicate(8, Alice), Array_replicate(8, 8), Array_replicate(8, a)])
      .invariant(balance(nftid) == 0)
      .while(i < 8)
      .api(
        Bob.bobs_inputs,
        (tickets, answers, k) => {
          k(null)
          storeval[this] = tickets
          storeanswers[this] = answers
          return [i + 1, address_list.set(i, this), ticketsnumber_list.set(i, tickets), answers_list.set(i, answers)]
        }
      )
  commit()
  Alice.only(() => {
    const saltwinningticketnum = declassify(_saltwinningticketnum)
    const winningticketnum = declassify(_winningticketnum)
  })
  Alice.publish(saltwinningticketnum, winningticketnum)
  checkCommitment(commitwinningticketnum, saltwinningticketnum, winningticketnum)
  commit()
  Alice.only(() => {
    const saltanswer = declassify(_saltanswer)
    const answer = declassify(_answer)
  })
  Alice.publish(saltanswer, answer)
  checkCommitment(commitanswer, saltanswer, answer)
  var [usersid, address, ticketnumber, answers] = [0, address_list, ticketsnumber_list, answers_list]
  invariant(balance(nftid) == 0)
  while (usersid < 8) {
    commit()
    Alice.publish()
    const checkentry = enterraffle(answer, answers[usersid])
    if (checkentry) {
      commit()
      Alice.publish()
      const outcome = getwinner(winningticketnum, ticketnumber[usersid])
      if (outcome == BOBWINNER) {
        commit()
        Alice.pay([[1, nftid]])
        transfer([[1, nftid]]).to(address[usersid])
        usersid = usersid + 1
        continue
      } else {
        usersid = usersid + 1
        continue
      }

    } else {
      usersid = usersid + 1
      continue
    }

  }
  transfer(balance()).to(Alice)
  commit()
  exit();
});

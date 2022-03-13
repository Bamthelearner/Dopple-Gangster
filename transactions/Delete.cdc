transaction {

  prepare(acct: AuthAccount) {
      let test <- acct.load<@AnyResource>(from: /storage/DoppleGangsterComponent)
      destroy test
  }

  execute {

  }
}

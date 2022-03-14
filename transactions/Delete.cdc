import DoppleGangsterAdmin from "../contracts/DoppleGangsterAdmin.cdc"
import DoppleGangsterComponent from "../contracts/DoppleGangsterComponent.cdc"
import DoppleGangster from "../contracts/DoppleGangster.cdc"

transaction {

  prepare(acct: AuthAccount) {
      let test <- acct.load<@AnyResource>(from: DoppleGangsterComponent.CollectionStoragePath)
      destroy test

      let test2 <- acct.load<@AnyResource>(from: DoppleGangster.CollectionStoragePath)
      destroy test2

      let test3 <- acct.load<@AnyResource>(from: DoppleGangsterAdmin.AdminFunctionStoragePath)
      destroy test3

      let test4 <- acct.load<@AnyResource>(from: DoppleGangsterAdmin.AdminStoragePath)
      destroy test4
  }

  execute {

  }
}

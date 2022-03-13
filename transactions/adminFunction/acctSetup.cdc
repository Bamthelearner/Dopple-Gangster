import DoppleGangsterAdmin from "../../contracts/DoppleGangsterAdmin.cdc"
import DoppleGangsterComponent from "../../contracts/DoppleGangsterComponent.cdc"
import DoppleGangster from "../../contracts/DoppleGangster.cdc"

transaction () {

  prepare(acct: AuthAccount) {
    if acct.borrow<&DoppleGangsterComponent.Collection>(from: DoppleGangsterComponent.CollectionStoragePath) == nil {
      acct.save<@DoppleGangsterComponent.Collection>(<- DoppleGangsterComponent.createEmptyCollection(), to: DoppleGangsterComponent.CollectionStoragePath)
      acct.link<&{DoppleGangsterComponent.CollectionPublic}>(DoppleGangsterComponent.CollectionPublicPath, target: DoppleGangsterComponent.CollectionStoragePath)
    }
    if acct.borrow<&DoppleGangster.Collection>(from: DoppleGangster.CollectionStoragePath) == nil {
      acct.save<@DoppleGangster.Collection>(<- DoppleGangster.createEmptyCollection(), to: DoppleGangster.CollectionStoragePath)
      acct.link<&{DoppleGangster.CollectionPublic}>(DoppleGangster.CollectionPublicPath, target: DoppleGangster.CollectionStoragePath)
    }
  }

  execute {
    
  }
}

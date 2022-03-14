import DoppleGangsterAdmin from "../contracts/DoppleGangsterAdmin.cdc"
import DoppleGangsterComponent from "../contracts/DoppleGangsterComponent.cdc"
import DoppleGangster from "../contracts/DoppleGangster.cdc"

transaction (id: UInt64, category: String) {

  let collectionRef : &DoppleGangster.Collection
  let componentCollectionRef : &DoppleGangsterComponent.Collection

  prepare(acct: AuthAccount) {
    if acct.borrow<&DoppleGangsterComponent.Collection>(from: DoppleGangsterComponent.CollectionStoragePath) == nil {
      acct.save<@DoppleGangsterComponent.Collection>(<- DoppleGangsterComponent.createEmptyCollection(), to: DoppleGangsterComponent.CollectionStoragePath)
      acct.link<&{DoppleGangsterComponent.CollectionPublic}>(DoppleGangsterComponent.CollectionPublicPath, target: DoppleGangsterComponent.CollectionStoragePath)
    }
    if acct.borrow<&DoppleGangster.Collection>(from: DoppleGangster.CollectionStoragePath) == nil {
      acct.save<@DoppleGangster.Collection>(<- DoppleGangster.createEmptyCollection(), to: DoppleGangster.CollectionStoragePath)
      acct.link<&{DoppleGangster.CollectionPublic}>(DoppleGangster.CollectionPublicPath, target: DoppleGangster.CollectionStoragePath)
    }

    self.collectionRef = acct.borrow<&DoppleGangster.Collection>(from: DoppleGangster.CollectionStoragePath) ?? panic("You do not have the admin right")
    self.componentCollectionRef = acct.borrow<&DoppleGangsterComponent.Collection>(from: DoppleGangsterComponent.CollectionStoragePath) ?? panic("You do not have the admin right")


  
  }

  execute {

    let doppleGangsterRef = self.collectionRef.borrowDoppleGangsterNFT(id: id) 

    let oldComponent <- doppleGangsterRef.removeOptionalComponent(category: category)
    
    self.componentCollectionRef.deposit(token: <- oldComponent)

  }
}

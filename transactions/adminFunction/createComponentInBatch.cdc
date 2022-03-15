import DoppleGangsterAdmin from "../../contracts/DoppleGangsterAdmin.cdc"
import DoppleGangsterComponent from "../../contracts/DoppleGangsterComponent.cdc"
import DoppleGangster from "../../contracts/DoppleGangster.cdc"

transaction (templateId: UInt64, quantity: UInt64) {

  let adminFunctionRef : &{DoppleGangsterAdmin.AdminFunctionPrivate}
  let acctComponentCollectionRef : &DoppleGangsterComponent.Collection

  prepare(acct: AuthAccount) {
    if acct.borrow<&DoppleGangsterComponent.Collection>(from: DoppleGangsterComponent.CollectionStoragePath) == nil {
      acct.save<@DoppleGangsterComponent.Collection>(<- DoppleGangsterComponent.createEmptyCollection(), to: DoppleGangsterComponent.CollectionStoragePath)
      acct.link<&{DoppleGangsterComponent.CollectionPublic, MetadataViews.ResolverCollection}>(DoppleGangsterComponent.CollectionPublicPath, target: DoppleGangsterComponent.CollectionStoragePath)
    }
    if acct.borrow<&DoppleGangster.Collection>(from: DoppleGangster.CollectionStoragePath) == nil {
      acct.save<@DoppleGangster.Collection>(<- DoppleGangster.createEmptyCollection(), to: DoppleGangster.CollectionStoragePath)
      acct.link<&{DoppleGangster.CollectionPublic, MetadataViews.ResolverCollection}>(DoppleGangster.CollectionPublicPath, target: DoppleGangster.CollectionStoragePath)
    }

    let adminRef = acct.borrow<&DoppleGangsterAdmin.Admin>(from: DoppleGangsterAdmin.AdminStoragePath) ?? panic("You do not have the admin right")
    self.adminFunctionRef = adminRef.borrowAdmin()
    self.acctComponentCollectionRef = acct.borrow<&DoppleGangsterComponent.Collection>(from: DoppleGangsterComponent.CollectionStoragePath) ?? panic("Cannot borrow reference")
  }

  execute {
    let componentCollection <- self.adminFunctionRef.batchCreateComponents(templateId: templateId, quantity: quantity)
    self.acctComponentCollectionRef.batchDeposit(collection: <- componentCollection)

  }
}

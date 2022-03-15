import DoppleGangsterAdmin from "../contracts/DoppleGangsterAdmin.cdc"
import DoppleGangsterComponent from "../contracts/DoppleGangsterComponent.cdc"
import DoppleGangster from "../contracts/DoppleGangster.cdc"

transaction (name: String, series: UInt32, creationComponentIds: [UInt64]) {

  let collectionRef : &DoppleGangster.Collection
  let componentCollectionRef : &DoppleGangsterComponent.Collection
  var compulsoryComponents : @{String : DoppleGangsterComponent.NFT} 
  let creatorAddress : Address

  prepare(acct: AuthAccount) {
    if acct.borrow<&DoppleGangsterComponent.Collection>(from: DoppleGangsterComponent.CollectionStoragePath) == nil {
      acct.save<@DoppleGangsterComponent.Collection>(<- DoppleGangsterComponent.createEmptyCollection(), to: DoppleGangsterComponent.CollectionStoragePath)
      acct.link<&{DoppleGangsterComponent.CollectionPublic, MetadataViews.ResolverCollection}>(DoppleGangsterComponent.CollectionPublicPath, target: DoppleGangsterComponent.CollectionStoragePath)
    }
    if acct.borrow<&DoppleGangster.Collection>(from: DoppleGangster.CollectionStoragePath) == nil {
      acct.save<@DoppleGangster.Collection>(<- DoppleGangster.createEmptyCollection(), to: DoppleGangster.CollectionStoragePath)
      acct.link<&{DoppleGangster.CollectionPublic, MetadataViews.ResolverCollection}>(DoppleGangster.CollectionPublicPath, target: DoppleGangster.CollectionStoragePath)
    }

    self.collectionRef = acct.borrow<&DoppleGangster.Collection>(from: DoppleGangster.CollectionStoragePath) ?? panic("You do not have the admin right")
    self.componentCollectionRef = acct.borrow<&DoppleGangsterComponent.Collection>(from: DoppleGangsterComponent.CollectionStoragePath) ?? panic("You do not have the admin right")

    self.compulsoryComponents <- {}
    for id in creationComponentIds {
      let nft <- self.componentCollectionRef.withdraw(withdrawID: id) as! @DoppleGangsterComponent.NFT
      let category = nft.componentMetadata.category
      self.compulsoryComponents[category] <-! nft 
    }

    self.creatorAddress = acct.address
    
  }

  execute {
    self.collectionRef.deposit(token: <- DoppleGangster.createDoppleGangster(name: name, series: series, creatorAddress: self.creatorAddress, compulsoryComponents: <- self.compulsoryComponents))
  }
}

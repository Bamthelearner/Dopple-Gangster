import DoppleGangsterComponent from "../contracts/DoppleGangsterComponent.cdc"
import DoppleGangster from "../contracts/DoppleGangster.cdc"

pub fun main(acct: Address) : [UInt64] {

  let componentCollectionCap = getAccount(acct).getCapability<&{DoppleGangsterComponent.CollectionPublic}>(DoppleGangsterComponent.CollectionPublicPath)
  let componentCollectionRef = componentCollectionCap.borrow() ?? panic("Cannot get reference to the component Collection")

  let collectionCap = getAccount(acct).getCapability<&{DoppleGangster.CollectionPublic}>(DoppleGangster.CollectionPublicPath)
  let collectionRef = collectionCap.borrow() ?? panic("Cannot get reference to the DoppleGangster Collection")


  return collectionRef.getIDs()

} 
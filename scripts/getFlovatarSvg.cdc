import Flovatar from 0x921ea449dffec68a

pub fun main(acct: Address) : String {
  let flovatarCap = getAccount(acct).getCapability<&{Flovatar.CollectionPublic}>(Flovatar.CollectionPublicPath)
  let flovatarRef = flovatarCap.borrow() ?? panic("GG")

  let ids = flovatarRef.getIDs()

  let nftRef = flovatarRef.borrowFlovatar(id: 1225)
  return nftRef!.getSvg()

} 
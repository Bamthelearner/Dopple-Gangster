import DoppleGangsterAdmin from "../../contracts/DoppleGangsterAdmin.cdc"

transaction (targetAddr: Address) {

  let targetAddrAdminRef : &{DoppleGangsterAdmin.AdminPublic}
  let adminFunctionCap : Capability<&{DoppleGangsterAdmin.AdminFunctionPrivate}>

  prepare(acct: AuthAccount) {

    self.targetAddrAdminRef = getAccount(targetAddr)
                              .getCapability<&{DoppleGangsterAdmin.AdminPublic}>(DoppleGangsterAdmin.AdminPublicPath)
                              .borrow() 
                              ?? panic("Cannot borrow reference")
                              
    self.adminFunctionCap = acct.getCapability<&{DoppleGangsterAdmin.AdminFunctionPrivate}>(DoppleGangsterAdmin.AdminFunctionPrivatePath)

  }

  execute {
    self.targetAddrAdminRef.deposit(cap: self.adminFunctionCap)
  }
}

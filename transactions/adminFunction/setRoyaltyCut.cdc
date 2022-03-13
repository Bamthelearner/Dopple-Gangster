import DoppleGangsterAdmin from "../../contracts/DoppleGangsterAdmin.cdc"

transaction (cut: UFix64) {

  let adminFunctionRef : &{DoppleGangsterAdmin.AdminFunctionPrivate}

  prepare(acct: AuthAccount) {
    let adminRef = acct.borrow<&DoppleGangsterAdmin.Admin>(from: DoppleGangsterAdmin.AdminStoragePath) ?? panic("You do not have the admin right")
    self.adminFunctionRef = adminRef.borrowAdmin()
  }

  execute {
    self.adminFunctionRef.setRoyaltyCut(cut: cut)
  }
}

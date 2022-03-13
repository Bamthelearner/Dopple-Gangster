import DoppleGangsterAdmin from "../../contracts/DoppleGangsterAdmin.cdc"

transaction () {

  prepare(acct: AuthAccount) {
    if acct.borrow<&DoppleGangsterAdmin.Admin>(from: DoppleGangsterAdmin.AdminStoragePath) == nil {
      acct.save<@DoppleGangsterAdmin.Admin>(<- DoppleGangsterAdmin.createAdmin(), to: DoppleGangsterAdmin.AdminStoragePath)
      acct.link<&{DoppleGangsterAdmin.AdminPublic}>(DoppleGangsterAdmin.AdminPublicPath, target: DoppleGangsterAdmin.AdminStoragePath)
    }
    acct.link<&{DoppleGangsterAdmin.AdminPublic}>(DoppleGangsterAdmin.AdminPublicPath, target: DoppleGangsterAdmin.AdminStoragePath)
  }

  execute {

  }
}

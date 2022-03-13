import DoppleGangsterAdmin from "../../contracts/DoppleGangsterAdmin.cdc"
/* 
transaction (name: String, 
             description: String?, 
             compulsoryCategories: [String], 
             optionalCategories: [String],
             sequence: [String]) {

  let adminFunctionRef : &{DoppleGangsterAdmin.AdminFunctionPrivate}

  prepare(acct: AuthAccount) {
    let adminRef = acct.borrow<&DoppleGangsterAdmin.Admin>(from: DoppleGangsterAdmin.AdminStoragePath) ?? panic("You do not have the admin right")
    self.adminFunctionRef = adminRef.borrowAdmin()

  }

  execute {
    self.adminFunctionRef.createSeries(name: name, 
                                       description: description, 
                                       compulsoryCategories: compulsoryCategories, 
                                       optionalCategories: optionalCategories,
                                       sequence: sequence)
  }
}
*/
transaction{

  let adminFunctionRef : &{DoppleGangsterAdmin.AdminFunctionPrivate}

  prepare(acct: AuthAccount) {
    let adminRef = acct.borrow<&DoppleGangsterAdmin.Admin>(from: DoppleGangsterAdmin.AdminStoragePath) ?? panic("You do not have the admin right")
    self.adminFunctionRef = adminRef.borrowAdmin()

  }

  execute {
    self.adminFunctionRef.createSeries(name: "test", 
                                       description: "testdes", 
                                       compulsoryCategories: ["a"], 
                                       optionalCategories: ["b"],
                                       sequence: ["a", "b"])
  }
}
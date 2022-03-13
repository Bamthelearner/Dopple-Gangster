import DoppleGangsterAdmin from "../../contracts/DoppleGangsterAdmin.cdc"

/* 
transaction (name : String ,
             description : String? ,
             series : UInt32 ,
             category : String ,
             compulsory : Bool ,
             color : String ,
             svg : String ,
             rarity : String ,
             maxMintable : UInt64) {
  let adminFunctionRef : &{DoppleGangsterAdmin.AdminFunctionPrivate}

  prepare(acct: AuthAccount) {
    let adminRef = acct.borrow<&DoppleGangsterAdmin.Admin>(from: DoppleGangsterAdmin.AdminStoragePath) ?? panic("You do not have the admin right")
    self.adminFunctionRef = adminRef.borrowAdmin()

  }

  execute {
    self.adminFunctionRef.createTemplate(name : name ,
                                         description : description ,
                                         series : series ,
                                         category : category ,
                                         color : color ,
                                         svg : svg ,
                                         rarity : rarity ,
                                         maxMintable : maxMintable)  
  }
}

*/
transaction {
  let adminFunctionRef : &{DoppleGangsterAdmin.AdminFunctionPrivate}

  prepare(acct: AuthAccount) {
    let adminRef = acct.borrow<&DoppleGangsterAdmin.Admin>(from: DoppleGangsterAdmin.AdminStoragePath) ?? panic("You do not have the admin right")
    self.adminFunctionRef = adminRef.borrowAdmin()

  }

  execute {
    self.adminFunctionRef.createTemplate(name : "b1" ,
                                         description : "" ,
                                         series : 1 ,
                                         category : "b" ,
                                         color : "blue" ,
                                         svg : "b1svg" ,
                                         rarity : "common" ,
                                         maxMintable : 5)  
  }
}

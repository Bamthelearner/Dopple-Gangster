import DoppleGangsterComponentTemplate from "./DoppleGangsterComponentTemplate.cdc"
import DoppleGangsterComponent from "./DoppleGangsterComponent.cdc"
import DoppleGangster from "./DoppleGangster.cdc"

pub contract DoppleGangsterAdmin {

    pub let AdminFunctionStoragePath : StoragePath
    pub let AdminFunctionPrivatePath : PrivatePath
    pub let AdminStoragePath : StoragePath
    pub let AdminPublicPath : PublicPath

    pub resource interface AdminFunctionPrivate {
        pub fun createSeries(   name: String, 
                                description: String?, 
                                compulsoryCategories: [String], 
                                optionalCategories: [String],
                                sequence: [String])
        pub fun setCompulsoryCategory(series: UInt32, category: String, sequenceAfter: String?)
        pub fun setOptionalCategory(series: UInt32, category: String, sequenceAfter: String?)
        pub fun createTemplate(name : String ,
                                            description : String? ,
                                            series : UInt32 ,
                                            category : String ,
                                            color : String ,
                                            svg : String ,
                                            rarity : String ,
                                            maxMintable : UInt64)
        pub fun createComponent(templateId: UInt64) : @DoppleGangsterComponent.NFT 
        pub fun batchCreateComponents(templateId: UInt64, quantity: UInt64) : @DoppleGangsterComponent.Collection 
        pub fun setMarketplaceCut(cut: UFix64)
        pub fun setRoyaltyCut(cut: UFix64)
    }

    pub resource AdminFunction : AdminFunctionPrivate {
        //Admin function for DoppleGangsterComponentTemplate
        pub fun createSeries(   name: String, 
                                description: String?, 
                                compulsoryCategories: [String], 
                                optionalCategories: [String],
                                sequence: [String]) {
            DoppleGangsterComponentTemplate.createSeries(
                                name: name, 
                                description: description, 
                                compulsoryCategories: compulsoryCategories, 
                                optionalCategories: optionalCategories,
                                sequence: sequence
            )
        }

        pub fun setCompulsoryCategory(series: UInt32, category: String, sequenceAfter: String?) {
            DoppleGangsterComponentTemplate.setCompulsoryCategory(
                series: series, category: category, sequenceAfter: sequenceAfter)
        }

        pub fun setOptionalCategory(series: UInt32, category: String, sequenceAfter: String?) {
            DoppleGangsterComponentTemplate.setOptionalCategory(
                series: series, category: category, sequenceAfter: sequenceAfter)
        }

        pub fun createTemplate(name : String ,
                                            description : String? ,
                                            series : UInt32 ,
                                            category : String ,
                                            color : String ,
                                            svg : String ,
                                            rarity : String ,
                                            maxMintable : UInt64){
            DoppleGangsterComponentTemplate.createTemplate(name : name ,
                                            description : description ,
                                            series : series ,
                                            category : category ,
                                            color : color ,
                                            svg : svg ,
                                            rarity : rarity ,
                                            maxMintable : maxMintable)
        }   

        //Admin function for DoppleGangsterComponent 
        pub fun createComponent(templateId: UInt64) : @DoppleGangsterComponent.NFT {
            return <- DoppleGangsterComponent.createComponent(templateId: templateId)
        }

        pub fun batchCreateComponents(templateId: UInt64, quantity: UInt64) : @DoppleGangsterComponent.Collection {
            return <- DoppleGangsterComponent.batchCreateComponents(templateId: templateId, quantity: quantity)
        }

        //Admin Funciton for DoppleGangster
        pub fun setMarketplaceCut(cut: UFix64){
            DoppleGangster.setMarketplaceCut(cut: cut)
        }

        pub fun setRoyaltyCut(cut: UFix64){
            DoppleGangster.setRoyaltyCut(cut: cut)
        }




        init(){

        }

    }

    pub resource interface AdminPublic {
        pub fun deposit(cap: Capability<&{AdminFunctionPrivate}>)
    }

    pub resource Admin : AdminPublic{
        access(contract) var adminCap : Capability<&{AdminFunctionPrivate}>?

        pub fun borrowAdmin(): &{AdminFunctionPrivate} {
            pre{
                self.adminCap != nil : "You do not own the admin Capability"
            }
            let adminRef = self.adminCap!.borrow() ?? panic ("Cannot borrow the admin function reference")
            return adminRef
        }

        pub fun deposit(cap: Capability<&{AdminFunctionPrivate}>) {
            self.adminCap = cap
        }

        init(){
            self.adminCap = nil
        }
    }

    //Admin Resource
    pub fun createAdmin() : @Admin {
        return <- create Admin()
    }

    init(){
        self.AdminFunctionStoragePath = /storage/DoppleGangsterAdminFunction
        self.AdminFunctionPrivatePath = /private/DoppleGangsterAdminFunction
        self.AdminStoragePath = /storage/DoppleGangsterAdmin
        self.AdminPublicPath = /public/DoppleGangsterAdmin

        //self.account.save<@DoppleGangsterAdmin.AdminFunction>(<- create AdminFunction(), to: DoppleGangsterAdmin.AdminFunctionStoragePath)
        self.account.link<&{DoppleGangsterAdmin.AdminFunctionPrivate}>(DoppleGangsterAdmin.AdminFunctionPrivatePath, target: DoppleGangsterAdmin.AdminFunctionStoragePath)

    }

}
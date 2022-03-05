import MetadataViews from "./MetadataViews.cdc"

pub contract DoppleGangsterComponentTemplate {

    pub let CollectionStoragePath : StoragePath 
    pub let CollectionPublicPath : PublicPath 
    pub let CollectionPrivatePath : PrivatePath  

    pub var totalSupply : UInt64

    access(contract) var totalMintedComponents : {UInt64 : UInt64}

    access(contract) var totalSeries : {UInt64 : SeriesData}

    init(){
        self.CollectionStoragePath = /storage/DoppleGangsterComponentTemplateCollection
        self.CollectionPublicPath = /public/DoppleGangsterComponentTemplateCollection
        self.CollectionPrivatePath = /private/DoppleGangsterComponentTemplateCollection

        self.totalSupply = 0

        self.totalMintedComponents = {}
        self.totalSeries = {}
    }

    /* This struct stores all Component Template Data under each series */
    /* Component between each series cannot be merged together */
    /* Component between series can be with different catalogue */
    pub struct SeriesData{
        pub let series : UInt32
        pub let name : String
        pub let description : String?

        pub var compulsoryCategories : {String : [UInt64]}
        pub var optionalCategories :  {String : [UInt64]}

        pub var displaySequence : [String]

        init(   name: String, 
                description: String?, 
                compulsoryCategories: {String : [UInt64]}, 
                optionalCategories: {String : [UInt64]},
                sequence: [String]
            ){
                self.series = UInt32(DoppleGangsterComponentTemplate.totalSeries.length) + 1

                /* abort if name = "" or name is already taken */
                assert(name != "", message: "Name cannot be blank" )
                assert(!DoppleGangsterComponentTemplate.getSeriesNames.contains(name), message: "Name is already taken")
                self.name = name
                self.description = description

                /* abort if key in compulsory category is also in optional */
                for key in compulsoryCategories.keys{
                    assert(!optionalCategories.keys.contains(key), message: "Duplicated category in compulsory and optional")
                }
                self.compulsoryCategories = compulsoryCategories
                self.optionalCategories = optionalCategories

                /* abort if sequence is not equal to all categories */
                for category in compulsoryCategories{
                    asset(sequence.contains(categories), message: "This display sequence does not include all compulsory categories")
                }

                for category in optionalCategories{
                    asset(sequence.contains(categories), message: "This display sequence does not include all optional categories")
                }

                assert(sequence.length = compulsoryCategories.keys.length + optionalCategories.keys.length, message: "This display sequence does not include all categories") )
                self.idisplaySequence = sequence

             }
        }

        pub struct TemplateMetaData{
            pub let id : UInt64
            pub let name : String
            pub let description : String? 
            pub let series : UInt32 
            pub let category : String 
            pub let compulsory : Bool 
            pub let color : String 
            pub let svg : String 
            pub let rarity : String 
            pub let maxMintable : UInt64

            init(
                id : UInt64 ,
                name : String ,
                description : String? ,
                series : UInt32 ,
                category : String ,
                compulsory : Bool ,
                color : String ,
                svg : String ,
                rarity : String ,
                maxMintable : UInt64,
            ){
                self.id = id
                self.name = name
                self.description = description 
                self.series = series 
                self.category = category 
                self.compulsory = compulsory 
                self.color = color 
                self.svg = svg
                self.rarity = rarity 
                self.maxMintable = maxMintable
            }
        }


        pub resource interface Public{

        }

        pub resource Template : Public{
            pub let id : UInt64 
            pub let template
        }


    }





}
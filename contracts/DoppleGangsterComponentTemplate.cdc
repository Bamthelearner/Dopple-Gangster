import MetadataViews from "./MetadataViews.cdc"


pub contract DoppleGangsterComponentTemplate {

    pub event ContractInitialized()
    pub event CreatedSeries(series:UInt32, 
                           name: String, 
                           description: String?, 
                           compulsoryCategories: {String : [UInt64]}, 
                           optionalCategories: {String : [UInt64]}, 
                           equence: [String])
    pub event Created(id: UInt64, name: String, category: String, color: String, maxMintableComponents: UInt64)

    pub let CollectionStoragePath : StoragePath 
    pub let CollectionPublicPath : PublicPath 
    pub let CollectionPrivatePath : PrivatePath  

    pub var totalSupply : UInt64

    access(contract) var totalMintedComponents : {UInt64 : UInt64}

    access(contract) var totalSeries : {UInt32 : SeriesData}
    access(contract) var ownedTemplates: @{UInt64 : Template}

    init(){
        self.CollectionStoragePath = /storage/DoppleGangsterComponentTemplateCollection
        self.CollectionPublicPath = /public/DoppleGangsterComponentTemplateCollection
        self.CollectionPrivatePath = /private/DoppleGangsterComponentTemplateCollection

        self.totalSupply = 0

        self.totalMintedComponents = {}
        self.totalSeries = {}
        self.ownedTemplates <- {}
    }

    /* This struct stores all Component Template Data under each series */
    /* Component between each series cannot be merged together */
    /* Component between series can be with different catalogue */
    pub struct SeriesData{
        pub let series : UInt32
        pub let name : String
        pub let description : String?

        access(contract) var compulsoryCategories : {String : [UInt64]}
        access(contract) var optionalCategories :  {String : [UInt64]}

        access(contract) var displaySequence : [String]

        init(   series:UInt32, 
                name: String, 
                description: String?, 
                compulsoryCategories: {String : [UInt64]}, 
                optionalCategories: {String : [UInt64]},
                sequence: [String]
            ){
                self.series = series
                self.name = name
                self.description = description
                self.compulsoryCategories = compulsoryCategories
                self.optionalCategories = optionalCategories
                self.displaySequence = sequence

        }

        access(contract) fun setCompulsoryCategory(category: String, sequenceAfter: String?){
            pre{
                self.compulsoryCategories[category] == nil : "The category creating is not nil"
                sequenceAfter == nil || self.displaySequence.contains(sequenceAfter!) : "The target to place infront of does not exist"
            }
            self.compulsoryCategories[category] = []
            var counter = 0
            for cat in self.displaySequence{
                if sequenceAfter == cat{
                    self.displaySequence.insert(at: counter, category)
                }
                counter = counter + 1
            }
        }

        access(contract) fun setOptionalCategory(category: String, sequenceAfter: String?){
            pre{
                self.optionalCategories[category] == nil : "The category creating is not nil"
                sequenceAfter == nil || self.displaySequence.contains(sequenceAfter!) : "The target to place infront of does not exist"
            }
            self.optionalCategories[category] = []
            var counter = 0
            for cat in self.displaySequence{
                if sequenceAfter == cat{
                    self.displaySequence.insert(at: counter, category)
                }
                counter = counter + 1
            }
        }

    }

    // Declare svg thumbnail type for MetadataViews
    pub struct SVGFile : MetadataViews.File {
        pub let svg : String
        init(_svg : String){
            self.svg = _svg
        }
        pub fun uri() : String {
            return self.svg
        }
    }

    pub struct TemplateMetadata{
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
            maxMintable : UInt64
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

    pub resource Template : MetadataViews.Resolver{
        pub let id : UInt64 
        pub let template : DoppleGangsterComponentTemplate.TemplateMetadata
        init(   name : String ,
                description : String? ,
                series : UInt32 ,
                category : String ,
                compulsory : Bool ,
                color : String ,
                svg : String ,
                rarity : String ,
                maxMintable : UInt64){
            DoppleGangsterComponentTemplate.totalSupply = DoppleGangsterComponentTemplate.totalSupply + 1
            self.id = DoppleGangsterComponentTemplate.totalSupply
            self.template = TemplateMetadata(   id : self.id ,
                                                name : name ,
                                                description : description ,
                                                series : series ,
                                                category : category ,
                                                compulsory : compulsory ,
                                                color : color ,
                                                svg : svg ,
                                                rarity : rarity ,
                                                maxMintable : maxMintable)
        }
        /* MetadataViews Implementation */ 
        pub fun getViews(): [Type]{
            return [Type<MetadataViews.Display>(), 
                    Type<DoppleGangsterComponentTemplate.TemplateMetadata>()]
        }
        pub fun resolveView(_ view: Type): AnyStruct? {
            switch view {
                case Type<MetadataViews.Display>():
                    return MetadataViews.Display(
                    name : self.template.name ,
                    description : self.template.description! ,
                    thumbnail : SVGFile(_svg : self.template.svg)
                    )
                
                case Type<DoppleGangsterComponentTemplate.TemplateMetadata>():
                    return self.template
            } 
            return nil
        }
    }

    /* Function for Template Management (Similar to collections) */ 
    pub fun getIDs(): [UInt64] {
        return self.ownedTemplates.keys 
    }

    access(account) fun deposit(token: @Template){
        let id = token.id
        self.ownedTemplates[id] <-! token
    }

    pub fun borrowDoppleGangsterTemplate(id: UInt64) : &Template {
        pre{
            self.ownedTemplates[id] != nil : "This template does not exist"
        }
        return &self.ownedTemplates[id] as &Template
    }

    /* MetadataViews Implementation */
    pub fun borrowViewResolver(id: UInt64): &{MetadataViews.Resolver} {
        pre{
            self.ownedTemplates[id] != nil : "This template does not exist"
        }
        let template = &self.ownedTemplates[id] as &Template
        return template as &{MetadataViews.Resolver}
    }

            
        

    /* Contract Functions */ 
    pub fun getSeries() : {UInt32 : String} {
        var series : {UInt32 : String} = {}
        for id in self.totalSeries.keys{
            series[id] = self.totalSeries[id]!.name
        }
        return series
    }

    pub fun getSeriesData(series : UInt32) : SeriesData? {
        return self.totalSeries[series]
    }

    pub fun getCategoriesInSequence(series: UInt32) : [String] {
        pre{
            self.totalSeries[series] != nil : "This series does not exist"
        }
        let seriesData = self.totalSeries[series]!
        var sequence : [String] = seriesData.displaySequence
        var index : UInt64 = 0
        return sequence
    }

    pub fun getCompulsoryCategories(series: UInt32) : [String] {
        pre{
            self.totalSeries[series] != nil : "This series does not exist"
        }
        let seriesData = self.totalSeries[series]!
        var sequence : [String] = seriesData.compulsoryCategories.keys
        var index : UInt64 = 0
        return sequence
    }

    pub fun getOptionalCategories(series: UInt32) : [String] {
        pre{
            self.totalSeries[series] != nil : "This series does not exist"
        }
        let seriesData = self.totalSeries[series]!
        var sequence : [String] = seriesData.optionalCategories.keys
        var index : UInt64 = 0
        return sequence
    }

    pub fun getComponentsBySeries(series: UInt32): [UInt64] {
        pre{
            self.totalSeries[series] != nil : "This series does not exist"
        }

        var componentID : [UInt64] = []
        let seriesData = self.totalSeries[series]!
        for category in seriesData.compulsoryCategories.keys{
            componentID.appendAll(seriesData.compulsoryCategories[category]!)
        }

        for category in seriesData.optionalCategories.keys{
            componentID.appendAll(seriesData.optionalCategories[category]!)
        }
        return componentID
    }

    pub fun getComponentsByCategory(series: UInt32, category: String) : [UInt64] {
        pre{
            self.totalSeries[series] != nil : "This series does not exist"
        }

        let seriesData = self.totalSeries[series]!
        
        if seriesData.compulsoryCategories.keys.contains(category) {
            return seriesData.compulsoryCategories[category]!
        } else if seriesData.optionalCategories.keys.contains(category) {
            return seriesData.optionalCategories[category]!
        } else {
            return []
        }
    }

    /* Admin Functions (to be called only be Admin resource in separate contract) */
    access(account) fun createSeries(   name: String, 
                                        description: String?, 
                                        compulsoryCategories: [String], 
                                        optionalCategories: [String],
                                        sequence: [String]) {

        let series = UInt32(self.totalSeries.length + 1)

        /* Checking session */
        /* abort if name = "" or name is already taken */
        assert(name != "", message: "Name cannot be blank" )
        assert(!DoppleGangsterComponentTemplate.getSeries().values.contains(name), message: "Name is already taken")

        /* abort if key in compulsory category is also in optional */
        for key in compulsoryCategories{
            assert(!optionalCategories.contains(key), message: "Duplicated category in compulsory and optional")
        }

        /* abort if sequence is not equal to all categories */
        for category in compulsoryCategories{
            assert(sequence.contains(category), message: "This display sequence does not include all compulsory categories")
        }

        for category in optionalCategories{
            assert(sequence.contains(category), message: "This display sequence does not include all optional categories")
        }

        assert(sequence.length == compulsoryCategories.length + optionalCategories.length, message: "This display sequence does not include all categories") 

        var compulsory : {String : [UInt64]}= {}
        var optional : {String : [UInt64]}= {}

        for category in compulsoryCategories {
            compulsory[category] = []
        }

        for category in optionalCategories {
            optional[category] = []
        }

        let seriesInfo = SeriesData(series:series, name: name, description: description, compulsoryCategories: compulsory, optionalCategories: optional, sequence: sequence)
        self.totalSeries[series] = seriesInfo
        emit CreatedSeries(series:seriesInfo.series, 
                           name: seriesInfo.name, 
                           description: seriesInfo.description, 
                           compulsoryCategories: seriesInfo.compulsoryCategories, 
                           optionalCategories: seriesInfo.optionalCategories, 
                           equence: seriesInfo.displaySequence)

    }

    // set 1 Compulsory Category, input sequenceAfter with an existing category to set the display priority. 
    // if sequenceAfter is nil, it will be set at the very first
    access(account) fun setCompulsoryCategory(series: UInt32, category: String, sequenceAfter: String?) {
        pre{
            self.totalSeries[series] != nil : "This series does not exist"
        }

        self.totalSeries[series]!.setCompulsoryCategory(category: category, sequenceAfter: sequenceAfter)
    }

    // set Compulsory Category in batch, input sequenceAfter with an existing category to set the display priority. 
    // if sequenceAfter is nil, it will be set at the very first
    access(account) fun setCompulsoryCategoriesByBatch(series: UInt32, categories: [String], sequenceAfter: [String?]) {
        pre{
            self.totalSeries[series] != nil : "This series does not exist"
            categories.length == sequenceAfter.length : "The length of categories does not match with the length of sequenceAfter array"
        }

        var index = 0
        for category in categories {
            self.totalSeries[series]!.setCompulsoryCategory(category: category, sequenceAfter: sequenceAfter[index])
        }

    }

    // set 1 Optional Category, input sequenceAfter with an existing category to set the display priority. 
    // if sequenceAfter is nil, it will be set at the very first
    access(account) fun setOptionalCategory(series: UInt32, category: String, sequenceAfter: String?) {
        pre{
            self.totalSeries[series] != nil : "This series does not exist"
        }

        self.totalSeries[series]!.setOptionalCategory(category: category, sequenceAfter: sequenceAfter)
    }

    // set Optional Category in batch, input sequenceAfter with an existing category to set the display priority. 
    // if sequenceAfter is nil, it will be set at the very first
    access(account) fun setOptionalCategoriesByBatch(series: UInt32, categories: [String], sequenceAfter: [String?]) {
        pre{
            self.totalSeries[series] != nil : "This series does not exist"
            categories.length == sequenceAfter.length : "The length of categories does not match with the length of sequenceAfter array"
        }

        var index = 0
        for category in categories {
            self.totalSeries[series]!.setOptionalCategory(category: category, sequenceAfter: sequenceAfter[index])
        }

    }

    access(account) fun createTemplate(name : String ,
                                        description : String? ,
                                        series : UInt32 ,
                                        category : String ,
                                        color : String ,
                                        svg : String ,
                                        rarity : String ,
                                        maxMintable : UInt64){
    
        pre{
            self.totalSeries[series] != nil : "This series does not exist"
        }

        /* Check if the name and svg exist in this series */
        for id in self.getComponentsBySeries(series: series){
            let templateRef = DoppleGangsterComponentTemplate.borrowDoppleGangsterTemplate(id: id)
            assert(templateRef.template.name == name, message : "This name is already taken in this series by other component")
            assert(templateRef.template.svg == svg, message : "This svg is already used in this series by other component")
        }

        /* Check if the category exist in this series */
        let seriesData = self.totalSeries[series]!
        var compulsory : Bool? = nil
        assert(seriesData.displaySequence.contains(category), message : "This category does not exist in this series")
        if seriesData.compulsoryCategories.keys.contains(category) {
            compulsory = true
        }
        if seriesData.optionalCategories.keys.contains(category) {
            compulsory = false
        }
        

        let templateResource <- create Template(name : name ,
                                                description : description ,
                                                series : series ,
                                                category : category ,
                                                compulsory : compulsory! ,
                                                color : color ,
                                                svg : svg ,
                                                rarity : rarity ,
                                                maxMintable : maxMintable)

        self.totalMintedComponents[templateResource.id] = 0

        self.deposit(token: <- templateResource)
    }

    pub fun getTotalMintedComponents(id: UInt64) : UInt64? {
        return self.totalMintedComponents[id]
    }

    pub fun getComponentMaxMintable(id: UInt64) : UInt64? {
        let templateMetadata = self.borrowDoppleGangsterTemplate(id: id).template
        return templateMetadata.maxMintable
    }

    access(contract) fun setTotalMintedComponents(id: UInt64) {
        pre{
            self.totalMintedComponents[id]  != nil : "This component does not exist" 
        }
        self.totalMintedComponents[id] = self.totalMintedComponents[id]! + 1
    }
}
import NonFungibleToken from "./NonFungibleToken.cdc"
import MetadataViews from "./MetadataViews.cdc"
import DoppleGangsterComponentTemplate from "./DoppleGangsterComponentTemplate.cdc"
import DoppleGangsterComponent from "./DoppleGangsterComponent.cdc"
import FungibleToken from "./FungibleToken.cdc"
import FlowToken from "./FlowToken.cdc"

pub contract DoppleGangster: NonFungibleToken{
  pub var totalSupply : UInt64
  
  pub let CollectionStoragePath : StoragePath
  pub let CollectionPublicPath : PublicPath
  pub let CollectionPrivatePath : PrivatePath

  // keep track of all addresses that have DoppleGangsters
  access(contract) var nftHolder : {Address : [UInt64]}
  // keep track of all components on a DoppleGangster
  access(contract) var componentsOnNFT : {UInt64 : [UInt64]}

  // These will be used in the Marketplace to pay out 
  // royalties to the creator and to the marketplace
  access(account) var royaltyCut: UFix64
  access(account) var marketplaceCut: UFix64

  pub event ContractInitialized()
  pub event Withdraw(id: UInt64, from: Address?)
  pub event Deposit(id: UInt64, to: Address?)
  pub event Changed(id: UInt64, componentId: [UInt64]) 
  pub event Created(id: UInt64, series: UInt32, creatorAddress: Address, componentId: [UInt64])

  pub struct Royalty{
    pub let wallet:Capability<&{FungibleToken.Receiver}> 
    pub let cut: UFix64

    init(wallet:Capability<&{FungibleToken.Receiver}>, cut: UFix64 ){
        self.wallet=wallet
        self.cut=cut
    }
  }

  pub struct Metadata {
    pub let id : UInt64
    pub let name : String
    pub let series : UInt32
    pub let creatorAddress : Address
    pub let compulsoryComponents : {String : DoppleGangsterComponent.ComponentMetadata}
    pub let optionalComponents : {String : DoppleGangsterComponent.ComponentMetadata}

    init(id : UInt64 , 
         name : String ,
         series : UInt32 ,
         creatorAddress : Address ,
         compulsoryComponents : {String : DoppleGangsterComponent.ComponentMetadata} ,
         optionalComponents : {String : DoppleGangsterComponent.ComponentMetadata}
      ) {
      self.id = id
      self.name = name
      self.series = series
      self.creatorAddress = creatorAddress
      self.compulsoryComponents = compulsoryComponents
      self.optionalComponents = optionalComponents
    }

    pub fun getAllComponentMetadata() : {String : DoppleGangsterComponent.ComponentMetadata} {
      var allComponentMetadata : {String : DoppleGangsterComponent.ComponentMetadata} = {}
      
      for components in self.compulsoryComponents.keys{
        allComponentMetadata[components] = self.compulsoryComponents[components]
      }

      for components in self.optionalComponents.keys{
        allComponentMetadata[components] = self.optionalComponents[components]
      }

      return allComponentMetadata
    }

    pub fun getAllComponentIDs() : [UInt64] {
      var ids : [UInt64] = []
      let componentMetadata = self.getAllComponentMetadata()
      for catInComponent in componentMetadata.keys {
        ids.append(componentMetadata[catInComponent]!.id)
      }
      return ids
    }

    pub fun getDoppleGangsterSvg() : [String?] {
      let series = self.series
      let allComponentMetadata = self.getAllComponentMetadata()
      var svg : [String?] = []
      var matchedCat : String? = nil
      for catInSequence in DoppleGangsterComponentTemplate.getCategoriesInSequence(series: series) {
        for catInMetadata in allComponentMetadata.keys {
          if catInSequence == catInMetadata {
            matchedCat = catInSequence
            break
          } else {
            matchedCat = nil
          }
        }

        if matchedCat != nil {
          svg.append(allComponentMetadata[matchedCat!]!.svg)
        } else {
          svg.append(matchedCat)
        }
      }
      return svg
    }

    pub fun checkOptionalComponent(category: String) : Bool {
      return self.optionalComponents.containsKey(category)
    }

  }

  pub resource interface Public {
    pub let id : UInt64
    pub let name : String
    pub let series : UInt32
    pub let creatorAddress : Address
    access(contract) let royalties : [Royalty]


    pub fun getDoppleGangsterSvg() : String
    pub fun getAllComponentMetadata() : {String : DoppleGangsterComponent.ComponentMetadata}
    pub fun getAllComponentIDs() : [UInt64]
    pub fun checkOptionalComponent(category: String) : Bool 

  }

  pub resource NFT : NonFungibleToken.INFT , Public , MetadataViews.Resolver{
    pub let id : UInt64
    pub let name : String
    pub let series : UInt32
    pub let creatorAddress : Address
    access(contract) var compulsoryComponents : @{String : DoppleGangsterComponent.NFT} 
    access(contract) var optionalComponents : @{String : DoppleGangsterComponent.NFT}

    access(contract) let royalties : [Royalty]

    init(creatorAddress: Address, series: UInt32, compulsoryComponents : @{String : DoppleGangsterComponent.NFT}, royalties: [Royalty]) {
      
      self.id = self.uuid
      self.name = ""
      self.series = series
      self.creatorAddress = creatorAddress
      self.compulsoryComponents <- compulsoryComponents
      self.optionalComponents <- {}

      self.royalties =royalties
    }

    destroy () {
      destroy self.compulsoryComponents
      destroy self.optionalComponents
    }

    pub fun getAllComponentMetadata() : {String : DoppleGangsterComponent.ComponentMetadata} {
      var allComponentMetadata : {String : DoppleGangsterComponent.ComponentMetadata} = {}
      
      for components in self.compulsoryComponents.keys{
        let componentRef : &DoppleGangsterComponent.NFT = &self.compulsoryComponents[components] as! &DoppleGangsterComponent.NFT
        allComponentMetadata[components] = componentRef.componentMetadata
      }

      for components in self.optionalComponents.keys{
        let componentRef : &DoppleGangsterComponent.NFT = &self.optionalComponents[components] as! &DoppleGangsterComponent.NFT
        allComponentMetadata[components] = componentRef.componentMetadata
      }

      return allComponentMetadata
    }

    pub fun getAllComponentIDs() : [UInt64] {
      var ids : [UInt64] = []
      let componentMetadata = self.getAllComponentMetadata()
      for catInComponent in componentMetadata.keys {
        ids.append(componentMetadata[catInComponent]!.id)
      }
      return ids
    }
    
    pub fun getDoppleGangsterSvg() : String {
      // part A get all svg Strings 
      let series = self.series
      let allComponentMetadata = self.getAllComponentMetadata()
      var svgArr : [String] = []
      var matchedCat : String? = nil
      for catInSequence in DoppleGangsterComponentTemplate.getCategoriesInSequence(series: series) {
        for catInMetadata in allComponentMetadata.keys {
          if catInSequence == catInMetadata {
            matchedCat = catInSequence
            break
          } else {
            matchedCat = nil
          }
        }

        if matchedCat != nil {
          svgArr.append(allComponentMetadata[matchedCat!]!.svg)
        } 
      }

      // Part B insert standard svg stuff
      let completeSvg: String = "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 3000 3000' width='100%' height='100%'>"

      for componentSvg in svgArr {
        completeSvg.concat(componentSvg)
      }

      completeSvg.concat("</svg>")
      
      return completeSvg
    }

    pub fun checkOptionalComponent(category: String) : Bool {
      return self.optionalComponents.containsKey(category)
    }

    pub fun changeCompulsoryComponent(component: @DoppleGangsterComponent.NFT) : @DoppleGangsterComponent.NFT {
      pre{
        self.series == component.componentMetadata.series : "The component series does not match"
        DoppleGangsterComponentTemplate.getCompulsoryCategories(series: self.series).contains(component.componentMetadata.category) : "The component is not a compulsory component"
      }

      let catInComponent = component.componentMetadata.category
      let withdrawNFT <- self.compulsoryComponents.remove(key: catInComponent) 

      self.compulsoryComponents[catInComponent] <-! component

      DoppleGangster.componentsOnNFT[self.id] = self.getAllComponentIDs()
      
      emit Changed(id: self.id, componentId: self.getAllComponentIDs())

      return <- withdrawNFT!
    }

    pub fun addOptionalComponent(component: @DoppleGangsterComponent.NFT) {
      pre{
        self.series == component.componentMetadata.series : "The component series does not match"
        DoppleGangsterComponentTemplate.getOptionalCategories(series: self.series).contains(component.componentMetadata.category) : "The component is not an optional component"
      }

      let catInComponent = component.componentMetadata.category

      self.optionalComponents[catInComponent] <-! component

      DoppleGangster.componentsOnNFT[self.id] = self.getAllComponentIDs()
      
      emit Changed(id: self.id, componentId: self.getAllComponentIDs())
    }

    pub fun changeOptionalComponent(component: @DoppleGangsterComponent.NFT) : @DoppleGangsterComponent.NFT {
      pre{
        self.series == component.componentMetadata.series : "The component series does not match"
        DoppleGangsterComponentTemplate.getOptionalCategories(series: self.series).contains(component.componentMetadata.category) : "The component is not an optional component"
      }

      let catInComponent = component.componentMetadata.category
      let withdrawNFT <- self.optionalComponents.remove(key: catInComponent)   ?? panic("This DoppleGangster does not own Component of this category")

      self.optionalComponents[catInComponent] <-! component
      
      DoppleGangster.componentsOnNFT[self.id] = self.getAllComponentIDs()

      emit Changed(id: self.id, componentId: self.getAllComponentIDs())

      return <- withdrawNFT
    }

    pub fun removeOptionalComponent(category: String) : @DoppleGangsterComponent.NFT {
      pre{
        self.optionalComponents[category] != nil : "This DoppleGangster is not equipped with the NFT of this category"
      }

      let withdrawNFT <- self.optionalComponents.remove(key: category)  ?? panic("This DoppleGangster does not own Component of this category")

      DoppleGangster.componentsOnNFT[self.id] = self.getAllComponentIDs()

      emit Changed(id: self.id, componentId: self.getAllComponentIDs())

      return <- withdrawNFT
    }

    /* MetadataViews Implementation */
    pub fun getViews():[Type] {
      return [Type<MetadataViews.Display>(), 
              Type<Metadata>(),
              Type<[Royalty]>()]
    }

    pub fun resolveView(_ view: Type): AnyStruct? {
        switch view {
            case Type<MetadataViews.Display>():
                return MetadataViews.Display(
                name : self.name ,
                description : "" ,
                thumbnail : DoppleGangsterComponentTemplate.SVGFile(_svg : self.getDoppleGangsterSvg())
                )
            
            case Type<Metadata>():
                
                var compulsoryComponents : {String : DoppleGangsterComponent.ComponentMetadata} = {}
                for key in self.compulsoryComponents.keys{
                  let componentRef : &DoppleGangsterComponent.NFT = &self.compulsoryComponents[key] as! &DoppleGangsterComponent.NFT
                  let category = componentRef.componentMetadata.category
                  compulsoryComponents[category] = componentRef.componentMetadata
                }
                
                var optionalComponents : {String : DoppleGangsterComponent.ComponentMetadata} = {}
                for key in self.optionalComponents.keys{
                  let componentRef : &DoppleGangsterComponent.NFT = &self.optionalComponents[key] as! &DoppleGangsterComponent.NFT
                  let category = componentRef.componentMetadata.category
                  optionalComponents[category] = componentRef.componentMetadata
                }

                let metadata = Metadata(id : self.id , 
                                        name : self.name ,
                                        series : self.series ,
                                        creatorAddress : self.creatorAddress ,
                                        compulsoryComponents : compulsoryComponents ,
                                        optionalComponents : optionalComponents)
                return metadata

            case Type<[Royalty]>() :
                return self.royalties
        } 
        return nil
    }
  }

  pub resource interface CollectionPublic {
    pub fun deposit(token: @NonFungibleToken.NFT)
    pub fun getIDs(): [UInt64]
    pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
    pub fun borrowDoppleGangsterNFTPublic(id: UInt64) : &{Public}? {
        // If the result isn't nil, the id of the returned reference
        // should be the same as the argument to the function
        post {
            (result == nil) || (result?.id == id):
                "Cannot borrow DoppleGangster reference: The ID of the returned reference is incorrect"
        }
    }
  }

  pub resource Collection : CollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
    pub var ownedNFTs : @{UInt64 : NonFungibleToken.NFT}

    init(){
      self.ownedNFTs <- {}
    }

    destroy() {
      destroy self.ownedNFTs
    }

    pub fun withdraw(withdrawID: UInt64) : @NonFungibleToken.NFT {
      pre{
        self.ownedNFTs[withdrawID] != nil : "Cannot find this NFT in your collection"
      }

      let token <- self.ownedNFTs.remove(key: withdrawID)!

      emit Withdraw(id: token.id, from: self.owner?.address)

      if let addr = self.owner?.address{
        DoppleGangster.nftHolder[addr] = self.getIDs()
      }

      return <- token
    
    }

    pub fun deposit(token: @NonFungibleToken.NFT) {

      let token <- token as! @DoppleGangster.NFT

      let id: UInt64 = token.id

      // add the new token to the dictionary which removes the old one
      let oldToken <- self.ownedNFTs[id] <- token

      emit Deposit(id: id, to: self.owner?.address)
      
      if let addr = self.owner?.address{
        DoppleGangster.nftHolder[addr] = self.getIDs()
      }

      destroy oldToken
    } 

    pub fun batchDeposit(collection: @Collection) {

      for id in collection.getIDs() {
        self.deposit(token: <- collection.withdraw(withdrawID: id))
      }

      assert(collection.getIDs().length == 0 , message: "The batch deposit does not run successfully")
      destroy collection
    }

    pub fun getIDs() : [UInt64] {
      return self.ownedNFTs.keys
    }

    pub fun borrowNFT(id: UInt64) : &NonFungibleToken.NFT {
      return &self.ownedNFTs[id] as &NonFungibleToken.NFT
    }

    pub fun borrowDoppleGangsterNFTPublic(id: UInt64) : &{Public}? {
      let ref = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
      let componentRef = ref as! &DoppleGangster.NFT
      return componentRef as &{Public}
    }

    pub fun borrowDoppleGangsterNFT(id: UInt64) : &NFT {
      let ref : auth &NonFungibleToken.NFT = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
      let componentRef = ref as! &DoppleGangster.NFT
      return componentRef 
    }

    /* MetadataViews Implementation */
    pub fun borrowViewResolver(id: UInt64) : &{MetadataViews.Resolver} {
        let nft = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
        let doppleGangsterNFT = nft as! &DoppleGangster.NFT
        return doppleGangsterNFT as &{MetadataViews.Resolver}
    }

  }

  pub fun createEmptyCollection() : @Collection {
    return <- create Collection()
  }

  pub fun getDoppleGangster(addr: Address, id: UInt64) : DoppleGangster.Metadata {
    let collectionCap = getAccount(addr).getCapability<&DoppleGangsterComponent.Collection{MetadataViews.ResolverCollection}>(DoppleGangsterComponent.CollectionPublicPath)
    let collectionRef = collectionCap.borrow() ?? panic("Cannot borrow the collection reference")
    return collectionRef.borrowViewResolver(id: id).resolveView(Type<Metadata>()) as! DoppleGangster.Metadata 
  }

  pub fun getDoppleGangsters(addr: Address) : {UInt64 : DoppleGangster.Metadata} {
    let collectionCap = getAccount(addr).getCapability<&DoppleGangsterComponent.Collection{MetadataViews.ResolverCollection}>(DoppleGangsterComponent.CollectionPublicPath)
    let collectionRef = collectionCap.borrow() ?? panic("Cannot borrow the collection reference")

    var metadata : {UInt64 : DoppleGangster.Metadata} = {}
    for id in collectionRef.getIDs() {
      metadata[id] = collectionRef.borrowViewResolver(id: id).resolveView(Type<Metadata>()) as! DoppleGangster.Metadata 
    }
    return metadata
  }

  pub fun getDoppleGangsterHolder() : {Address : [UInt64]} {
    return DoppleGangster.nftHolder
  }

  pub fun getComponentsOnNFT() : {UInt64 : [UInt64]} {
    return DoppleGangster.componentsOnNFT
  }

  pub fun createDoppleGangster(
    name: String,
    series: UInt32
    creatorAddress: Address,
    compulsoryComponents : @{String : DoppleGangsterComponent.NFT} ,

  ) : @DoppleGangster.NFT {

    /* Checking */

    //Check the length of inputted components, it should equal to the length of th compulsory category
    assert(compulsoryComponents.length == DoppleGangsterComponentTemplate.getCompulsoryCategories(series:series).length, message : "All compulsory components are required to create a DoppleGangster")

    for catInInput in compulsoryComponents.keys{
      assert(DoppleGangsterComponentTemplate.getCompulsoryCategories(series:series).contains(compulsoryComponents[catInInput]?.componentMetadata!.category)
            , message : "Only compulsory components can be placed to create a DoppleGangster")
      assert(compulsoryComponents[catInInput]?.componentMetadata!.series == series, message : "The placed component does not match with the series")
    }

    var creatorCap = getAccount(creatorAddress).getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)
    var projectCap = self.account.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)
    var royalties = [ Royalty(wallet: creatorCap, cut: DoppleGangster.royaltyCut) ,
                      Royalty(wallet: projectCap, cut: DoppleGangster.marketplaceCut) ]

    var newNFT <- create NFT(creatorAddress: creatorAddress, series: series, compulsoryComponents: <- compulsoryComponents, royalties: royalties)
    
    emit Created(id: newNFT.id, series: series, creatorAddress: creatorAddress, componentId: newNFT.getAllComponentIDs())
    
    return <- newNFT

  }

  access(account) fun setMarketplaceCut(cut: UFix64) {
    pre{
      cut + self.royaltyCut <= 1.0 : "Royalty cannot be greater than 1"
    }
    self.marketplaceCut = cut
  }

  access(account) fun setRoyaltyCut(cut: UFix64) {
    pre{
      cut + self.marketplaceCut <= 1.0 : "Royalty cannot be greater than 1"
    }
    self.royaltyCut = cut
  }

  pub fun getMarketplaceCut(): UFix64 {
    return self.marketplaceCut
  }

  pub fun getRoyaltyCut(): UFix64 {
    return self.royaltyCut
  }


  init(){
    self.totalSupply = 0
    
    self.CollectionStoragePath = /storage/DoppleGangster
    self.CollectionPublicPath = /public/DoppleGangster
    self.CollectionPrivatePath = /private/DoppleGangster

    self.nftHolder = {}
    self.componentsOnNFT = {}

    // Set the default Royalty and Marketplace cuts
    self.royaltyCut = 0.01
    self.marketplaceCut = 0.05

    self.account.save<@DoppleGangster.Collection>(<- DoppleGangster.createEmptyCollection(), to: DoppleGangster.CollectionStoragePath)
    self.account.link<&{DoppleGangster.CollectionPublic}>(DoppleGangster.CollectionPublicPath, target: DoppleGangster.CollectionStoragePath)

    emit ContractInitialized()
  }
}
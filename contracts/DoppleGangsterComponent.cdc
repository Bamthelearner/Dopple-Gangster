import NonFungibleToken from "./NonFungibleToken.cdc"
import MetadataViews from "./MetadataViews.cdc"
import DoppleGangsterComponentTemplate from "./DoppleGangsterComponentTemplate.cdc"

pub contract DoppleGangsterComponent : NonFungibleToken {
  pub var totalSupply : UInt64
  
  pub let CollectionStoragePath : StoragePath
  pub let CollectionPublicPath : PublicPath
  pub let CollectionPrivatePath : PrivatePath

  access(contract) var nftHolder : {Address : [UInt64]}

  pub event ContractInitialized()
  pub event Withdraw(id: UInt64, from: Address?)
  pub event Deposit(id: UInt64, to: Address?)
  pub event Created(id: UInt64, templateId : UInt64)


  pub struct ComponentMetadata {
    pub let id : UInt64
    pub let templateId : UInt64
    pub let mint : UInt64
    pub let name : String
    pub let description : String?
    pub let series : UInt32
    pub let category : String
    pub let compulsory : Bool
    pub let color : String
    pub let svg : String
    pub let rarity : String

    init(id : UInt64 , 
         templateId : UInt64 ,
         mint : UInt64 ,
         name : String ,
         description : String? ,
         series : UInt32 ,
         category : String ,
         compulsory : Bool ,
         color : String ,
         svg : String ,
         rarity : String){

        self.id = id
        self.templateId = templateId
        self.mint = mint
        self.name = name
        self.description = description
        self.series = series
        self.category = category
        self.compulsory = compulsory
        self.color = color
        self.svg = svg
        self.rarity = rarity
    }
  }

  pub resource NFT : NonFungibleToken.INFT, MetadataViews.Resolver {
    pub let id : UInt64  
    pub let templateId : UInt64 
    pub let componentMetadata : ComponentMetadata
    
    init(templateId: UInt64, mint: UInt64) {
    self.id = self.uuid
    self.templateId = templateId
    let metadataRef = DoppleGangsterComponentTemplate.borrowDoppleGangsterTemplate(id: templateId)
    let componentTemplateRef = metadataRef.template
    self.componentMetadata = ComponentMetadata(id : self.uuid , 
                                               templateId : templateId ,
                                               mint : mint ,
                                               name : componentTemplateRef.name ,
                                               description : componentTemplateRef.description ,
                                               series : componentTemplateRef.series ,
                                               category : componentTemplateRef.category ,
                                               compulsory : componentTemplateRef.compulsory ,
                                               color : componentTemplateRef.color ,
                                               svg : componentTemplateRef.svg ,
                                               rarity : componentTemplateRef.rarity)
    } 


    /* MetadataViews Implementation */
    pub fun getViews():[Type] {
      return [Type<MetadataViews.Display>(), 
              Type<ComponentMetadata>()]
    }

    pub fun resolveView(_ view: Type): AnyStruct? {
        switch view {
            case Type<MetadataViews.Display>():
                return MetadataViews.Display(
                name : self.componentMetadata.name ,
                description : self.componentMetadata.description! ,
                thumbnail : DoppleGangsterComponentTemplate.SVGFile(_svg : self.componentMetadata.svg)
                )
            
            case Type<ComponentMetadata>():
                return self.componentMetadata
        } 
        return nil
    }
  }

  pub resource interface CollectionPublic {
    pub fun getIDs() : [UInt64]
    pub fun deposit(token: @NonFungibleToken.NFT)
    pub fun borrowNFT(id : UInt64) : &NonFungibleToken.NFT
    pub fun borrowDoppleGangsterComponentNFT(id : UInt64) : &NFT {
      // If the result isn't nil, the id of the returned reference
      // should be the same as the argument to the function
      post {
          (result == nil) || (result.id == id):
              "Cannot borrow Component reference: The ID of the returned reference is incorrect"
      }
    }
  }

  pub resource Collection : CollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection {
    pub var ownedNFTs : @{UInt64: NonFungibleToken.NFT}

    init(){
      self.ownedNFTs <- {}
    }

    destroy(){
      destroy self.ownedNFTs
    }

    pub fun withdraw(withdrawID: UInt64) : @NonFungibleToken.NFT {
      pre{
        self.ownedNFTs[withdrawID] != nil : "Cannot find this NFT in your collection"
      }

      let token <- self.ownedNFTs.remove(key: withdrawID)!

      emit Withdraw(id: token.id, from: self.owner?.address)

      if let addr = self.owner?.address{
        DoppleGangsterComponent.nftHolder[addr] = self.getIDs()
      }

      return <- token
    
    }

    pub fun deposit(token: @NonFungibleToken.NFT) {

      let token <- token as! @DoppleGangsterComponent.NFT

      let id: UInt64 = token.id

      // add the new token to the dictionary which removes the old one
      let oldToken <- self.ownedNFTs[id] <- token

      emit Deposit(id: id, to: self.owner?.address)
      
      if let addr = self.owner?.address{
        DoppleGangsterComponent.nftHolder[addr] = self.getIDs()
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

    pub fun borrowDoppleGangsterComponentNFT(id: UInt64) : &NFT {
      let ref : auth &NonFungibleToken.NFT = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
      let componentRef : &NFT = ref as! &NFT
      return componentRef 
    }

    /* MetadataViews Implementation */
    pub fun borrowViewResolver(id: UInt64) : &{MetadataViews.Resolver} {
        let nft = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
        let doppleGangsterNFT = nft as! &DoppleGangsterComponent.NFT
        return doppleGangsterNFT as &{MetadataViews.Resolver}
    }

  }

  pub fun createEmptyCollection() : @Collection {
    return <- create Collection()
  }

  pub fun getDoppleGangsterComponentByAddr(addr : Address) : [UInt64]? {
    return self.nftHolder[addr]
  }

  pub fun getHolderAddrByComponentId(id: UInt64) : Address? {
    for addr in self.nftHolder.keys {
      if self.nftHolder[addr]!.contains(id) {
        return addr 
      }
    }
    return nil
  }

  pub fun getConponent(addr: Address, id: UInt64) : DoppleGangsterComponent.ComponentMetadata {
    let collectionCap = getAccount(addr).getCapability<&DoppleGangsterComponent.Collection{DoppleGangsterComponent.CollectionPublic}>(DoppleGangsterComponent.CollectionPublicPath)
    let collectionRef = collectionCap.borrow() ?? panic("Cannot borrow the collection reference")
    return collectionRef.borrowDoppleGangsterComponentNFT(id: id).componentMetadata
  }

  pub fun getComponents(addr: Address) : [DoppleGangsterComponent.ComponentMetadata]  {
    let collectionCap = getAccount(addr).getCapability<&DoppleGangsterComponent.Collection{DoppleGangsterComponent.CollectionPublic}>(DoppleGangsterComponent.CollectionPublicPath)
    let collectionRef = collectionCap.borrow() ?? panic("Cannot borrow the collection reference")
    var metadatas : [DoppleGangsterComponent.ComponentMetadata] = []
    for id in collectionRef.getIDs() {
      metadatas.append(collectionRef.borrowDoppleGangsterComponentNFT(id: id).componentMetadata)
    }
    return metadatas
  }

  pub fun getComponentHolder() : {Address : [UInt64]} {
    return DoppleGangsterComponent.nftHolder
  }

  access(account) fun createComponent(templateId: UInt64) : @NFT {
    let maxMintable = DoppleGangsterComponentTemplate.getComponentMaxMintable(id: templateId)!
    let thisMint = DoppleGangsterComponentTemplate.getTotalMintedComponents(id: templateId)! + 1

    assert(thisMint <= maxMintable, message: "The component exceed its allowed number of mintings.")

    var newNFT <- create NFT(templateId: templateId, mint : thisMint)

    DoppleGangsterComponentTemplate.setTotalMintedComponents(id: templateId)
    
    emit Created(id: newNFT.id, templateId: templateId)
    
    return <- newNFT
  }

  access(account) fun batchCreateComponents(templateId: UInt64, quantity: UInt64) : @Collection {
    var counter : UInt64 = 0
    let collection <- self.createEmptyCollection()
    while counter < quantity {
      collection.deposit(token: <- self.createComponent(templateId: templateId))
      counter = counter + 1
    }

    return <- collection
  }

  init(){
    self.totalSupply = 0
    
    self.CollectionStoragePath = /storage/DoppleGangsterComponent
    self.CollectionPublicPath = /public/DoppleGangsterComponent
    self.CollectionPrivatePath = /private/DoppleGangsterComponent

    self.nftHolder = {}

    self.account.save<@DoppleGangsterComponent.Collection>(<- DoppleGangsterComponent.createEmptyCollection(), to: DoppleGangsterComponent.CollectionStoragePath)
    self.account.link<&{DoppleGangsterComponent.CollectionPublic, MetadataViews.ResolverCollection}>(DoppleGangsterComponent.CollectionPublicPath, target: DoppleGangsterComponent.CollectionStoragePath)

    emit ContractInitialized()
  }

}
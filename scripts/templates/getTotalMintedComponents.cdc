import DoppleGangsterComponentTemplate from "../../contracts/DoppleGangsterComponentTemplate.cdc"


pub fun main(id: UInt64) : UInt64? {

  return DoppleGangsterComponentTemplate.getTotalMintedComponents(id: id)

} 
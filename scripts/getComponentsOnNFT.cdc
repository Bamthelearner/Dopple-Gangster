import DoppleGangsterComponent from "../contracts/DoppleGangsterComponent.cdc"
import DoppleGangster from "../contracts/DoppleGangster.cdc"

pub fun main() : {UInt64 : [UInt64]} {

  return DoppleGangster.getComponentsOnNFT()

} 
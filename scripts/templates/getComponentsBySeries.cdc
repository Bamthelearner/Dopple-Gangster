import DoppleGangsterComponentTemplate from "../../contracts/DoppleGangsterComponentTemplate.cdc"


pub fun main(series: UInt32) : [UInt64] {

  return DoppleGangsterComponentTemplate.getComponentsBySeries(series: series)

} 
import DoppleGangsterComponentTemplate from "../../contracts/DoppleGangsterComponentTemplate.cdc"


pub fun main(series: UInt32, category: String) : [UInt64] {

  return DoppleGangsterComponentTemplate.getComponentsByCategory(series: series, category: category)

} 
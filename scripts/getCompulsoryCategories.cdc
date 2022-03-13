import DoppleGangsterComponentTemplate from "../contracts/DoppleGangsterComponentTemplate.cdc"

pub fun main(series: UInt32) : [String] {

  return DoppleGangsterComponentTemplate.getCompulsoryCategories(series: series)

} 
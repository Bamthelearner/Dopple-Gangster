import DoppleGangsterComponentTemplate from "../../contracts/DoppleGangsterComponentTemplate.cdc"


pub fun main(id: UInt64) : &DoppleGangsterComponentTemplate.Template {

  return DoppleGangsterComponentTemplate.borrowDoppleGangsterTemplate(id: id)

} 
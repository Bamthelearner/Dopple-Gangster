import DoppleGangsterComponentTemplate from "../../contracts/DoppleGangsterComponentTemplate.cdc"


pub fun main(series : UInt32) : DoppleGangsterComponentTemplate.SeriesData? {

  return DoppleGangsterComponentTemplate.getSeriesData(series: series)

} 
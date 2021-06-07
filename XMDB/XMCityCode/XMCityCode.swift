//
//  XMCityCode.swift
//  XMDB
//
//  Created by Rowling on 2021/6/7.
//

import Foundation

open class XMCityCode {
   public class func getProvince(adcode : String,callBack:@escaping ((_ data : (province:String,city:String,district:String)?)->())) {
        let sql = """
            SELECT
            province.name AS province,
            city.name AS city,
            district.name AS district
            FROM
            location AS province,
            location AS city,
            location AS district
            WHERE
            district.adcode = '\(adcode)'
            AND SUBSTR( city.adcode, 5, 2 ) = '00'
            AND SUBSTR( province.adcode, 3, 4 ) = '0000'
            AND SUBSTR( province.adcode, 1, 2) = SUBSTR(district.adcode,1, 2)
            AND SUBSTR(city.adcode, 1, 4 ) = SUBSTR( district.adcode, 1, 4 )
        """
        XMFMDB.excauteQuery(sql: sql, dbname: "amap_city_code") { (rs) in
           if let rs = rs {
               while rs.next() {
                guard let province = rs.string(forColumn: "province"),
                      let city = rs.string(forColumn: "city"),
                      let district = rs.string(forColumn: "district")
                else {
                    callBack(nil)
                      return
                }
                callBack((province,city,district))
              }
           }
        }
    }
    
    public class func getCityName(adcode : String,callBack:@escaping ((_ cityName : String?)->())) {
        let sql = "SELECT name From location WHERE adcode = \(adcode)"
        XMFMDB.excauteQuery(sql: sql, dbname: "") { (rs) in
           if let rs = rs {
               while rs.next() {
                guard let cityName = rs.string(forColumn: "name")
                else {
                    callBack(nil)
                      return
                }
                callBack(cityName)
              }
           }
        }
    }
}

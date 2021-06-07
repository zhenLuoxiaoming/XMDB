//
//  XMDBModelTool.swift
//  HaiLuo
//
//  Created by Rowling on 2020/6/9.
//  Copyright © 2020 Rowling. All rights reserved.
//

import Foundation

open class XMCityUtil {
    public struct CityQueryResult {
        public var province : String
        public var city : String
        public var district : String
    }
    public class func getAddressInfo(adcode : String,callBack:@escaping ((_ data : CityQueryResult?)->())) {
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
        XMFMDB.excauteQuery(sql: sql, dbname: "") { (rs) in
           if let rs = rs {
               while rs.next() {
                guard let province = rs.string(forColumn: "province"),
                      let city = rs.string(forColumn: "city"),
                      let district = rs.string(forColumn: "district")
                else {
                    callBack(nil)
                      return
                }
                callBack(CityQueryResult(province: province, city: city, district: district))
              }
           }
        }
    }

}
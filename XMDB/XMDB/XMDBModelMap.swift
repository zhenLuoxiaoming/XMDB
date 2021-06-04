//
//  XMDBModelMap.swift
//  HaiLuo
//
//  Created by Rowling on 2020/6/12.
//  Copyright © 2020 Rowling. All rights reserved.
//

import UIKit
import KakaJSON
import FMDB

public protocol XMDBMap : Convertible {
    static func ignoreKey() -> [String]
    static func primaryKey() -> String
    static func updateTabelNewNameToOldNameDic() -> [String : String]
}

extension XMDBMap {
    static func ignoreKey() -> [String] {
        return [""]
    }
    
    static func updateTabelNewNameToOldNameDic() -> [String : String] {
        return [:]
    }
}

class XMDBModelMap: NSObject {
    //MARK:key - value 映射
    static func keyVauleMap<T : XMDBMap>(type : T) -> [String : Any]{
        let mir = Mirror(reflecting: type)
        var result = [String : Any]()
        let ignorkeys = T.self.ignoreKey()
        for a in mir.children {
            if let label = a.label {
                if ignorkeys.contains(label){
                    // 过滤
                    continue
                }
                
                let b = a.value as AnyObject
                print(b)
                if isNull(value: b) {
                    print("is null")
                    let v = a.value
                    let subm = Mirror(reflecting: v)
                    let str =  dealOption(typeStr: "\(subm.subjectType)")
                    result[label] = typeMapTableValule(proerty:str)
                } else {
                    result[label] = a.value
                }
            }
        }
        return result
    }
    
    static func isNull(value : Any?) -> Bool{
        if value == nil {return true}
        if value is NSNull {return true}
        return false
    }
    
    //MARK:解析数据类型
    static func modelMapKey<T : XMDBMap>(model : T) -> [String : String] {
        let mir = Mirror(reflecting: model)
        var result = [String : String]()
        let ignorkeys = T.self.ignoreKey()
        for a in mir.children {
            if let label = a.label {
                if ignorkeys.contains(label){
                    // 过滤
                    continue
                }
                let subMir = Mirror(reflecting:a.value)
                let typeStr = "\(subMir.subjectType)"
                result[label] = dealOption(typeStr: typeStr)
            }
        }
        return result
    }
    
    //MARK:属性，数据库类型映射处理
    static func transPropertyToTabelKey(proertys:[String : String]) -> [String : String]{
        var newDic = [String : String]()
        for dic in proertys {
            newDic[dic.key] = typeMapTableKey(proerty: dic.value)
        }
        return newDic
    }
    
    //MARK:swift 类型 与数据库类型映射
    static func typeMapTableKey(proerty : String)->String {
        switch proerty {
        case "String":
            return "text"
        case "Int":
            return "integer"
        case "Float":
            return "real"
        case "Double":
            return "real"
        case "Bool":
            return "blob"
        case "image":
            return "BLOB"
        default:
            return "text"
        }
    }
    
    //MARK:swift 类型 与数据库类型映射
    static func typeMapTableValule(proerty : String)-> Any {
        switch proerty {
        case "String":
            return ""
        case "Int":
            return 0
        case "Float":
            return 0.0
        case "Double":
            return 0.0
        case "Bool":
            return false
        case "image":
            return false
        default:
            return ""
        }
    }
    
    //MARK:处理optional
    static func dealOption( typeStr : String) -> String {
        var temp = typeStr
        if match(str: temp, "Optional<.+>") {
            temp = temp.replacingOccurrences(of: "Optional<", with: "")
            temp = temp.replacingOccurrences(of: ">", with: "")
        }
        return temp
    }
    
    /// 匹配正则
    static func match(str:String, _ regex:String) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: str)
    }
    
    
}

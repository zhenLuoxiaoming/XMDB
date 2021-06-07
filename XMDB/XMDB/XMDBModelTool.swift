//
//  XMDBModelTool.swift
//  HaiLuo
//
//  Created by Rowling on 2020/6/9.
//  Copyright © 2020 Rowling. All rights reserved.
//

import UIKit
import KakaJSON
import FMDB
open class XMDBModelTool  {
    //MARK:存储
    public static func saveOrUpdateModelToDB<T : XMDBMap>(model : T ,dbname : String) -> Bool {
        let dic = XMDBModelMap.keyVauleMap(type: model)
        
        var hasTheModel = false // 是否已经存在数据库中了
        XMFMDB.excauteQuery(sql: "select * from \(T.self) where \(T.self.primaryKey()) = '\(dic[(T.self.primaryKey())] ?? "")'", dbname: dbname) { (rs) in
            if let rs = rs , rs.next(){
                hasTheModel = true
            }
        }
        if hasTheModel {
             // 更新
            return XMFMDB.update(tableName: "\(T.self)", dic: dic, primaryKey: T.self.primaryKey(), dbname: dbname)
        } else {
             // 插入
            return XMFMDB.insertInto(tableName: "\(T.self)", dic: dic, dbname: dbname)
        }
    }
    
    //MARK:获取
    public static func getModelFromDB<T : XMDBMap>(model :T.Type,dbname : String , complete : @escaping ((_ result : [T])->())){
        let valueMap = XMDBModelMap.modelMapKey(model: model.init())
        XMFMDB.excauteQuery(sql: "select * from \(model)", dbname: dbname) { (rs) in
            var resultArray = [T]()
            if let rs = rs {
              while rs.next() {
                // 还不知道怎么映射
                var jsonDic = [String : Any]()
                for dic in valueMap {
                    if let data = rs.object(forColumn: dic.key) {
                        jsonDic[dic.key] = data
                    }
                }
                
                let resultModel = jsonDic.kj.model(type: model)
                resultArray.append(resultModel as! T)
               }
            }
            complete(resultArray)
        }
    }
    
    //MARK:删除
    public static func deleteTheModel<T : XMDBMap>(model :T ,dbname : String) -> Bool{
        let tabelName = "\(T.self)"
        let primaryKey = T.self.primaryKey()
        let mirror = Mirror(reflecting: model)
        var dic = [String : Any]()
        for a in mirror.children {
            if let label = a.label {
                if primaryKey == label {
                    dic[label] = a.1
                }
            }
        }
        let primaryVaule = dic[primaryKey]
       return XMFMDB.excauteSql(sqls: [("delete from \(tabelName) where \(primaryKey) = '\(primaryVaule ?? -999)'",nil)], dbname: dbname)
    }
    
    //MARK:创建表
    public static func creatTabel<T : XMDBMap>(model : T.Type , dbname : String) -> Bool {
       
        let dic = XMDBModelMap.modelMapKey(model:T.init())
        
        let pdic = XMDBModelMap.transPropertyToTabelKey(proertys: dic)
        
        return XMFMDB.creatTabel(tableName: "\(model)", items: pdic, primarykey: model.primaryKey(), dbname: dbname)
    }
    
    
    //MARK:更新表
    public static func updateTabel<T : XMDBMap>(tabelType : T.Type ,dbname : String) -> Bool {
        let  tmpTableName = "\(T.self)_temp"
        let  tabelName = "\(T.self)"
        let  primaryKey = T.self.primaryKey()
        let  newNameToOldNameDic = T.self.updateTabelNewNameToOldNameDic()
        // 创建临时表
        let dic = XMDBModelMap.modelMapKey(model:T.init())
        let pdic = XMDBModelMap.transPropertyToTabelKey(proertys: dic)
        
        var sqls = [(String,[Any]?)]()
        let dropTabel : (String,[Any]?) = ("drop table if exists \(tmpTableName)",nil)
        sqls.append(dropTabel)

        let creatTabel : (String,[Any]?) = (XMFMDB.creatTableSql(tableName: tmpTableName, items: pdic, primarykey: primaryKey),nil)
        sqls.append(creatTabel)
        
        // 插入数据
        let insertDataSql = "insert into \(tmpTableName)(\(primaryKey)) select \(primaryKey) from \(tabelName)"
        sqls.append((insertDataSql,nil))
        
        var oldNames = [String]()
        var newNames = [String]()
        if let database = XMFMDB.openDB(dbname: dbname), let rs = database.getTableSchema(tabelName){
            
            while rs.next() {
                if let name = rs.string(forColumn: "name"){
                    oldNames.append(name)
                }
            }
            database.close()
        }
        for d in dic {
            newNames.append(d.key)
        }
        
        for columnName in newNames {
            var oldName = columnName
            if let newname = newNameToOldNameDic[columnName] , newname.count > 0  {
                oldName = newname
            }
            
            if (!oldNames.contains(columnName) && !oldNames.contains(oldName)) || columnName == primaryKey {
                // 新增字段
                continue
            }
            
            let updateSql = "update \(tmpTableName) set \(columnName) = (select \(oldName) from \(tabelName) where \(tmpTableName).\(primaryKey) = \(tabelName).\(primaryKey))"
            sqls.append((updateSql,nil))
        }
        
        let deleteOldTable = "drop table if exists \(tabelName)"
        sqls.append((deleteOldTable,nil))
        let renameTableName = "alter table \(tmpTableName) rename to \(tabelName)"
        
        sqls.append((renameTableName,nil))
        return XMFMDB.excauteSqlsWithTransaction(sqls: sqls, dbname: dbname)
    }
}







class TestModel : XMDBMap , Convertible {
//    static func ignoreKey() -> [String] {
//        return [""]
//    }
    
    static func primaryKey() -> String {
        "aa"
    }
    
    var fuck : String?
    var image : Data!
    var aa = ""
    var shijian = Date()
    var dabo : Double = 1.2
    var fulouti : Float = 1.3
    var inte : Int = 4
    var sejifluot : CGFloat = 1.8
    var buer : Bool = true
    
    required init(){}
}

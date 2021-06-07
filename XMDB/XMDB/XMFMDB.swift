//
//  XMFMDB.swift
//  HaiLuo
//
//  Created by Rowling on 2020/6/9.
//  Copyright © 2020 Rowling. All rights reserved.
//

import UIKit
import KakaJSON
import FMDB
open class XMFMDB  {
    //MARK:执行查询sql
    public static func excauteQuery(sql : String, dbname : String , rsBlock:((_ rs : FMResultSet?)->())?){
        guard let database = openDB(dbname: dbname) else {return}
        var rs : FMResultSet?
        do {
            rs = try database.executeQuery(sql, values: nil)
        } catch {
            print(error)
        }
        if let rsBlock = rsBlock {
            rsBlock(rs)
        }
        database.close()
    }
    
    //MARK:执行sql
    public static func excauteSql(sqls : [(String,[Any]?)] , dbname : String) -> Bool{
        guard let database = openDB(dbname: dbname) else {return false}

        do {
            for sql in sqls {
                try database.executeUpdate(sql.0,values:sql.1)
            }
            database.close()
            return true
        } catch {
            print("failed: \(error.localizedDescription)")
            database.close()
            return false
        }
    }
    
    //MARK:打开数据库
    public static func openDB(dbname : String) -> FMDatabase? {
        let fileURL = getDBUrl(dbname: dbname)
        let database = FMDatabase(url: fileURL)
        guard database.open() else {
            print("Unable to open database")
            return nil
        }
        return database
    }
        
    //MARK:获取数据库路径
    public static func getDBUrl(dbname : String) -> URL {
        if let path = Bundle.main.path(forResource:dbname, ofType:"db") {
            let fileURL = URL.init(fileURLWithPath: path)
            return fileURL
        }
        else {
            let fileURL = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("\(dbname).sqlite")
            return fileURL
        }
    }
    
    public static func insertInto(tableName : String , dic : [String : Any], dbname : String) -> Bool {
         var sql =  "insert into \(tableName)" //" (x, y, z)
         var parSql = ""
//         var values = [Any]()
         var placePar = ""
         for d in dic {
             parSql.append(d.key)
             parSql.append(",")
             placePar.append("'\(d.value)'")
             placePar.append(",")
//             values.append(d.value)
         }
         parSql = parSql.xmsubstring(to: parSql.count - 1)
         placePar = placePar.xmsubstring(to: placePar.count - 1)
         
         sql.append(" (\(parSql))")
         sql.append(" values (\(placePar))")
         print(sql)
         return excauteSql(sqls: [(sql,nil)], dbname: dbname)
        
        
//        var sql =  "insert into \(tableName)" //" (x, y, z)
//        var parSql = ""
//        var values = [Any]()
//        var placePar = ""
//        for d in dic {
//            parSql.append(d.key)
//            parSql.append(",")
//            placePar.append("?")
//            placePar.append(",")
//            values.append(d.value)
//        }
//        parSql = parSql.zm.substring(to: parSql.count - 1)
//        placePar = placePar.zm.substring(to: placePar.count - 1)
//
//        sql.append(" (\(parSql))")
//        sql.append(" values (\(placePar))")
//        print(sql)
//        return excauteSql(sqls: [(sql,values)], dbname: dbname)
     }
    
    
   static  func update(tableName : String , dic : [String : Any] ,primaryKey : String , dbname : String) -> Bool {
        var sql =  "UPDATE \(tableName) SET " //" (x, y, z)
        var parSql = ""
        var values = [Any]()
//        var placePar = ""
        var keyValue : Any!
        for d in dic {
            if d.key == primaryKey {
                keyValue = d.value
            } else {
               parSql.append(d.key)
               parSql.append("=")
               parSql.append("?")
               parSql.append(",")
               values.append(d.value)
            }
        }
        parSql = parSql.xmsubstring(to: parSql.count - 1)
        parSql.append(" WHERE \(primaryKey)='\(keyValue ?? "")'")
        sql.append(parSql)
        print(sql)
        return excauteSql(sqls: [(sql,values)], dbname: dbname)
    }
        
    static func creatTabel(tableName : String , items : [String : String] , primarykey : String , dbname : String) -> Bool{
        let sql = creatTableSql(tableName: tableName, items: items, primarykey: primarykey)
        print("creatsql is \"\(sql)\"")
        return excauteSql(sqls: [(sql,nil)], dbname: dbname)
    }
    
    static func creatTableSql(tableName : String , items : [String : String] , primarykey : String) -> String {
        var sql = "create table if not exists \(tableName)"
        var parSql = ""
        for dic in items {
            parSql.append(dic.key)
            parSql.append(" ")
            parSql.append(dic.value)
            if dic.key == primarykey {
                parSql.append(" ")
                parSql.append("PRIMARY KEY")
            }
            parSql.append(",")
        }
        parSql = parSql.xmsubstring(to: parSql.count - 1)
        sql.append("(\(parSql))")
        return sql
    }
    
    
    static func excauteSqlsWithTransaction(sqls : [(String,[Any]?)] , dbname : String) -> Bool {
        guard let database = openDB(dbname: dbname) else {return false}
        do {
            database.beginTransaction()
            for sql in sqls {
                 try database.executeUpdate(sql.0,values:sql.1)
            }
            database.commit()
            database.close()
            return true
        } catch {
            database.rollback()
            print("failed: \(error)")
            database.close()
            return false
        }
    }
    
    
}

extension String {
    /// 从某个下标开始截取字符串
    func xmsubstring(from index: Int) -> String {
        if index > count {
           return ""
        }
        let range = self.index(self.startIndex, offsetBy: index) ..< self.index(self.endIndex, offsetBy: 0)
        let sub = self[range]
        return String(sub)
    }
    
    /// 从开始截取到某个下标
    func xmsubstring(to index: Int) -> String {
        if index > count {
            return self
        }
        let range = self.startIndex ..< self.index(self.startIndex, offsetBy: index)
        let sub = self[range]
        return String(sub)
    }
}




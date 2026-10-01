
package util;
 
import java.sql.Connection;
import java.sql.SQLException;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;
 
/**
 * Tomcat側(context.xml)に登録された "jdbc/mydb" という名前の
 * コネクションプールから、接続を1つ借りてくるクラス。
 *
 * DAOはこのクラスのgetConnection()を呼ぶだけでよく、
 * JNDIの詳しい仕組み(lookupなど)を意識しなくて済む。
 */
public class DBConnection {
    private static DataSource dataSource;
 
    static {
        try {
            Context ctx = new InitialContext();
            // context.xml の <Resource name="jdbc/mydb" .../> と対応
            dataSource = (DataSource) ctx.lookup("java:comp/env/jdbc/mydb");
        } catch (NamingException e) {
            throw new RuntimeException("DataSource取得失敗。context.xmlの設定を確認してください", e);
        }
    }
 
    public static Connection getConnection() throws SQLException {
        return dataSource.getConnection();
    }
}
 

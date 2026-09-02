package util;

import java.sql.Connection;
import java.sql.SQLException;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;


public class DBConnection {
	private static DataSource dataSource;
	
		static{
			try {
				Context ctx = new InitialContext();
				dataSource = (DataSource)ctx.lookup("java;comp/jdbc/mydb");
			} catch (NamingException e) {
				throw new RuntimeException("DataSource取得失敗", e);
			}
		}
		
		public static Connection getConnection() throws SQLException{
			return dataSource.getConnection();
			
		}

}

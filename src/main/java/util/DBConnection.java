package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final String URL =
        "jdbc:postgresql://172.16.1.119:5432/taskapp";

    private static final String USER =
        "taskuser";

    private static final String PASS =
        "taskpass";

    public static Connection getConnection()
            throws SQLException {

        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException(
                "PostgreSQLドライバが見つかりません",
                e);
        }

        return DriverManager.getConnection(
            URL,
            USER,
            PASS
        );
    }
}
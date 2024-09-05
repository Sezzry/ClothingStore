import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class Main {

    private static final String URL = "jdbc:mysql://127.0.0.1:3306/OnlineClothingStore";
    private static final String USER = "root";
    private static final String PASSWORD = "Joeman339617!?";

    public static void main(String[] args) {
        Connection connection = null;

        try {
            connection = DriverManager.getConnection(URL, USER, PASSWORD);
            System.out.println("Connected to the database!");

            // SQL-fråga för att hitta kunder som har köpt "SweetPants Black Trousers" i storlek '38'
            String query = "SELECT DISTINCT c.first_name, c.last_name " +
                    "FROM Customers c " +
                    "JOIN Orders o ON c.customer_id = o.customer_id " +
                    "JOIN Order_Product op ON o.order_id = op.order_id " +
                    "JOIN Products p ON op.product_id = p.product_id " +
                    "WHERE p.name = 'SweetPants Black Trousers' " +
                    "AND p.size = '38' " +
                    "AND p.color = 'Black'";

            PreparedStatement statement = connection.prepareStatement(query);
            ResultSet resultSet = statement.executeQuery();

            // Skriver ut resultatet
            System.out.println("Customers who bought SweetPants Black Trousers in size 38:");
            while (resultSet.next()) {
                String firstName = resultSet.getString("first_name");
                String lastName = resultSet.getString("last_name");
                System.out.println(" Name: " + firstName + " " + lastName);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            if (connection != null) {
                try {
                    connection.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }
}

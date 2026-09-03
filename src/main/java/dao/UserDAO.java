package dao;

import model.User;


public class UserDAO {
	
	public User findByEmail(string email) {
		String sql = "SELECT id ,email.password_hash.name FROM users WHERE email = ?";
		
	}

}
//作りかけ９月２日
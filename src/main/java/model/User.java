package model;

import java.io.Serializable;


public class User implements Serializable{
	private int id;
	private String email;
	private String passwardHash;
	private String name;
	
	// getter /setter
	public int getId () { return id;}
	public void setId(int id) {this.id = id ;}
	
	public String getEmail() {return email;}
	public void setEmail(String email) {this.email = email;}
	
	public String getPasswordHash() {return passwordHash;}
	public void setPasswordHash(String passwordHash) {this.passwordHash = passwordHash;}
	
	public String getName() {return name;}
	public void setName(String name) {this.name = name;}
}

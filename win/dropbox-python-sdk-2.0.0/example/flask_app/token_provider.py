import sqlite3

def get_access_token():
	db = sqlite3.connect('instance/myapp.db')

	cursor = db.cursor()
	row = db.execute('SELECT access_token FROM users WHERE username = ?', ['user']).fetchone()

	db.close()
	
	if row is None:
		return None

	access_token = row[0]

	return access_token
	
import sqlite3


class TokenProvider(object):

	def get_access_token(self):
		db = sqlite3.connect('instance/myapp.db')

		cursor = db.cursor()
		row = db.execute('SELECT access_token FROM users WHERE username = ?', ['user']).fetchone()

		db.close()

		if row is None:
			return None

		access_token = row[0]

		return access_token

	def remove_access_token(self):
		db = sqlite3.connect('instance/myapp.db')

		cursor = db.cursor()
		row = db.execute('DELETE FROM users WHERE username = ?', ['user'])

		db.commit()
		db.close()
	
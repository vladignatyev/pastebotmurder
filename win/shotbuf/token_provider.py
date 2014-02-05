import sqlite3
import os.path

STORAGE_PATH = 'storage.txt'

class TokenProvider(object):

	def get_access_token(self):
		if not os.path.isfile(STORAGE_PATH):
			print 'Not file'
			return None

		f = open(STORAGE_PATH, 'r')

		result = f.readline().strip()

		f.close()

		return result
		
	def set_access_token(self, token):
		print 'Token set ', type(token), token
		f = open(STORAGE_PATH, 'w')

		f.write(token)

		f.close()

	def remove_token_storage(self):
		if os.path.isfile(STORAGE_PATH):
			os.remove(STORAGE_PATH)
	
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
		f = open(STORAGE_PATH, 'w')

		f.write(token)

		f.close()

	def remove_access_token(self):
		f = open(STORAGE_PATH, 'w')

		f.close()	
	
import shelve
import os.path

STORAGE_PATH = 'storage.txt'

ACCESS_TOKEN_KEY = 'access_token'
class TokenProvider(object):

	def get_access_token(self):
		if not os.path.isfile(STORAGE_PATH):
			print 'Not file'
			return None


		d = shelve.open(STORAGE_PATH)

		result = d.get(ACCESS_TOKEN_KEY, None)

		d.close()

		return result
		
	def set_access_token(self, token):
		d = shelve.open(STORAGE_PATH)
		d[ACCESS_TOKEN_KEY] = token

		d.close()

	def remove_token(self):
		d = shelve.open(STORAGE_PATH)
		del d[ACCESS_TOKEN_KEY]
		d.close()
	
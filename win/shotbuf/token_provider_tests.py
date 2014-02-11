import unittest
import os.path
	
import token_provider
from token_provider import TokenProvider

def remove_storage():
	if os.path.isfile(token_provider.STORAGE_PATH):
			os.remove(token_provider.STORAGE_PATH)
class TokenProviderTest(unittest.TestCase):

	def setUp(self):
		self.tokenProvider = TokenProvider()
		remove_storage()

	def tearDown(self):
		remove_storage()

	def test_should_be_none_access_token_when_file_doesnt_exist(self):
		self.assertEquals(None, self.tokenProvider.get_access_token(), "should be none access token when file doesnt exist")

	def test_should_set_access_token(self):
		self.tokenProvider.set_access_token('asd')
		access_token = self.tokenProvider.get_access_token()
		print access_token
		self.assertEquals('asd', access_token, "should set access token")

	def test_should_delete_file_when_remove_access_token(self):
		self.tokenProvider.remove_token_storage()
		isFileExist = os.path.isfile(token_provider.STORAGE_PATH)
		self.assertFalse(isFileExist)


	


import token_provider

class ShotBufApp(object):

	def __init__(self, dropboxApi):
		self.dropboxApi = dropboxApi
		

	def enable(self):
		pass

	def disable(self):
		pass

	def isEnabled(self):
		pass

	def did_login(self):
		access_token = token_provider.get_access_token()
		self.dropboxApi.login_with_token(access_token)

	def isLogined(self):
		pass

	def pasteText(self, text):
		pass

	def paste_file(self, name):
		self.dropboxApi.upload_file(name)
		
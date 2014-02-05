import token_provider
from validate_email import validate_email

from urlparse import urlparse

PLAIN_TYPE = 'plain'
EMAIL_TYPE = 'email'
WEB_URL_TYPE = 'www'
SCHEME_LINK_TYPE = 'scheme'

def is_web_url(text):
	def has_web_prefix(text):
		return text.startswith('http://') or text.startswith('https://') or text.startswith('www.')

	return has_web_prefix(text)

def is_scheme_link(text):
	if is_web_url(text):
		return False
	parse_result = urlparse(text)
	return parse_result.scheme != ''


def is_email(text):
	return validate_email(text)

def get_text_type(text):
	type=PLAIN_TYPE
	if is_email(text):
		type = EMAIL_TYPE
	elif is_web_url(text):
		type = WEB_URL_TYPE
	elif is_scheme_link(text):
		type = SCHEME_LINK_TYPE
	return type

class ShotBufApp(object):

	def __init__(self, dropboxApi, tokenProvider):
		self.dropboxApi = dropboxApi
		self.tokenProvider = tokenProvider
		self.lastData = None
		self.isFirstPaste = False	

	def did_login(self):
		access_token = self.tokenProvider.get_access_token()
		self.dropboxApi.login_with_token(access_token)
		self.isFirstPaste = True

	def is_logined(self):
		access_token = self.tokenProvider.get_access_token()
		print 'access token', access_token
		return access_token != None

	def unlink_dropbox(self):
		self.dropboxApi.unlink()
		self.tokenProvider.remove_access_token()

	def paste_text(self, text):
		insert_text = text.strip()
		text_type = get_text_type(insert_text)
		self.dropboxApi.insert_text(insert_text, type=text_type)

	def paste_file(self, name):
		self.dropboxApi.upload_file(name)


	def set_data_if_new(self, data):
		if self.isFirstPaste:
			self.lastData = data
			self.isFirstPaste = False
			return False
		result = (self.lastData != data)
		if result: 
			self.lastData = data	
		return result

	def paste_text_if_new(self, text):
		isNew = self.set_data_if_new(text)
		if isNew:
			self.paste_text(text)

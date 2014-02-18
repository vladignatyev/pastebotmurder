import token_provider
from validate_email import validate_email

from urlparse import urlparse

from util import track_event

import numpy

PLAIN_TYPE = 'plain'
EMAIL_TYPE = 'email'
WEB_URL_TYPE = 'www'
SCHEME_LINK_TYPE = 'scheme'

def only_one_word_in_text(text):
	return len(text.split()) == 1

def is_web_url(text):
	def has_web_prefix(text):
		return text.startswith('http://') or text.startswith('https://') or text.startswith('www.')

	return has_web_prefix(text) and only_one_word_in_text(text)

def is_scheme_link(text):
	if is_web_url(text):
		return False
	parse_result = urlparse(text)
	return parse_result.scheme != '' and only_one_word_in_text(text)


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
		self.lastImageData = None
		self.isFirstPaste = False	

	def get_auth_url(self):
		return self.dropboxApi.start_auth()

	def did_finish_auth(self, auth_code):
		access_token = self.dropboxApi.finish_auth(auth_code)
		self.tokenProvider.set_access_token(access_token)
		self.isFirstPaste = True

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
		self.tokenProvider.remove_token_storage()

	def paste_text(self, text):
		insert_text = text.strip()
		text_type = get_text_type(insert_text)
		self.dropboxApi.insert_text(insert_text, type=text_type)

	def paste_file(self, name):
		self.dropboxApi.upload_file(name)


	def set_image_data_if_new(self, image_data):
		def setDataFunc(image_data):
			self.lastImageData = image_data
		def compareImageFunc(image_data):
			return not numpy.array_equal(self.lastImageData, image_data)

		return self.set_data_if_new(image_data, setDataFunc, compareImageFunc)


	def set_data_if_new(self, data, setDataFunc, compareFunc):
		# if self.isFirstPaste:
		# 	setDataFunc(data)
		# 	self.isFirstPaste = False
		# 	return False
		isNewData = compareFunc(data)
		if isNewData: 
			setDataFunc(data)	
		return isNewData

	def set_text_data_if_new(self, data):
		def setDataFunc(data):
			self.lastData = data
		return self.set_data_if_new(data, setDataFunc, lambda data: self.lastData != data)

	

	def paste_text_if_new(self, text):
		isNew = self.set_text_data_if_new(text)
		if isNew:
			track_event('Paste new text')
			self.paste_text(text)

	def enable(self):
		self.isFirstPaste = True

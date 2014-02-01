import unittest

from shotbuf_app import *

class FakeDropboxApi(object):

	def __init__(self):
		self.text=''

	def insert_text(self, text, type='plain'):
		self.text = text
		self.type = type

	def last_text(self):
		return self.text

	def last_type(self):
		return self.type

class ShotBufAppTestCase(unittest.TestCase):

	def setUp(self):
		self.links = ['itms-services://?action=download-manifest&url=http://www.yoursite.ru/dirname/yourFile.plist',
		'myapp-is-cool://showbigboobs!', 'ftp://someuser:somepassword@very-long.domain.63.com']
		self.texts = ['asd', 'itms-service?asd', 'httpasd', 'bla bla bla http://linux.org.ru', 'http://asd.org']
		self.dropboxApi = FakeDropboxApi()
		self.shotBufApp = ShotBufApp(self.dropboxApi)

	def test_should_be_text(self):
		text = "Welcome to the Hell!"
		isWebUrl = is_web_url(text)
		self.assertFalse(isWebUrl)

	def test_should_be_web_url_when_http_prefix(self):
		text = 'http://www.python.org/dev/peps/pep-0008/  '

		isWebUrl = is_web_url(text)

		self.assertTrue(isWebUrl, "should be link when http prefix")

	def test_should_not_be_web_url_when_short_text(self):
		text = 'd'

		isWebUrl = is_web_url(text)

		self.assertFalse(isWebUrl, "should not be link when short text")

	def test_should_be_web_url_when_https_prefix(self):
		text = 'https://www.facebook.com/'

		isWebUrl = is_web_url(text)

		self.assertTrue(isWebUrl, 'should be link when https prefix')
	def test_should_be_web_url_when_www_prefix(self):
		text = 'www.google.com'

		isWebUrl = is_web_url(text)

		self.assertTrue(isWebUrl, 'should be link when www prefix')

	def test_should_be_scheme_link(self):

		for link in self.links:
			self.assertTrue(is_scheme_link(link), "should be link")

	def test_should_not_be_scheme_link(self):
		for text in self.texts:
			self.assertFalse(is_scheme_link(text), 'should not be link %s' % text)

	def test_text_should_not_be_email(self):
		for text in self.texts:
			self.assertFalse(is_email(text))

	def test_scheme_links_should_not_be_email(self):
		for link in self.links:
			self.assertFalse(is_email(link))

	def test_should_be_email(self):
		emails = ['very.very-long.long1238@email.organization.info', 'ya.na.pochte@gmail.com', 'varuzhnikov@gmail.com', 'huy@ivanov.krutoy.server.museum']
		
		for email in emails:
			self.assertTrue(is_email(email))

	def test_should_be_text_type(self):
		self.assertEquals(PLAIN_TYPE, get_text_type('asd'))

	def test_should_be_email_type(self):
		self.assertEquals(EMAIL_TYPE, get_text_type('very.very-long.long1238@email.organization.info'))

	def test_should_be_web_url_type(self):
		self.assertEquals(WEB_URL_TYPE, get_text_type('http://linux.org.ru'))

	def test_should_be_scheme_link_type(self):
		actual_type = get_text_type('itms-services://?action=download-manifest&url=http://www.yoursite.ru/dirname/yourFile.plist')

		self.assertEquals(SCHEME_LINK_TYPE, actual_type)

	def test_should_insert_trimmed_link_in_data_store(self):
		self.shotBufApp.paste_text('   http://linux.org.ru   ')

		self.assertEquals('http://linux.org.ru', self.dropboxApi.last_text())
		self.assertEquals(WEB_URL_TYPE, self.dropboxApi.last_type())

	def test_should_be_new_image_when_first(self):
		image_data = 'image data'

		isNew = self.shotBufApp.set_image_data_if_new(image_data)

		self.assertTrue(isNew, "Should be new image when first image come")

	def test_should_set_new_image_when_first(self):
		image_data = 'image data'

		isNew = self.shotBufApp.set_image_data_if_new(image_data)

		self.assertEquals(image_data, self.shotBufApp.lastImageData, "should set new image when first")

	def test_should_be_duplicate_image_when_buffer_same(self):
		image_data = 'image data'
		same_image_data = 'image data'
		self.shotBufApp.lastImageData = image_data

		isNew = self.shotBufApp.set_image_data_if_new(same_image_data)

		self.assertFalse(isNew, "should be duplicate image when buffer same")

	def test_should_be_new_image_when_buffers_differ(self):
		image_data = 'image data'
		another_image_data = 'another image data'
		self.shotBufApp.lastImageData = image_data

		isNew = self.shotBufApp.set_image_data_if_new(another_image_data)

		self.assertTrue(isNew, "should be new image when buffers differ")		

	def test_should_set_new_image_data_when_buffers_differ(self):
		image_data = 'image data'
		new_image_data = 'another image data'
		self.shotBufApp.lastImageData = image_data

		self.shotBufApp.set_image_data_if_new(new_image_data)

		self.assertEquals(new_image_data, self.shotBufApp.lastImageData, "should be new image when buffers differ")		

	def test_should_not_set_new_image_data_when_same_image(self):
		image_data = 'image data'
		new_image_data = 'image data'
		self.shotBufApp.lastImageData = image_data

		self.shotBufApp.set_image_data_if_new(new_image_data)

		self.assertEquals(image_data, self.shotBufApp.lastImageData, "should be new image when buffers differ")		


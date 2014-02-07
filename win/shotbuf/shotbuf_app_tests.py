import unittest

from shotbuf_app import *
import numpy

class FakeDropboxApi(object):

	def __init__(self):
		self.text=''

	def login_with_token(self, token):
		pass

	def insert_text(self, text, type='plain'):
		self.text = text
		self.type = type

	def last_text(self):
		return self.text

	def last_type(self):
		return self.type

class FakeTokenProvider(object):


	def get_access_token(self):
		return None

	def remove_access_token(self):
		pass
	

class ShotBufAppTestCase(unittest.TestCase):

	def setUp(self):
		self.links = ['itms-services://?action=download-manifest&url=http://www.yoursite.ru/dirname/yourFile.plist',
		'myapp-is-cool://showbigboobs!', 'ftp://someuser:somepassword@very-long.domain.63.com']
		self.texts = ['asd', 'itms-service?asd', 'httpasd', 'bla bla bla http://linux.org.ru', 'http://asd.org']
		self.dropboxApi = FakeDropboxApi()
		self.tokenProvider = FakeTokenProvider()

		self.shotBufApp = ShotBufApp(self.dropboxApi, self.tokenProvider)

	def test_should_be_first_paste_after_did_login(self):
		self.shotBufApp.did_login()

		self.assertTrue(self.shotBufApp.isFirstPaste, "should be first paste after did login")

	def test_should_be_first_paster_after_enable(self):
		self.shotBufApp.enable()

		self.assertTrue(self.shotBufApp.isFirstPaste)

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

	def test_should_be_text_type_when_contains_links(self):
		self.assertEquals(PLAIN_TYPE, get_text_type('http://linux.org.ru   asd'))

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

	def test_should_be_false_status_when_first_paste(self):
		self.shotBufApp.isFirstPaste = True
		data = 'data'

		isNew = self.shotBufApp.set_text_data_if_new(data)

		self.assertFalse(isNew, "Should be new data when first data come")

	def test_should_reset_first_paste_status_after_first_paste(self):
		self.shotBufApp.isFirstPaste = True
		data = 'data'

		isNew = self.shotBufApp.set_text_data_if_new(data)

		self.assertFalse(self.shotBufApp.isFirstPaste, "Should reset first paste status after first paste")

	def test_should_set_new_data_when_first_paste(self):
		data = 'data'

		isNew = self.shotBufApp.set_text_data_if_new(data)

		self.assertEquals(data, self.shotBufApp.lastData, "should set new data when first")

	def test_should_be_duplicate_data_when_text_same(self):
		data = 'data'
		same_data = 'data'
		self.shotBufApp.lastData = data

		isNew = self.shotBufApp.set_text_data_if_new(same_data)

		self.assertFalse(isNew, "should be duplicate data when buffer same")

	def test_should_be_new_data_when_data_differ(self):
		data = 'data'
		another_data = 'another data'
		self.shotBufApp.lastData = data

		isNew = self.shotBufApp.set_text_data_if_new(another_data)

		self.assertTrue(isNew, "should be new data when buffers differ")		

	def test_should_set_new_data_when_text_differ(self):
		data = 'data'
		new_data = 'another data'
		self.shotBufApp.lastData = data

		self.shotBufApp.set_text_data_if_new(new_data)

		self.assertEquals(new_data, self.shotBufApp.lastData, "should be new data when buffers differ")		

	def test_should_not_set_new_data_when_same_data(self):
		data = 'data'
		new_data = 'data'
		self.shotBufApp.lastData = data

		self.shotBufApp.set_text_data_if_new(new_data)

		self.assertEquals(data, self.shotBufApp.lastData, "should be new data when buffers differ")		

	def test_last_image_data_should_be_none_by_default(self):
		self.assertEquals(None, self.shotBufApp.lastImageData)

	def test_should_set_first_image(self):
		self.shotBufApp.isFirstPaste = True
		image = numpy.zeros((10, 10, 3), dtype=numpy.uint8)

		self.shotBufApp.set_image_data_if_new(image)

		self.assertTrue(numpy.array_equal(image , self.shotBufApp.lastImageData))

	def test_should_be_new_image_when_no_previous_image(self):
		image = numpy.zeros((10, 10, 3), dtype=numpy.uint8)

		isNew = self.shotBufApp.set_image_data_if_new(image)

		self.assertTrue(isNew, "should be new image when no previous image")

	def test_should_be_new_image_when_buffers_data_differ(self):
		old_image = numpy.zeros((10, 10, 3), dtype=numpy.uint8)
		self.shotBufApp.lastImageData = old_image

		new_image = numpy.zeros((10, 10, 3), dtype=numpy.uint8)
		new_image[0,0,0] = 1
		isNew = self.shotBufApp.set_image_data_if_new(new_image)

		self.assertTrue(isNew, "should be new image when buffers differ")

	def test_should_be_new_image_when_buffers_size_differ(self):
		old_image = numpy.zeros((10, 10, 3), dtype=numpy.uint8)
		self.shotBufApp.lastImageData = old_image

		new_image = numpy.zeros((12, 10, 3), dtype=numpy.uint8)
		new_image[0,0,0] = 1
		isNew = self.shotBufApp.set_image_data_if_new(new_image)

		self.assertTrue(isNew, "should be new image when buffers size differ")

	def test_should_set_new_image_when_buffers_size_differ(self):
		old_image = numpy.zeros((10, 10, 3), dtype=numpy.uint8)
		self.shotBufApp.lastImageData = old_image

		new_image = numpy.zeros((12, 10, 3), dtype=numpy.uint8)
		new_image[0,0,0] = 1
		isNew = self.shotBufApp.set_image_data_if_new(new_image)

		self.assertTrue(numpy.array_equal(new_image, self.shotBufApp.lastImageData), "should set new image when buffers size differ")

import unittest
import update_checker
from update_checker import UpdateChecker


class FakeAppCastParser(object):
	def __init__(self):
		self.updated = False

	def get_download_link(self):
		return 'http://shotbuf.com/exe/ShotBuf_1.2.0_64-bit.exe'

	def get_version(self):
		return '1.2.0'

	def get_release_notes(self):
		return 'Some release notes'

	def update(self):
		self.updated = True

class UpdateCheckerTest(unittest.TestCase):

	def setUp(self):
		self.appCastParser = FakeAppCastParser()
		self.updateChecker = UpdateChecker(self.appCastParser)
		print 'update checker', self.updateChecker

	def test_should_update_appcast_before_comparing(self):
		self.updateChecker.is_newest_version_available()
		self.assertTrue(self.appCastParser.updated)

	def test_should_be_newest_version_availabe(self):
		print 'checker', self.updateChecker
		self.assertTrue(self.updateChecker.is_newest_version_available())

	def test_should_not_be_newest_version_available(self):
		update_checker.CURRENT_VERSION = '1.3.0'
		self.assertFalse(self.updateChecker.is_newest_version_available())

	def test_should_not_be_newest_version_available_when_version_same(self):
		update_checker.CURRENT_VERSION = '1.2.0'
		self.assertFalse(self.updateChecker.is_newest_version_available())

	def test_should_be_newest_version_available_when_version(self):
		update_checker.CURRENT_VERSION = '1.1.3'
		self.assertTrue(self.updateChecker.is_newest_version_available())

	def test_should_get_release_notes(self):
		self.assertEquals('Some release notes', self.updateChecker.get_release_notes())

	def test_should_get_newest_version(self):
		self.assertEquals('1.2.0', self.updateChecker.get_newest_version())
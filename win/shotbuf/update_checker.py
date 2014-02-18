
from distutils.version import StrictVersion

CURRENT_VERSION = '1.2.0'

class UpdateChecker(object):

	def __init__(self, appcast_reader):
		self.appCastReader = appcast_reader
	
	def is_newest_version_available(self):
		self.appCastReader.update()
		return StrictVersion(CURRENT_VERSION) < StrictVersion(self.appCastReader.get_version())

	def get_release_notes(self):
		return self.appCastReader.get_release_notes()

	def get_newest_version(self):
		return self.appCastReader.get_version()

	def get_new_version_download_link(self):
		return self.appCastReader.get_download_link()

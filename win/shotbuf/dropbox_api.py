import dropbox
from dropbox.datastore import DatastoreError, DatastoreManager, Date, Bytes
from datetime import datetime
from dropbox import rest as dbrest
from dropbox.client import DropboxOAuth2FlowNoRedirect

APP_KEY = '84zxlqvsmm2py5y'
APP_SECRET = 'u5sva6uz22bvuyy'

class DropboxApi(object):

	def start_auth(self):
		self.auth_flow = DropboxOAuth2FlowNoRedirect(APP_KEY, APP_SECRET)
		authorize_url = self.auth_flow.start()
		return authorize_url

	def finish_auth(self, auth_code):
		try:
			access_token, user_id = self.auth_flow.finish(auth_code)
		except dbrest.ErrorResponse , e:
			print 'Error %s' % e
			return

		print 'finish auth access_token', access_token

		self.login_with_token(access_token)

		return access_token

	def login_with_token(self, token):
		self.token = token
		self.client = dropbox.client.DropboxClient(self.token)

		print 'linked account: ', self.client.account_info()

		self.manager = DatastoreManager(self.client)
		self.datastore = self.manager.open_default_datastore()
		self.bufs_table = self.datastore.get_table('bufs_values')

	def unlink(self):
		self.datastore.close()

	def insert_text(self, text, type='plain'):
		def insert_record():
			dt = datetime.now()
			d = Date.from_datetime_local(dt)
			buf = self.bufs_table.insert(value=text, type=type, created=d)
		self.datastore.transaction(insert_record, max_tries=4)

	def upload_file(self, file):
		dt = datetime.now()
		def insert_record():
			d = Date.from_datetime_local(dt)
			buf = self.bufs_table.insert(value=upload_file_name, type='image', created=d)

		f = open(file, 'rb')

		upload_file_name = 'Shot at %s.png' % dt.strftime("%d.%m.%y %H:%M:%S")

		self.datastore.transaction(insert_record, max_tries=4)

		response = self.client.put_file(upload_file_name, f)
		
		

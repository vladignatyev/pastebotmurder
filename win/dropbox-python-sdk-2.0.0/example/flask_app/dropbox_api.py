import dropbox
from dropbox.datastore import DatastoreError, DatastoreManager, Date, Bytes
from datetime import datetime

class DropboxApi(object):

	def login_with_token(self, token):
		self.token = token
		self.client = dropbox.client.DropboxClient(self.token)

		print 'linked account: ', self.client.account_info()

		manager = DatastoreManager(self.client)
		datastore = manager.open_default_datastore()
		self.bufs_table = datastore.get_table('bufs_values')

	def clear_data(self):
		pass

	def insert_record(self):
		d = Date(time())
		buf = self.bufs_table.insert(value='HUI PIZDA', type='plain', created=d)
		datastore.commit()

	def upload_file(self, file):
		f = open(file, 'rb')
		dt = datetime.now()
		upload_file_name = 'Shot at %s.png' % dt.strftime("%d.%m.%y %H:%M:%S")

		response = self.client.put_file(upload_file_name, f)
		print 'uploaded: ', response

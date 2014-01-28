class DropboxApi(object):

	def init(self, token):
		self.token = token
		client = DropboxClient(access_token)
		manager = DatastoreManager(client)
		datastore = manager.open_default_datastore()
		self.bufs_table = datastore.get_table('bufs_values')
		
		# bufs = bufs_table.query()
		# for buf in bufs:
			# print buf
				# buf.delete_record()


	def clear_data(self):
		pass

	def insert_record(self):
		d = Date(time())
		buf = bufs_table.insert(value='HUI PIZDA', type='plain', created=d)
		datastore.commit()

	def upload_image(self, image):
		pass

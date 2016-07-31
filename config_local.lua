cfg.influxDB = {
  host = '192.168.1.101',
  port = '8086',
  dbname = 'sensors',
  username = 'sensors',
  password = 'super-secret'
}
cfg.influxTags = {
  node = 'node01',
  location = 'location01'
}
cfg.production = false

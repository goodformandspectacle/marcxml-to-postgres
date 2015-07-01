use Rack::Static,
  :urls => { '/' => 'index.html' },
  :root => "public",
  :index => 'index.html',
  :header_rules => [[:all, {'Cache-Control' => 'public, max-age=1'}]]

use Rack::Deflater

app = Proc.new do |env|
  ['404', {'Content-Type' => 'text/plain'}, ['Page Not Found']]
end

run app
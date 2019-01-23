class web_server {
  include web_server::install
  include web_server::config
  include web_server::service
}

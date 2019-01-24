class web_server {
  include epel
  include web_server::install
  include web_server::config
  include web_server::service
}

import app/router
import app/web
import gleam/erlang/process
import mist
import wisp

pub fn main() {
  wisp.configure_logger()
  let secret = wisp.random_string(64)
  let ctx = web.Context(static_directory: web.static_directory())
  let assert Ok(_) =
    wisp.mist_handler(router.handle_request(_, ctx), secret)
    |> mist.new
    |> mist.port(8080)
    |> mist.start_http
  process.sleep_forever()
}

import gleam/erlang/process
import mist
import wisp
import app/web
import app/router

pub fn main() {
  wisp.configure_logger()
  let secret = wisp.random_string(64)
  let ctx = web.Context(static_directory: web.static_directory())
  let assert Ok(_) =
    wisp.mist_handler(router.handle_request(_, ctx), secret)
    |> mist.new
    |> mist.port(1480)
    |> mist.start_http
  process.sleep_forever()
}




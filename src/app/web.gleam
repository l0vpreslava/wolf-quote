import app/model.{type AppError, type QuoteResponse}
import gleam/dynamic
import gleam/hackney
import gleam/http/request
import gleam/http/response
import gleam/json
import gleam/result
import wisp.{type Request, type Response}

pub type Context {
  Context(static_directory: String)
}

pub fn get_random_quote() -> Result(QuoteResponse, AppError) {
  let decoder =
    dynamic.decode2(
      model.QuoteResponse,
      dynamic.field("quoteText", of: dynamic.string),
      dynamic.field("quoteAuthor", of: dynamic.string),
    )

  let assert Ok(req) = request.to("http://api.forismatic.com/api/1.0/")
  let req =
    request.set_query(req, [
      #("method", "getQuote"),
      #("format", "json"),
      #("lang", "ru"),
    ])
  let result =
    hackney.send(req)
    |> result.map_error(model.HackneyError)
    |> result.try(error_on_status)

  use response <- result.try(result)
  json.decode(response.body, decoder)
  |> result.map_error(model.DecodeError)
}

pub fn middleware(
  req: Request,
  ctx: Context,
  handler: fn(Request) -> Response,
) -> Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  use <- wisp.serve_static(req, under: "/static", from: ctx.static_directory)
  handler(req)
}

pub fn static_directory() -> String {
  let assert Ok(priv_directory) = wisp.priv_directory("wolf_quotes")
  priv_directory <> "/static"
}

pub fn error_on_status(
  r: response.Response(a),
) -> Result(response.Response(a), AppError) {
  case 400 <= r.status && r.status < 600 {
    True -> Error(model.ResponseError(r.status))
    False -> Ok(r)
  }
}

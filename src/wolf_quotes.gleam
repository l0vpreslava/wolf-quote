import gleam/dynamic
import gleam/erlang/process
import gleam/hackney
import gleam/http/request
import gleam/http/response
import gleam/json
import gleam/list
import gleam/result
import gleam/string
import gleam/string_builder
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import mist
import simplifile
import wisp.{type Request, type Response}

pub type QuoteResponse {
  QuoteResponse(quote_text: String, quote_author: String)
}

pub type AppError {
  FileError(simplifile.FileError)
  HackneyError(hackney.Error)
  ResponseError(status: Int)
  DecodeError(json.DecodeError)
  NoImagesError
}

pub type Context {
  Context(static_directory: String)
}

pub fn main() {
  wisp.configure_logger()
  let secret = wisp.random_string(64)
  let ctx = Context(static_directory: static_directory())
  let assert Ok(_) =
    wisp.mist_handler(handle_request(_, ctx), secret)
    |> mist.new
    |> mist.port(1480)
    |> mist.start_http
  process.sleep_forever()
}

pub fn get_random_quote() -> Result(QuoteResponse, AppError) {
  let decoder =
    dynamic.decode2(
      QuoteResponse,
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
    |> result.map_error(HackneyError)
    |> result.try(error_on_status)

  use response <- result.try(result)
  json.decode(response.body, decoder)
  |> result.map_error(DecodeError)
}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use _req <- middleware(req, ctx)
  let body = {
    use image <- result.try(get_random_image(ctx))
    use quote <- result.map(get_random_quote())

    root("/static/images/" <> image, quote.quote_text, quote.quote_author)
    |> element.to_document_string_builder
  }
  let response = case body {
    Ok(body) -> #(body, 200)
    Error(error) -> #(
      { "500 Internal Server Error: " <> string.inspect(error) }
        |> string_builder.from_string,
      500,
    )
  }
  wisp.html_response(response.0, response.1)
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

pub fn get_images(ctx: Context) -> Result(List(String), AppError) {
  simplifile.read_directory(ctx.static_directory <> "/images")
  |> result.map_error(FileError)
}

pub fn get_random_image(ctx: Context) -> Result(String, AppError) {
  use list_image <- result.try(get_images(ctx))

  list_image
  |> list.shuffle
  |> list.first
  |> result.replace_error(NoImagesError)
}

pub fn error_on_status(
  r: response.Response(a),
) -> Result(response.Response(a), AppError) {
  case 400 <= r.status && r.status < 600 {
    True -> Error(ResponseError(r.status))
    False -> Ok(r)
  }
}

pub fn layout(elements: List(Element(a))) -> Element(a) {
  html.html([], [
    html.head([], [
      html.title([], "Wolf quote"),
      html.meta([
        attribute.name("viewport"),
        attribute.attribute("content", "width=device-width, initial-scale=1.0"),
        attribute.attribute("charset", "UTF-8"),
      ]),
    ]),
    html.body([], elements),
  ])
}

pub fn root(image_src: String, quote_text: String, quote_author: String) {
  layout([
    html.h1([], [html.text(quote_text)]),
    html.h2([], [html.text(quote_author)]),
    html.img([attribute.src(image_src), attribute.alt("Great wolf!")]),
  ])
}

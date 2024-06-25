import app/images
import app/pages
import app/web.{type Context}
import gleam/result
import gleam/string
import gleam/string_builder
import lustre/element
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use _req <- web.middleware(req, ctx)
  let body = {
    use image <- result.try(images.get_random_image(ctx))
    use quote <- result.map(web.get_random_quote())

    pages.root("/static/images/" <> image, quote.quote_text, quote.quote_author)
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

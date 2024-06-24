import gleam/hackney
import gleam/json
import simplifile

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

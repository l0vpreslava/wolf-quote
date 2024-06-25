import app/model.{type AppError}
import app/web.{type Context}
import gleam/list
import gleam/result
import simplifile

pub fn get_images(ctx: Context) -> Result(List(String), AppError) {
  simplifile.read_directory(ctx.static_directory <> "/images")
  |> result.map_error(model.FileError)
}

pub fn get_random_image(ctx: Context) -> Result(String, AppError) {
  use list_image <- result.try(get_images(ctx))

  list_image
  |> list.shuffle
  |> list.first
  |> result.replace_error(model.NoImagesError)
}

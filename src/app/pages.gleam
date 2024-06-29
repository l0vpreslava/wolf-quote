import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html

pub fn layout(elements: List(Element(a))) -> Element(a) {
  html.html([], [
    html.head([], [
      html.title([], "Wolf quote"),
      html.meta([
        attribute.name("viewport"),
        attribute.attribute("content", "width=device-width, initial-scale=1.0"),
        attribute.attribute("charset", "UTF-8"),
      ]),
      html.link([
        attribute.rel("stylesheet"),
        attribute.href("static/styles.css"),
      ]),
      html.script([attribute.src("static/script.js")], ""),
    ]),
    html.body([], elements),
  ])
}

pub fn root(image_src: String, quote_text: String, quote_author: String) {
  let quote_text = "«" <> quote_text <> "»"
  layout([
    html.div([], [
      html.div([], [
        html.img([
          attribute.src(image_src),
          attribute.class("image"),
          attribute.alt("Great wolf!"),
        ]),
      ]),
      html.div([attribute.class("quote-block")], [
        html.h1([attribute.class("quote-text")], [html.text(quote_text)]),
        html.h2([attribute.class("quote-author")], [html.text(quote_author)]),
        html.button([attribute.class("reload-button")], [
          html.text("Новая цитата"),
        ]),
      ]),
    ]),
  ])
}

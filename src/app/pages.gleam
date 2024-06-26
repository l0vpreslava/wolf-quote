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
    ]),
    html.body([], elements),
  ])
}

pub fn root(image_src: String, quote_text: String, quote_author: String) {
  layout([
    html.div([], [
      html.div([attribute.class("image")], [
        html.img([
          attribute.src(image_src),
          attribute.width(480),
          attribute.height(270),
          attribute.alt("Great wolf!"),
        ]),
      ]),
      html.div([], [
        html.h1([attribute.class("quote-text")], [html.text(quote_text)]),
      ]),
      html.div([], [
        html.h2([attribute.class("quote-author")], [html.text(quote_author)]),
      ]),
    ]),
  ])
}

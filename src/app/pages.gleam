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


require 'thor'
require 'kramdown'

module Md2slide
  class CLI < Thor
    def build_full_html(slides_html)
      template = ERB.new(<<~HTML)
        <!DOCTIPE html>
        <html>
        <head><meta charset="UTF-8">
          <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/reveal.js/dist/reveal.css">
        </head>
        <body>
          <div class="reveal"><div class="slides">
            <% slides_html.each do |slide| %>
              <section><%= slide %></section>
            <% end %>
          </div></div>
          <script src="https://cdn.jsdelivr.net/npm/reveal.js/dist/reveal.js"></script>
          <script>Reveal.initialize();</script>
        </body>
        </html>
      HTML
      template.result(binding)
    end

    desc "build FILE", "convert markdown to html slide"
    def build(file)
      content = File.read(file)
      doc = Kramdown::Document.new(content)
      slides = []
      current = nil

      doc.root.children.each do |element|
        if element.type == :header && element.options[:level] == 1
          current = [element]
          slides << current
        else
          current&.push(element)
        end
      end

      slides_html = slides.map do |elements|
        root = Kramdown::Element.new(:root, nil, nil, doc.root.options)
        root.children = elements
        html, _warnings = Kramdown::Converter::Html.convert(root, doc.options)
        html
      end

      File.write("output.html", build_full_html(slides_html))


    end

    desc "serve FILE", "run preview server"
    def serve(file)
    end
  end

end

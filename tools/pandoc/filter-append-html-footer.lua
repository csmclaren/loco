function Pandoc(doc)

  -- Get the current date
  local date = os.date("!%Y-%m-%d")
  local date_formatted = os.date("!%B %d, %Y")

  -- Create the content
  local content = '<footer>\n' .. '<p>This document was produced on <time datetime="' .. date .. '">' .. date_formatted .. '</time>, from the original <a href="https://en.wikipedia.org/wiki/Markdown">Markdown</a> version, using <a href="https://pandoc.org">Pandoc</a>.</p>' .. '\n</footer>'

  -- Create an element and append it to the document
  local element = pandoc.RawBlock("html", content)
  table.insert(doc.blocks, element)

  return doc
end

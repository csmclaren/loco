function Pandoc(doc)

  -- Get the current date
  local date = os.date("!%Y-%m-%d")
  local date_formatted = os.date("!%B %d, %Y")

  -- Create an element and append it to the document
  local content = "<footer>\n" .. '<p>This document was produced on <time datetime="' .. date .. '">' .. date_formatted .. '</time>, using <a href="https://pandoc.org">Pandoc</a>.</p>' .. "\n</footer>"
  local element = pandoc.RawBlock("html", content)
  table.insert(doc.blocks, element)

  return doc
end

function Pandoc(doc)

  -- Get the current date
  local date = os.date("!%Y-%m-%d")
  local date_formatted = os.date("!%B %d, %Y")

  -- Create an element and append it to the document
  local element = pandoc.Para({
    pandoc.Str("This document was produced on "),
    pandoc.Str(date_formatted),
    pandoc.Str(".")
  })
  table.insert(doc.blocks, element)

  return doc
end

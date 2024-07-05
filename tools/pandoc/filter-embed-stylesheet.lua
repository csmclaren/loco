function Meta(meta)

  -- Create the content
  local fname = "docs/loco.css"
  local file = io.open(fname, "r")
  local content = '<style>\n' .. file:read("*all") .. '\n</style>'
  file:close()

  -- Create an element and insert it into the document
  local element = pandoc.RawBlock("html", content)
  meta['stylesheet'] = element

  return meta
end

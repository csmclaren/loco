function Meta(meta)

  -- Create the content
  local fpath = meta.filter_embed_stylesheet_fpath
  local file = io.open(fpath, "r")
  local content = '<style>\n' .. file:read("*all") .. '\n</style>'
  file:close()

  -- Create an element and insert it into the document
  local element = pandoc.RawBlock("html", content)
  meta.stylesheet = element

  return meta
end

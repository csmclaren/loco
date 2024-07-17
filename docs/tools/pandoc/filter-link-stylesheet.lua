function Meta(meta)

  -- Create the content
  local fpath = pandoc.utils.stringify(meta.filter_link_stylesheet_fpath)
  local content = '<link rel="stylesheet" href="' .. fpath .. '">'

  -- Create an element and insert it into the document
  local element = pandoc.RawBlock("html", content)
  meta.stylesheet = element

  return meta
end

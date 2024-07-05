function Meta(meta)

  -- Create the content
  local fname = "loco.css"
  local content = '<link rel="stylesheet" href="' .. fname .. '">'

  -- Create an element and insert it into the document
  local element = pandoc.RawBlock("html", content)
  meta['stylesheet'] = element

  return meta
end
